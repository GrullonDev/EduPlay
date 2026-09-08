/**
 * Integration tests for functions/classes.js against the real Firestore
 * emulator — same harness as recurrente.integration.test.js (firebase-
 * functions-test's wrap() to invoke onCall handlers directly, Admin SDK
 * pointed at FIRESTORE_EMULATOR_HOST).
 *
 * Run via `npm test` in functions/, which wraps this in
 * `firebase emulators:exec --only firestore`.
 */

'use strict';

const assert = require('node:assert/strict');
const { test, before, after, beforeEach } = require('node:test');

process.env.GCLOUD_PROJECT = process.env.GCLOUD_PROJECT || 'eduplay-rules-test';
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8085';

const admin = require('firebase-admin');
if (!admin.apps.length) {
  admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT });
}
const db = admin.firestore();

const functionsTest = require('firebase-functions-test')();

const {
  lookupClassByJoinCode,
  joinClassByCode,
  generateUniqueJoinCode,
} = require('../classes');

const lookupByCode = functionsTest.wrap(lookupClassByJoinCode);
const joinByCode = functionsTest.wrap(joinClassByCode);
const generateCode = functionsTest.wrap(generateUniqueJoinCode);

async function clearCollection(name) {
  const snap = await db.collection(name).get();
  await Promise.all(snap.docs.map((d) => d.ref.delete()));
}

async function seedClass(overrides = {}) {
  const ref = db.collection('classes').doc();
  await ref.set({
    teacherUid: 'teacher-1',
    teacherName: 'Profe Ana',
    name: 'Matemáticas 3B',
    subject: 'math',
    gradeLevel: '3',
    joinCode: 'ABC123',
    studentCount: 0,
    minAge: 7,
    maxAge: 9,
    isPublic: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    ...overrides,
  });
  return ref;
}

before(async () => {
  await clearCollection('classes');
});

after(async () => {
  await clearCollection('classes');
  functionsTest.cleanup();
});

beforeEach(async () => {
  await clearCollection('classes');
});

test('lookupClassByJoinCode: rejects unauthenticated calls', async () => {
  await assert.rejects(
    () => lookupByCode({ data: { code: 'ABC123' }, auth: null }),
    (err) => {
      assert.equal(err.code, 'unauthenticated');
      return true;
    }
  );
});

test('lookupClassByJoinCode: rejects a missing code', async () => {
  await assert.rejects(
    () => lookupByCode({ data: {}, auth: { uid: 'parent-1' } }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    }
  );
});

test('lookupClassByJoinCode: returns found:false for an unknown code', async () => {
  const result = await lookupByCode({
    data: { code: 'ZZZZZZ' },
    auth: { uid: 'parent-1' },
  });
  assert.equal(result.found, false);
});

test('lookupClassByJoinCode: finds a class by code, case/space insensitive', async () => {
  await seedClass({ joinCode: 'ABC123' });

  const result = await lookupByCode({
    data: { code: ' abc123 ' },
    auth: { uid: 'parent-1' },
  });

  assert.equal(result.found, true);
  assert.equal(result.teacherClass.name, 'Matemáticas 3B');
  assert.equal(result.teacherClass.teacherUid, 'teacher-1');
  assert.equal(result.teacherClass.joinCode, 'ABC123');
});

test('joinClassByCode: rejects unauthenticated calls', async () => {
  await assert.rejects(
    () =>
      joinByCode({
        data: { classId: 'x', displayName: 'Kid', role: 'student' },
        auth: null,
      }),
    (err) => {
      assert.equal(err.code, 'unauthenticated');
      return true;
    }
  );
});

test('joinClassByCode: rejects a missing classId', async () => {
  await assert.rejects(
    () =>
      joinByCode({
        data: { displayName: 'Kid', role: 'student' },
        auth: { uid: 'parent-1' },
      }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    }
  );
});

test('joinClassByCode: rejects an unknown classId', async () => {
  await assert.rejects(
    () =>
      joinByCode({
        data: { classId: 'does-not-exist', displayName: 'Kid', role: 'student' },
        auth: { uid: 'parent-1' },
      }),
    (err) => {
      assert.equal(err.code, 'not-found');
      return true;
    }
  );
});

test('joinClassByCode: creates a member doc and increments studentCount', async () => {
  const classRef = await seedClass();

  const result = await joinByCode({
    data: {
      classId: classRef.id,
      displayName: 'Lilo',
      email: 'parent@example.com',
      role: 'student',
      studentId: 'student-lilo',
      childProfileId: 'student-lilo',
      parentUid: 'parent-1',
      age: 8,
      focusSubject: 'math',
    },
    auth: { uid: 'parent-1' },
  });

  assert.equal(result.success, true);

  const memberSnap = await classRef.collection('members').doc('student-lilo').get();
  assert.equal(memberSnap.exists, true);
  const member = memberSnap.data();
  assert.equal(member.displayName, 'Lilo');
  assert.equal(member.parentUid, 'parent-1');
  assert.equal(member.className, 'Matemáticas 3B');
  assert.equal(member.teacherUid, 'teacher-1');

  const classSnap = await classRef.get();
  assert.equal(classSnap.data().studentCount, 1);
});

test('joinClassByCode: re-joining the same student does not double-increment studentCount', async () => {
  const classRef = await seedClass();
  const joinArgs = {
    classId: classRef.id,
    displayName: 'Lilo',
    email: 'parent@example.com',
    role: 'student',
    studentId: 'student-lilo',
    parentUid: 'parent-1',
  };

  await joinByCode({ data: joinArgs, auth: { uid: 'parent-1' } });
  await joinByCode({ data: joinArgs, auth: { uid: 'parent-1' } });

  const classSnap = await classRef.get();
  assert.equal(classSnap.data().studentCount, 1);
});

test('generateUniqueJoinCode: rejects unauthenticated calls', async () => {
  await assert.rejects(
    () => generateCode({ data: {}, auth: null }),
    (err) => {
      assert.equal(err.code, 'unauthenticated');
      return true;
    }
  );
});

test('generateUniqueJoinCode: returns a 6-character code not colliding with an existing class', async () => {
  await seedClass({ joinCode: 'ABC123' });

  const result = await generateCode({ data: {}, auth: { uid: 'teacher-2' } });

  assert.equal(typeof result.code, 'string');
  assert.equal(result.code.length, 6);
  assert.notEqual(result.code, 'ABC123');
});
