/**
 * firestore.rules coverage for the teacher dashboard's top-level `classes`
 * collection: classes/{classId}, classes/{classId}/members/{memberId}, and
 * classes/{classId}/challenges/{challengeId}. Runs against the real
 * Firestore emulator via @firebase/rules-unit-testing, same pattern as
 * store.rules.test.js / subscriptions.rules.test.js.
 *
 * classes/{classId}/members/{memberId} read access was previously
 * `allow read: if request.auth != null` — any authenticated user (any
 * teacher, any parent, a collectionGroup('members') query) could read
 * every class's full roster (names/emails/ages/parentUid). It is now
 * narrowed to the owning teacher, the linked parent, or the member
 * themself; the "denied to a random 4th user" tests below are the
 * regression coverage for that fix.
 *
 * Requires the emulator running first (see package.json's "test" script,
 * which wraps this in `firebase emulators:exec`).
 */

const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'eduplay-rules-test';

/** @type {import('@firebase/rules-unit-testing').RulesTestEnvironment} */
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(
        path.resolve(__dirname, '../../firestore.rules'),
        'utf8',
      ),
      host: '127.0.0.1',
      port: 8085,
    },
  });
});

after(async () => {
  if (testEnv) await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

/** Seeds documents bypassing all rules, like an admin SDK / migration script would. */
function seed(setupFn) {
  return testEnv.withSecurityRulesDisabled(async (context) => {
    await setupFn(context.firestore());
  });
}

function asUser(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function unauthed() {
  return testEnv.unauthenticatedContext().firestore();
}

const baseClass = (overrides = {}) => ({
  teacherUid: 'teacher1',
  teacherName: 'Profe Ana',
  name: '4to Grado A',
  subject: 'math',
  gradeLevel: '4to',
  joinCode: 'AB12CD',
  studentCount: 0,
  minAge: 8,
  maxAge: 10,
  isPublic: false,
  ...overrides,
});

describe('classes/{classId}', () => {
  it('allows the owning teacher to create a class declaring their own teacherUid', async () => {
    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .set(baseClass()),
    );
  });

  it('rejects creating a class with someone else as teacherUid', async () => {
    await assertFails(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .set(baseClass({ teacherUid: 'teacher2' })),
    );
  });

  it('rejects an unauthenticated create', async () => {
    await assertFails(
      unauthed().collection('classes').doc('c1').set(baseClass()),
    );
  });

  it('allows the owning teacher to update their class', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .set(baseClass({ name: 'Renamed' }), { merge: true }),
    );
  });

  it('rejects another teacher updating a class they do not own', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertFails(
      asUser('teacher2')
        .collection('classes')
        .doc('c1')
        .set(baseClass({ name: 'Hijacked' }), { merge: true }),
    );
  });

  it('rejects a non-owner incrementing studentCount by one (the old client-side join escape hatch is gone)', async () => {
    // joinClassByCode now increments studentCount server-side via the Admin
    // SDK — a client (even the joining parent) has no rules-level path to
    // bump this field on a class they don't own.
    await seed((db) =>
      db.collection('classes').doc('c1').set(baseClass({ studentCount: 5 })),
    );

    await assertFails(
      asUser('parent1')
        .collection('classes')
        .doc('c1')
        .set({ studentCount: 6 }, { merge: true }),
    );
  });

  it('allows the owning teacher to delete their class', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertSucceeds(
      asUser('teacher1').collection('classes').doc('c1').delete(),
    );
  });

  it('rejects a non-owner deleting a class', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertFails(
      asUser('teacher2').collection('classes').doc('c1').delete(),
    );
  });

  it('allows the owning teacher to read their own private class', async () => {
    await seed((db) =>
      db.collection('classes').doc('c1').set(baseClass({ isPublic: false })),
    );

    await assertSucceeds(
      asUser('teacher1').collection('classes').doc('c1').get(),
    );
  });

  it('rejects a different authenticated user reading a private class', async () => {
    await seed((db) =>
      db.collection('classes').doc('c1').set(baseClass({ isPublic: false })),
    );

    await assertFails(
      asUser('someone-else').collection('classes').doc('c1').get(),
    );
  });

  it('allows any authenticated user to read a public class', async () => {
    await seed((db) =>
      db.collection('classes').doc('c1').set(baseClass({ isPublic: true })),
    );

    await assertSucceeds(
      asUser('someone-else').collection('classes').doc('c1').get(),
    );
  });
});

