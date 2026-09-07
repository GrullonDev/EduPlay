/**
 * Integration tests for functions/payments/recurrente.js against the real
 * Firestore emulator (no mocked Firestore, no calls to the live Recurrente
 * API — that isn't reachable from this sandbox).
 *
 * Uses firebase-functions-test's wrapV2 to invoke the onCall handlers
 * directly with a synthetic CallableRequest ({ auth, data }), and
 * admin.initializeApp() pointed at the local Firestore emulator via
 * FIRESTORE_EMULATOR_HOST (set before requiring anything below).
 *
 * Run via `npm test` in functions/, which wraps this in
 * `firebase emulators:exec --only firestore`.
 *
 * NOT covered here (documented rather than faked): the happy path of
 * createRecurrenteCheckout that talks to Recurrente's real
 * checkout_custom_links endpoint. It's exercised below by temporarily
 * overriding global.fetch, which is the minimal seam available without
 * pulling in a full HTTP-mocking library — see the "happy path" describe
 * block. If that seam ever proves too fragile, it's fine to delete just
 * that block; the unauthenticated/invalid-argument paths (the bulk of the
 * function's own logic) do not depend on it.
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
  createRecurrenteCheckout,
  cancelRecurrenteSubscription,
} = require('../payments/recurrente');

const createCheckout = functionsTest.wrap(createRecurrenteCheckout);
const cancelSubscription = functionsTest.wrap(cancelRecurrenteSubscription);

/** Deletes every doc in a collection — cheap emulator-only cleanup. */
async function clearCollection(name) {
  const snap = await db.collection(name).get();
  await Promise.all(snap.docs.map((d) => d.ref.delete()));
}

before(async () => {
  await clearCollection('orders');
  await clearCollection('subscriptions');
});

after(async () => {
  await clearCollection('orders');
  await clearCollection('subscriptions');
  functionsTest.cleanup();
});

beforeEach(async () => {
  await clearCollection('orders');
  await clearCollection('subscriptions');
});

test('createRecurrenteCheckout rejects an unauthenticated call', async () => {
  await assert.rejects(
    () => createCheckout({ data: {} }),
    (err) => {
      assert.equal(err.code, 'unauthenticated');
      return true;
    },
  );
});

test('createRecurrenteCheckout rejects amount <= 0', async () => {
  await assert.rejects(
    () =>
      createCheckout({
        auth: { uid: 'u1' },
        data: {
          amount: 0,
          orderId: 'o1',
          userEmail: 'a@b.com',
          itemName: 'Pro plan',
        },
      }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    },
  );
});

test('createRecurrenteCheckout rejects a non-numeric amount', async () => {
  await assert.rejects(
    () =>
      createCheckout({
        auth: { uid: 'u1' },
        data: {
          amount: 'lots',
          orderId: 'o1',
          userEmail: 'a@b.com',
          itemName: 'Pro plan',
        },
      }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    },
  );
});

test('createRecurrenteCheckout rejects a missing orderId', async () => {
  await assert.rejects(
    () =>
      createCheckout({
        auth: { uid: 'u1' },
        data: { amount: 50, userEmail: 'a@b.com', itemName: 'Pro plan' },
      }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    },
  );
});

test('createRecurrenteCheckout rejects a missing userEmail', async () => {
  await assert.rejects(
    () =>
      createCheckout({
        auth: { uid: 'u1' },
        data: { amount: 50, orderId: 'o1', itemName: 'Pro plan' },
      }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    },
  );
});

test('createRecurrenteCheckout rejects a missing itemName', async () => {
  await assert.rejects(
    () =>
      createCheckout({
        auth: { uid: 'u1' },
        data: { amount: 50, orderId: 'o1', userEmail: 'a@b.com' },
      }),
    (err) => {
      assert.equal(err.code, 'invalid-argument');
      return true;
    },
  );
});

test('createRecurrenteCheckout (happy path, fetch mocked) creates the order doc and returns the checkout URL', async () => {
  const originalFetch = global.fetch;
  global.fetch = async () => ({
    ok: true,
    text: async () =>
      JSON.stringify({ checkout_url: 'https://recurrente.test/c/abc', id: 'ch_abc' }),
  });

  try {
    const result = await createCheckout({
      auth: { uid: 'u1' },
      data: {
        amount: 99.5,
        orderId: 'order-happy-1',
        userEmail: 'a@b.com',
        itemName: 'Pro plan',
        metadata: { kind: 'subscription' },
        isTest: true,
      },
    });

    assert.equal(result.success, true);
    assert.equal(result.checkoutUrl, 'https://recurrente.test/c/abc');
    assert.equal(result.checkoutId, 'ch_abc');

    const orderSnap = await db.collection('orders').doc('order-happy-1').get();
    assert.equal(orderSnap.exists, true);
    const order = orderSnap.data();
    assert.equal(order.uid, 'u1');
    assert.equal(order.status, 'PENDING');
    assert.equal(order.paymentMethod, 'RECURRENTE');
    assert.equal(order.kind, 'subscription');
    assert.equal(order.mode, 'test');
  } finally {
    global.fetch = originalFetch;
  }
});

test('cancelRecurrenteSubscription rejects an unauthenticated call', async () => {
  await assert.rejects(
    () => cancelSubscription({ data: {} }),
    (err) => {
      assert.equal(err.code, 'unauthenticated');
      return true;
    },
  );
});

test('cancelRecurrenteSubscription is a no-op when there is no subscription doc', async () => {
  const result = await cancelSubscription({ auth: { uid: 'nouser' }, data: {} });
  assert.deepEqual(result, { success: true, alreadyFree: true });

  const snap = await db.collection('subscriptions').doc('nouser').get();
  assert.equal(snap.exists, false);
});

test('cancelRecurrenteSubscription is a no-op when the subscription is already free', async () => {
  await db.collection('subscriptions').doc('freeuser').set({ tier: 'free' });

  const result = await cancelSubscription({ auth: { uid: 'freeuser' }, data: {} });
  assert.deepEqual(result, { success: true, alreadyFree: true });

  const snap = await db.collection('subscriptions').doc('freeuser').get();
  assert.equal(snap.data().tier, 'free');
  assert.equal('cancelledAt' in snap.data(), false);
});

test('cancelRecurrenteSubscription downgrades a pro subscription to free and stamps cancelledAt', async () => {
  await db.collection('subscriptions').doc('prouser').set({ tier: 'pro' });

  const result = await cancelSubscription({ auth: { uid: 'prouser' }, data: {} });
  assert.deepEqual(result, { success: true, alreadyFree: false });

  const snap = await db.collection('subscriptions').doc('prouser').get();
  const data = snap.data();
  assert.equal(data.tier, 'free');
  assert.ok(data.cancelledAt, 'expected cancelledAt to be set');
});

test("cancelRecurrenteSubscription only ever touches the caller's own doc", async () => {
  await db.collection('subscriptions').doc('victim').set({ tier: 'pro' });

  const result = await cancelSubscription({ auth: { uid: 'attacker' }, data: {} });
  assert.deepEqual(result, { success: true, alreadyFree: true });

  const snap = await db.collection('subscriptions').doc('victim').get();
  assert.equal(snap.data().tier, 'pro');
});
