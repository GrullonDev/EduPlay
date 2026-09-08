/**
 * firestore.rules coverage for notifications/{notificationId}, focused on
 * the `teacher_message` creation branch: a teacher may only notify the
 * parent of a student actually enrolled in one of their own classes. The
 * rule cross-checks classes/{classId}.teacherUid against the caller, and
 * classes/{classId}/members/{memberId}.parentUid against the declared
 * recipientUid — so a teacher can't message an arbitrary uid, and can't
 * mis-declare recipientUid to reroute the notification away from the
 * member's real parent.
 *
 * Runs against the real Firestore emulator via @firebase/rules-unit-testing,
 * same pattern as store.rules.test.js / subscriptions.rules.test.js /
 * classes.rules.test.js.
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

/** Seeds a class owned by `teacher1` and one member in it, linked to `parent1`. */
function seedClassAndMember() {
  return seed(async (db) => {
    await db.collection('classes').doc('c1').set({
      teacherUid: 'teacher1',
      name: '4to Grado A',
      isPublic: false,
    });
    await db
      .collection('classes')
      .doc('c1')
      .collection('members')
      .doc('m1')
      .set({
        classId: 'c1',
        teacherUid: 'teacher1',
        parentUid: 'parent1',
        studentId: 'student1',
        displayName: 'Sofía',
      });
  });
}

const teacherMessage = (overrides = {}) => ({
  type: 'teacher_message',
  senderUid: 'teacher1',
  senderRole: 'teacher',
  recipientUid: 'parent1',
  classId: 'c1',
  memberId: 'm1',
  read: false,
  title: 'Progreso de Sofía',
  body: 'Sofía tuvo una gran semana.',
  ...overrides,
});

describe("notifications/{notificationId} — type: 'teacher_message'", () => {
  it('allows the owning teacher to notify the real parent of a class member', async () => {
    await seedClassAndMember();

    await assertSucceeds(
      asUser('teacher1')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage()),
    );
  });

  it('rejects a teacher who does not own the class', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('teacher2')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage({ senderUid: 'teacher2' })),
    );
  });

  it('rejects declaring recipientUid as someone other than the member\'s real parentUid', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('teacher1')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage({ recipientUid: 'attacker' })),
    );
  });

  it('rejects a memberId that belongs to a different class than the declared classId', async () => {
    await seed(async (db) => {
      await db
        .collection('classes')
        .doc('c1')
        .set({ teacherUid: 'teacher1', name: 'Clase A', isPublic: false });
      await db
        .collection('classes')
        .doc('c2')
        .set({ teacherUid: 'teacher1', name: 'Clase B', isPublic: false });
      // Member lives under c2, but the notification will falsely declare c1.
      await db
        .collection('classes')
        .doc('c2')
        .collection('members')
        .doc('m1')
        .set({ classId: 'c2', teacherUid: 'teacher1', parentUid: 'parent1' });
    });

    await assertFails(
      asUser('teacher1')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage({ classId: 'c1', memberId: 'm1' })),
    );
  });

  it('rejects senderRole other than teacher', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('teacher1')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage({ senderRole: 'parent' })),
    );
  });

  it('rejects a caller impersonating another sender uid', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('attacker')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage()),
    );
  });

  it('rejects creating the notification already marked read', async () => {
    await seedClassAndMember();

    await assertFails(
      asUser('teacher1')
        .collection('notifications')
        .doc('n1')
        .set(teacherMessage({ read: true })),
    );
  });

  it('the recipient parent can read the notification once created', async () => {
    await seedClassAndMember();
    await seed((db) =>
      db.collection('notifications').doc('n1').set(teacherMessage()),
    );

    await assertSucceeds(
      asUser('parent1').collection('notifications').doc('n1').get(),
    );
  });

  it('a different user cannot read the notification', async () => {
    await seedClassAndMember();
    await seed((db) =>
      db.collection('notifications').doc('n1').set(teacherMessage()),
    );

    await assertFails(
      asUser('someone-else').collection('notifications').doc('n1').get(),
    );
  });
});
