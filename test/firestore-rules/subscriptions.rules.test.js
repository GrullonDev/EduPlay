/**
 * firestore.rules coverage for subscriptions/{uid}: a user may read/create
 * their own doc and update non-tier fields (usage counters written by the
 * client), but only the Admin SDK — i.e. Cloud Functions such as the
 * Recurrente webhook / cancelRecurrenteSubscription — may ever set `tier`.
 * Runs against the real Firestore emulator via @firebase/rules-unit-testing,
 * same pattern as store.rules.test.js.
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

/** Seeds documents bypassing all rules, like an admin SDK / Cloud Function would. */
function seed(setupFn) {
  return testEnv.withSecurityRulesDisabled(async (context) => {
    await setupFn(context.firestore());
  });
}

function asUser(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

describe('subscriptions/{uid}', () => {
  it('allows a user to read their own subscription doc', async () => {
    await seed((db) =>
      db.collection('subscriptions').doc('u1').set({ tier: 'free' }),
    );

    await assertSucceeds(
      asUser('u1').collection('subscriptions').doc('u1').get(),
    );
  });

  it("rejects a user reading another user's subscription doc", async () => {
    await seed((db) =>
      db.collection('subscriptions').doc('u2').set({ tier: 'free' }),
    );

    await assertFails(
      asUser('attacker').collection('subscriptions').doc('u2').get(),
    );
  });

  it('allows a user to create their own subscription doc with tier: free', async () => {
    await assertSucceeds(
      asUser('u3')
        .collection('subscriptions')
        .doc('u3')
        .set({ tier: 'free', sessionsThisMonth: 0, monthYear: '2026-09' }),
    );
  });

  it('rejects a user creating their own subscription doc with tier: pro (self-promotion)', async () => {
    await assertFails(
      asUser('u4')
        .collection('subscriptions')
        .doc('u4')
        .set({ tier: 'pro', sessionsThisMonth: 0, monthYear: '2026-09' }),
    );
  });

  it('rejects a user updating their own tier to pro', async () => {
    await seed((db) =>
      db
        .collection('subscriptions')
        .doc('u5')
        .set({ tier: 'free', sessionsThisMonth: 0, monthYear: '2026-09' }),
    );

    await assertFails(
      asUser('u5')
        .collection('subscriptions')
        .doc('u5')
        .set({ tier: 'pro' }, { merge: true }),
    );
  });

  it('allows re-sending the same tier value, since affectedKeys() only lists fields whose value actually changes', async () => {
    // firestore.rules guards `affectedKeys().hasAny(['tier'])`, which is a
    // diff against the *value* — writing the same tier the doc already has
    // is indistinguishable from not touching it at all, so this succeeds.
    // (Actually changing the value is covered by the previous test.)
    await seed((db) =>
      db
        .collection('subscriptions')
        .doc('u6')
        .set({ tier: 'free', sessionsThisMonth: 0, monthYear: '2026-09' }),
    );

    await assertSucceeds(
      asUser('u6')
        .collection('subscriptions')
        .doc('u6')
        .set({ tier: 'free' }, { merge: true }),
    );
  });

  it('allows a user to update usage counters without touching tier', async () => {
    await seed((db) =>
      db
        .collection('subscriptions')
        .doc('u7')
        .set({ tier: 'free', sessionsThisMonth: 0, monthYear: '2026-09' }),
    );

    await assertSucceeds(
      asUser('u7')
        .collection('subscriptions')
        .doc('u7')
        .set(
          { sessionsThisMonth: 1, monthYear: '2026-09' },
          { merge: true },
        ),
    );
  });

  it('allows the Admin SDK (Cloud Functions) to set tier freely', async () => {
    // Simulates what recurrenteWebhook / cancelRecurrenteSubscription do
    // with the Admin SDK, which bypasses these rules entirely.
    await seed((db) =>
      db.collection('subscriptions').doc('u8').set({ tier: 'free' }),
    );

    await seed((db) =>
      db
        .collection('subscriptions')
        .doc('u8')
        .set({ tier: 'pro' }, { merge: true }),
    );

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await context
        .firestore()
        .collection('subscriptions')
        .doc('u8')
        .get();
      if (snap.data().tier !== 'pro') {
        throw new Error('Admin SDK write did not persist tier: pro');
      }
    });
  });
});
