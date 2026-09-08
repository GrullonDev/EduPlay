/**
 * Teacher-class join-by-code operations (Guatemala/LATAM roster feature).
 *
 * Why these live server-side: `classes/{classId}` documents belong to one
 * teacher, but "join a class by code" is fundamentally a cross-tenant
 * lookup — a parent/student needs to find a class they don't own by its
 * `joinCode`. Doing that as a direct client-side Firestore query requires
 * `classes/{classId}` to be broadly readable, which also lets any
 * authenticated user enumerate every class (public or not) and harvest
 * every join code, teacher name, etc. via an unfiltered collection read —
 * a real leak, since a join code is meant to gate entry the same way a
 * password would.
 *
 * These three callables replace that broad client read with three narrow,
 * server-mediated operations (Admin SDK, bypasses rules): looking up a
 * class by code, joining it, and generating a code guaranteed unique
 * across *all* classes (not just the caller's own — which is all the
 * client could see once `classes/{classId}` read is tightened to
 * `isPublic == true || teacherUid == request.auth.uid`, see
 * firestore.rules). Public classes remain directly browsable by the
 * client (`getPublicClassesForAge` in teacher_classes_datasource.dart) —
 * that's an intentional discovery feature, not a leak, since `isPublic`
 * classes are meant to be found without a code.
 */

'use strict';

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

function classFromDoc(doc) {
  const data = doc.data() ?? {};
  return {
    id: doc.id,
    teacherUid: data.teacherUid ?? '',
    teacherName: data.teacherName ?? '',
    name: data.name ?? '',
    subject: data.subject ?? '',
    gradeLevel: data.gradeLevel ?? '',
    joinCode: data.joinCode ?? '',
    studentCount: data.studentCount ?? 0,
    minAge: data.minAge ?? 3,
    maxAge: data.maxAge ?? 12,
    isPublic: data.isPublic ?? false,
    // Timestamps don't survive the callable's JSON transport as Timestamp
    // objects — send millis, the client already treats a missing/invalid
    // createdAt as "now" (see TeacherClass.fromMap).
    createdAtMillis: data.createdAt?.toMillis?.() ?? null,
  };
}

async function findClassByCode(db, code) {
  const normalized = String(code ?? '').trim().toUpperCase();
  if (!normalized) return null;
  const snap = await db
    .collection('classes')
    .where('joinCode', '==', normalized)
    .limit(1)
    .get();
  return snap.empty ? null : snap.docs[0];
}

// ─────────────────────────────────────────────────────────────────────────────
// lookupClassByJoinCode
// ─────────────────────────────────────────────────────────────────────────────

const lookupClassByJoinCode = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
  }
  const code = request.data?.code;
  if (!code || typeof code !== 'string') {
    throw new HttpsError('invalid-argument', 'code es requerido.');
  }

  const db = admin.firestore();
  const doc = await findClassByCode(db, code);
  if (!doc) {
    return { found: false };
  }
  return { found: true, teacherClass: classFromDoc(doc) };
});

// ─────────────────────────────────────────────────────────────────────────────
// joinClassByCode
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Takes the classId the client already has from an earlier
 * lookupClassByJoinCode call (a document id isn't a secret — nothing is
 * gained by making the client resend the join code here) and joins it via
 * the Admin SDK — same member-doc shape and studentCount increment as the
 * old client-side `joinClass()` transaction, just running server-side so
 * it doesn't need `classes/{classId}` to be client-readable.
 */
const joinClassByCode = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
  }

  const data = request.data ?? {};
  const classId = data.classId;
  const displayName = data.displayName;
  const email = data.email;
  const role = data.role;
  if (!classId || typeof classId !== 'string') {
    throw new HttpsError('invalid-argument', 'classId es requerido.');
  }
  if (!displayName || typeof displayName !== 'string') {
    throw new HttpsError('invalid-argument', 'displayName es requerido.');
  }
  if (!role || typeof role !== 'string') {
    throw new HttpsError('invalid-argument', 'role es requerido.');
  }

  const studentId = typeof data.studentId === 'string' ? data.studentId : null;
  const childProfileId =
    typeof data.childProfileId === 'string' ? data.childProfileId : '';
  const parentUid = typeof data.parentUid === 'string' ? data.parentUid : uid;
  const age = typeof data.age === 'number' ? data.age : null;
  const focusSubject =
    typeof data.focusSubject === 'string' ? data.focusSubject : '';

  const db = admin.firestore();
  const classRef = db.collection('classes').doc(classId);
  const classDoc = await classRef.get();
  if (!classDoc.exists) {
    throw new HttpsError('not-found', 'Clase no encontrada.');
  }

  const classData = classDoc.data() ?? {};
  const memberKey = studentId && studentId.length > 0 ? studentId : uid;
  const memberRef = classRef.collection('members').doc(memberKey);

  await db.runTransaction(async (tx) => {
    const existing = await tx.get(memberRef);

    tx.set(
      memberRef,
      {
        classId: classDoc.id,
        teacherUid: classData.teacherUid ?? '',
        className: classData.name ?? '',
        classSubject: classData.subject ?? '',
        classGradeLevel: classData.gradeLevel ?? '',
        displayName,
        email: email ?? '',
        role,
        studentId: studentId ?? memberKey,
        childProfileId,
        parentUid,
        age,
        focusSubject,
        completedChallengeIds: existing.data()?.completedChallengeIds ?? [],
        joinedAt: existing.exists
          ? existing.data()?.joinedAt ?? admin.firestore.FieldValue.serverTimestamp()
          : admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    if (!existing.exists) {
      tx.update(classRef, {
        studentCount: admin.firestore.FieldValue.increment(1),
      });
    }
  });

  return { success: true, classId: classDoc.id };
});

// ─────────────────────────────────────────────────────────────────────────────
// generateUniqueJoinCode
// ─────────────────────────────────────────────────────────────────────────────

const JOIN_CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function randomJoinCode() {
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += JOIN_CODE_ALPHABET[Math.floor(Math.random() * JOIN_CODE_ALPHABET.length)];
  }
  return code;
}

/**
 * Scans across *all* classes (not just the caller's own) for a collision —
 * something the client can no longer do itself once `classes/{classId}`
 * read is tightened to `isPublic == true || teacherUid == request.auth.uid`.
 * Without this, two different teachers' private classes could silently end
 * up sharing a join code.
 */
const generateUniqueJoinCode = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
  }

  const db = admin.firestore();
  for (let attempt = 0; attempt < 20; attempt++) {
    const code = randomJoinCode();
    const existing = await db
      .collection('classes')
      .where('joinCode', '==', code)
      .limit(1)
      .get();
    if (existing.empty) {
      return { code };
    }
  }
  throw new HttpsError(
    'resource-exhausted',
    'No se pudo generar un código único. Intenta de nuevo.'
  );
});

module.exports = {
  lookupClassByJoinCode,
  joinClassByCode,
  generateUniqueJoinCode,
};
