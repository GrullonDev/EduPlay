/**
 * firestore.rules coverage for the Tienda: storeCatalog access, and the
 * purchase-write validation on students/{studentId} (price/PRO/minLevel/
 * seasonal-availability integrity, plus the parentUid/childProfileId
 * hijack guard). Runs against the real Firestore emulator via
 * @firebase/rules-unit-testing — fake_cloud_firestore (used by the Dart
 * test suite) has no rules engine, so this is the only place these rules
 * are actually exercised.
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

const baseStudent = { name: 'Explorador', age: 8, points: 0, streak: 0 };

describe('storeCatalog', () => {
  it('is readable without authentication', async () => {
    await seed((db) =>
      db.collection('storeCatalog').doc('item1').set({ cost: 100 }),
    );
    await assertSucceeds(
      unauthed().collection('storeCatalog').doc('item1').get(),
    );
  });

  it('cannot be written by a non-admin authenticated user', async () => {
    await assertFails(
      asUser('kid1')
        .collection('storeCatalog')
        .doc('item1')
        .set({ cost: 100 }),
    );
  });

  it('can be written by a user whose parents/{uid}.role is admin', async () => {
    await seed((db) =>
      db.collection('parents').doc('admin1').set({ role: 'admin' }),
    );
    await assertSucceeds(
      asUser('admin1')
        .collection('storeCatalog')
        .doc('item1')
        .set({ cost: 100 }),
    );
  });
});

describe('students/{studentId} purchase validation', () => {
  it('allows a direct purchase with the correct declared cost and matching point deduction', async () => {
    await seed(async (db) => {
      await db.collection('storeCatalog').doc('item1').set({ cost: 100 });
      await db
        .collection('students')
        .doc('s1')
        .set({ ...baseStudent, points: 200 });
    });

    await assertSucceeds(
      asUser('s1')
        .collection('students')
        .doc('s1')
        .set(
          {
            ...baseStudent,
            points: 100,
            ownedItemIds: ['item1'],
            lastPurchase: { itemId: 'item1', cost: 100 },
          },
          { merge: true },
        ),
    );
  });

  it('rejects a purchase whose declared cost does not match the catalog price', async () => {
    await seed(async (db) => {
      await db.collection('storeCatalog').doc('item1').set({ cost: 100 });
      await db
        .collection('students')
        .doc('s2')
        .set({ ...baseStudent, points: 200 });
    });

    await assertFails(
      asUser('s2')
        .collection('students')
        .doc('s2')
        .set(
          {
            ...baseStudent,
            points: 199,
            ownedItemIds: ['item1'],
            lastPurchase: { itemId: 'item1', cost: 1 },
          },
          { merge: true },
        ),
    );
  });

  it('rejects growing ownedItemIds without deducting the matching points', async () => {
    await seed(async (db) => {
      await db.collection('storeCatalog').doc('item1').set({ cost: 100 });
      await db
        .collection('students')
        .doc('s3')
        .set({ ...baseStudent, points: 200 });
    });

    await assertFails(
      asUser('s3')
        .collection('students')
        .doc('s3')
        .set(
          {
            ...baseStudent,
            points: 200, // unchanged — should have dropped by 100
            ownedItemIds: ['item1'],
            lastPurchase: { itemId: 'item1', cost: 100 },
          },
          { merge: true },
        ),
    );
  });

  it('rejects a PRO-only item for a free subscriber', async () => {
    await seed(async (db) => {
      await db
        .collection('storeCatalog')
        .doc('pro1')
        .set({ cost: 50, isProOnly: true });
      await db
        .collection('students')
        .doc('s4')
        .set({ ...baseStudent, points: 100 });
      await db.collection('subscriptions').doc('s4').set({ tier: 'free' });
    });

    await assertFails(
      asUser('s4')
        .collection('students')
        .doc('s4')
        .set(
          {
            ...baseStudent,
            points: 50,
            ownedItemIds: ['pro1'],
            lastPurchase: { itemId: 'pro1', cost: 50 },
          },
          { merge: true },
        ),
    );
  });

  it('allows a PRO-only item for a pro subscriber', async () => {
    await seed(async (db) => {
      await db
        .collection('storeCatalog')
        .doc('pro1')
        .set({ cost: 50, isProOnly: true });
      await db
        .collection('students')
        .doc('s5')
        .set({ ...baseStudent, points: 100 });
      await db.collection('subscriptions').doc('s5').set({ tier: 'pro' });
    });

    await assertSucceeds(
      asUser('s5')
        .collection('students')
        .doc('s5')
        .set(
          {
            ...baseStudent,
            points: 50,
            ownedItemIds: ['pro1'],
            lastPurchase: { itemId: 'pro1', cost: 50 },
          },
          { merge: true },
        ),
    );
  });

  it('rejects a purchase below the catalog item minLevel', async () => {
    await seed(async (db) => {
      await db
        .collection('storeCatalog')
        .doc('leveled')
        .set({ cost: 10, minLevel: 5 });
      // 50 points → level 1 (points ~/ 100 + 1), well under minLevel 5.
      await db
        .collection('students')
        .doc('s6')
        .set({ ...baseStudent, points: 50 });
    });

    await assertFails(
      asUser('s6')
        .collection('students')
        .doc('s6')
        .set(
          {
            ...baseStudent,
            points: 40,
            ownedItemIds: ['leveled'],
            lastPurchase: { itemId: 'leveled', cost: 10 },
          },
          { merge: true },
        ),
    );
  });

  it('allows a purchase once the buyer meets the catalog item minLevel', async () => {
    await seed(async (db) => {
      await db
        .collection('storeCatalog')
        .doc('leveled')
        .set({ cost: 10, minLevel: 5 });
      // 500 points → level 6, meets minLevel 5.
      await db
        .collection('students')
        .doc('s7')
        .set({ ...baseStudent, points: 500 });
    });

    await assertSucceeds(
      asUser('s7')
        .collection('students')
        .doc('s7')
        .set(
          {
            ...baseStudent,
            points: 490,
            ownedItemIds: ['leveled'],
            lastPurchase: { itemId: 'leveled', cost: 10 },
          },
          { merge: true },
        ),
    );
  });

  it('rejects a purchase of a seasonal item before its availableFrom date', async () => {
    // A plain JS Date is auto-converted to a Firestore Timestamp on write —
    // matches what StoreItem.toJson() writes in the app, and what
    // isCatalogItemAvailable() compares against request.time directly.
    const future = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    await seed(async (db) => {
      await db
        .collection('storeCatalog')
        .doc('future')
        .set({ cost: 10, availableFrom: future });
      await db
        .collection('students')
        .doc('s8')
        .set({ ...baseStudent, points: 100 });
    });

    await assertFails(
      asUser('s8')
        .collection('students')
        .doc('s8')
        .set(
          {
            ...baseStudent,
            points: 90,
            ownedItemIds: ['future'],
            lastPurchase: { itemId: 'future', cost: 10 },
          },
          { merge: true },
        ),
    );
  });

  it('rejects a purchase of a seasonal item after its availableUntil date', async () => {
    const past = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    await seed(async (db) => {
      await db
        .collection('storeCatalog')
        .doc('expired')
        .set({ cost: 10, availableUntil: past });
      await db
        .collection('students')
        .doc('s9')
        .set({ ...baseStudent, points: 100 });
    });

    await assertFails(
      asUser('s9')
        .collection('students')
        .doc('s9')
        .set(
          {
            ...baseStudent,
            points: 90,
            ownedItemIds: ['expired'],
            lastPurchase: { itemId: 'expired', cost: 10 },
          },
          { merge: true },
        ),
    );
  });

  it('allows a benign write (recordScore-style) with no purchase fields touched', async () => {
    await seed(async (db) => {
      await db
        .collection('students')
        .doc('s10')
        .set({ ...baseStudent, points: 30 });
    });

    await assertSucceeds(
      asUser('s10')
        .collection('students')
        .doc('s10')
        .set({ points: 40, streak: 1, lastPlayedDate: '2026-08-12' }, { merge: true }),
    );
  });

  it('rejects rewriting parentUid to hijack an already-linked profile', async () => {
    await seed(async (db) =>
      db
        .collection('students')
        .doc('s11')
        .set({ ...baseStudent, parentUid: 'parentA' }),
    );

    await assertFails(
      asUser('attacker')
        .collection('students')
        .doc('s11')
        .set({ points: 999, parentUid: 'attacker' }, { merge: true }),
    );
  });

  it('allows a benign write that keeps parentUid unchanged', async () => {
    await seed(async (db) =>
      db
        .collection('students')
        .doc('s12')
        .set({ ...baseStudent, parentUid: 'parentA' }),
    );

    await assertSucceeds(
      asUser('parentA')
        .collection('students')
        .doc('s12')
        .set({ points: 40, parentUid: 'parentA' }, { merge: true }),
    );
  });

  it('allows setting parentUid for the first time (initial linking)', async () => {
    await seed(async (db) =>
      db.collection('students').doc('s13').set({ ...baseStudent }),
    );

    await assertSucceeds(
      asUser('parentB')
        .collection('students')
        .doc('s13')
        .set({ parentUid: 'parentB' }, { merge: true }),
    );
  });
});

describe('students/{studentId}/transactions', () => {
  it('allows creating a well-shaped transaction entry', async () => {
    await seed((db) => db.collection('students').doc('s20').set(baseStudent));

    await assertSucceeds(
      asUser('s20')
        .collection('students')
        .doc('s20')
        .collection('transactions')
        .doc('t1')
        .set({ itemId: 'item1', cost: 10 }),
    );
  });

  it('rejects updating an existing transaction entry (append-only ledger)', async () => {
    await seed((db) =>
      db
        .collection('students')
        .doc('s21')
        .collection('transactions')
        .doc('t1')
        .set({ itemId: 'item1', cost: 10 }),
    );

    await assertFails(
      asUser('s21')
        .collection('students')
        .doc('s21')
        .collection('transactions')
        .doc('t1')
        .set({ itemId: 'item1', cost: 20 }),
    );
  });
});