describe('classes/{classId}/members/{memberId}', () => {
  const seedClassAndMember = (memberOverrides = {}) =>
    seed(async (db) => {
      await db.collection('classes').doc('c1').set(baseClass());
      await db
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .set({
          classId: 'c1',
          teacherUid: 'teacher1',
          displayName: 'Sofía',
          email: 'parent@example.com',
          role: 'student',
          studentId: 'student1',
          parentUid: 'parent1',
          ...memberOverrides,
        });
    });

  it('allows the owning teacher to read a member doc', async () => {
    await seedClassAndMember();

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .get(),
    );
  });

  it('allows the linked parent to read a member doc', async () => {
    await seedClassAndMember();

    await assertSucceeds(
      asUser('parent1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .get(),
    );
  });

  it('allows the member themself (memberId == auth.uid) to read the member doc', async () => {
    await seed(async (db) => {
      await db.collection('classes').doc('c1').set(baseClass());
      await db
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('student1')
        .set({
          classId: 'c1',
          teacherUid: 'teacher1',
          studentId: 'student1',
          parentUid: 'parent1',
        });
    });

    await assertSucceeds(
      asUser('student1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('student1')
        .get(),
    );
  });

  it('DENIES a random fourth user from reading a member doc (the fixed security hole)', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('random-attacker')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .get(),
    );
  });

  it('allows the owning teacher to create a member doc', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .set({ classId: 'c1', teacherUid: 'teacher1', parentUid: 'parent1' }),
    );
  });

  it('allows a parent to create a member doc declaring themself as parentUid (join flow)', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertSucceeds(
      asUser('parent1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .set({ classId: 'c1', teacherUid: 'teacher1', parentUid: 'parent1' }),
    );
  });

  it('allows the member themself to create their own member doc', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertSucceeds(
      asUser('student1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('student1')
        .set({ classId: 'c1', teacherUid: 'teacher1', parentUid: 'parent1' }),
    );
  });

  it('DENIES a random fourth user from creating a member doc for someone else', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertFails(
      asUser('random-attacker')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .set({ classId: 'c1', teacherUid: 'teacher1', parentUid: 'parent1' }),
    );
  });

  it('allows the owning teacher to update a member doc', async () => {
    await seedClassAndMember();

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .set({ focusSubject: 'science' }, { merge: true }),
    );
  });

  it('DENIES a random fourth user from updating a member doc', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('random-attacker')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .set({ focusSubject: 'science' }, { merge: true }),
    );
  });

  it('allows the owning teacher to delete a member doc', async () => {
    await seedClassAndMember();

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .delete(),
    );
  });

  it('allows the linked parent to delete a member doc', async () => {
    await seedClassAndMember();

    await assertSucceeds(
      asUser('parent1')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .delete(),
    );
  });

  it('DENIES a random fourth user from deleting a member doc', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('random-attacker')
        .collection('classes')
        .doc('c1')
        .collection('members')
        .doc('m1')
        .delete(),
    );
  });
});

describe('classes/{classId}/challenges/{challengeId}', () => {
  const seedClassAndChallenge = () =>
    seed(async (db) => {
      await db.collection('classes').doc('c1').set(baseClass());
      await db
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .set({ title: 'Suma rápida', status: 'active' });
    });

  it('allows any authenticated user to read a challenge', async () => {
    await seedClassAndChallenge();

    await assertSucceeds(
      asUser('anyone')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .get(),
    );
  });

  it('rejects an unauthenticated read of a challenge', async () => {
    await seedClassAndChallenge();

    await assertFails(
      unauthed()
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .get(),
    );
  });

  it('allows the owning teacher to create a challenge', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .set({ title: 'Suma rápida', status: 'active' }),
    );
  });

  it('DENIES another teacher (not owning the class) from creating a challenge', async () => {
    await seed((db) => db.collection('classes').doc('c1').set(baseClass()));

    await assertFails(
      asUser('teacher2')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .set({ title: 'Suma rápida', status: 'active' }),
    );
  });

  it('allows the owning teacher to update a challenge', async () => {
    await seedClassAndChallenge();

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .set({ status: 'completed' }, { merge: true }),
    );
  });

  it('DENIES another teacher from updating a challenge', async () => {
    await seedClassAndChallenge();

    await assertFails(
      asUser('teacher2')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .set({ status: 'completed' }, { merge: true }),
    );
  });

  it('allows the owning teacher to delete a challenge', async () => {
    await seedClassAndChallenge();

    await assertSucceeds(
      asUser('teacher1')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .delete(),
    );
  });

  it('DENIES another teacher from deleting a challenge', async () => {
    await seedClassAndChallenge();

    await assertFails(
      asUser('teacher2')
        .collection('classes')
        .doc('c1')
        .collection('challenges')
        .doc('ch1')
        .delete(),
    );
  });
});
