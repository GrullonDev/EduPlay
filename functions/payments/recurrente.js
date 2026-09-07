/**
 * Recurrente checkout integration (Guatemala/LATAM payment gateway).
 *
 * Decoupled from index.js on purpose: everything Recurrente-specific
 * (secrets, API request shape, webhook handling) lives here so it can be
 * reasoned about/rotated independently of the SendGrid/deletion-request
 * functions next door.
 *
 * IMPORTANT — verify before going live: the request body sent to
 * `checkout_custom_links` is a best-effort mapping based on Recurrente's
 * public API description, not a shape verified against a live sandbox call.
 * The `payment_intent.succeeded` webhook payload, on the other hand, IS
 * confirmed against Recurrente's own docs — it's a FLAT top-level object
 * (no Stripe-style `data.object` wrapper), with the event name at
 * `event_type` (not `type`) and the checkout's own status/metadata nested
 * under `checkout: { id, status, metadata }`. Still unverified: whether
 * `checkout.metadata.orderId` actually round-trips exactly as sent to
 * checkout_custom_links (Recurrente's own example payload uses unrelated
 * sample metadata keys) — confirm with one real test-mode checkout before
 * trusting this in production.
 *
 * Test vs live mode: the Flutter client decides (see
 * RecurrenteDatasource — sends `isTest: kDebugMode`), so a debug build hits
 * the sandbox key and a release build hits the live key even though both
 * are active on the same deployed function. No public key is required by
 * this API — only a secret key per mode.
 *
 * Environment config (Firebase Secret Manager or .env):
 *   RECURRENTE_SECRET_KEY_TEST     – sk_test_...
 *   RECURRENTE_SECRET_KEY          – sk_live_...
 *   RECURRENTE_WEBHOOK_SECRET_TEST – signing secret for the test-mode webhook
 *   RECURRENTE_WEBHOOK_SECRET      – signing secret for the live-mode webhook
 *
 * Webhook signature verification: Recurrente's event naming
 * (`payment_intent.succeeded`, flat body) mirrors Stripe's API design, so
 * `isValidSignature` below verifies against the same composite scheme Stripe
 * uses: a `<signature-header>` value shaped as `t=<unix ts>,v1=<hmac>`, where
 * the hmac is HMAC-SHA256(`${t}.${rawBody}`, webhookSecret) — this needs to
 * be confirmed against the "Webhooks" section of the Recurrente dashboard
 * (where the signing secret is issued) before relying on it in production.
 * If the header name or scheme differs, SIGNATURE_HEADER and
 * isValidSignature are the only things that need to change — the rest of
 * the webhook (order lookup, mode selection, accreditation) doesn't.
 */

'use strict';

const crypto = require('crypto');
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

const RECURRENTE_SECRET_KEY_TEST = defineSecret('RECURRENTE_SECRET_KEY_TEST');
const RECURRENTE_SECRET_KEY = defineSecret('RECURRENTE_SECRET_KEY');
const RECURRENTE_WEBHOOK_SECRET_TEST = defineSecret('RECURRENTE_WEBHOOK_SECRET_TEST');
const RECURRENTE_WEBHOOK_SECRET = defineSecret('RECURRENTE_WEBHOOK_SECRET');

const RECURRENTE_API_BASE = 'https://app.recurrente.com/api/v1';

// Confirm this against the Recurrente dashboard's webhook config — see the
// module docstring above. Lowercase because Node normalizes incoming header
// names to lowercase on `req.headers`.
const SIGNATURE_HEADER = 'recurrente-signature';

// Reject events whose timestamp is further than this from "now", to stop a
// captured request from being replayed later.
const MAX_SIGNATURE_AGE_SECONDS = 5 * 60;

/**
 * Verifies a Stripe-style composite signature header (`t=<ts>,v1=<hmac>`)
 * against the raw request body. Fails closed: any missing piece (header,
 * secret, malformed value, stale timestamp, mismatch) returns false.
 */
function isValidSignature(rawBody, signatureHeader, secret) {
  if (!rawBody || !signatureHeader || !secret) return false;

  const parts = {};
  for (const segment of String(signatureHeader).split(',')) {
    const [key, value] = segment.trim().split('=');
    if (key && value) parts[key] = value;
  }

  const timestamp = parts.t;
  const signature = parts.v1;
  if (!timestamp || !signature) return false;

  const ageSeconds = Math.abs(Date.now() / 1000 - Number(timestamp));
  if (!Number.isFinite(ageSeconds) || ageSeconds > MAX_SIGNATURE_AGE_SECONDS) {
    return false;
  }

  const signedPayload = Buffer.concat([
    Buffer.from(`${timestamp}.`, 'utf8'),
    Buffer.isBuffer(rawBody) ? rawBody : Buffer.from(String(rawBody), 'utf8'),
  ]);
  const expected = crypto.createHmac('sha256', secret).update(signedPayload).digest('hex');

  const expectedBuf = Buffer.from(expected, 'utf8');
  const providedBuf = Buffer.from(signature, 'utf8');
  if (expectedBuf.length !== providedBuf.length) return false;
  return crypto.timingSafeEqual(expectedBuf, providedBuf);
}

/**
 * Credits the purchased product/subscription once an order is confirmed
 * PAID. `order.kind` (set by the caller of createRecurrenteCheckout via
 * `metadata.kind`) selects the branch.
 *
 * Only 'subscription' is wired to a concrete Firestore write today — it
 * mirrors the existing stripeWebhook upgrade logic 1:1. Real-money store
 * items currently go through a different, rules-validated client-side path
 * (see isValidStudentPurchaseWrite in firestore.rules / StudentRepository),
 * which this Admin-SDK webhook would bypass rather than reuse — crediting
 * those here needs an explicit target doc decided first, so it's left as a
 * logged no-op until that's defined.
 */
async function accreditOrder(db, orderId, order) {
  const kind = order.kind;

  if (kind === 'subscription' && order.uid) {
    await db.collection('subscriptions').doc(order.uid).set(
      {
        tier: 'pro',
        paymentMethod: 'RECURRENTE',
        activatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    console.log(`[Recurrente] Upgraded ${order.uid} to pro via order ${orderId}.`);
    return;
  }

  console.log(
    `[Recurrente] Order ${orderId} marked PAID (kind=${kind ?? 'unknown'}); ` +
    'no auto-accreditation wired for this kind yet.'
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// createRecurrenteCheckout
// ─────────────────────────────────────────────────────────────────────────────

const createRecurrenteCheckout = onCall(
  { secrets: [RECURRENTE_SECRET_KEY_TEST, RECURRENTE_SECRET_KEY] },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
    }

    const data = request.data ?? {};
    const amount = Number(data.amount);
    const orderId = data.orderId;
    const userEmail = data.userEmail;
    const itemName = data.itemName;
    const currency = data.currency || 'GTQ';
    const metadata = data.metadata && typeof data.metadata === 'object' ? data.metadata : {};
    const isTest = data.isTest === true;
    const mode = isTest ? 'test' : 'live';
    const secretKey = isTest
      ? RECURRENTE_SECRET_KEY_TEST.value()
      : RECURRENTE_SECRET_KEY.value();

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new HttpsError('invalid-argument', 'amount debe ser un número mayor a 0.');
    }
    if (!orderId || typeof orderId !== 'string') {
      throw new HttpsError('invalid-argument', 'orderId es requerido.');
    }
    if (!userEmail || typeof userEmail !== 'string') {
      throw new HttpsError('invalid-argument', 'userEmail es requerido.');
    }
    if (!itemName || typeof itemName !== 'string') {
      throw new HttpsError('invalid-argument', 'itemName es requerido.');
    }

    const db = admin.firestore();
    const amountInCents = Math.round(amount * 100);

    const payload = {
      items: [
        {
          name: itemName,
          amount_in_cents: amountInCents,
          currency,
          quantity: 1,
        },
      ],
      user: { email: userEmail },
      metadata: { orderId, uid, ...metadata },
    };

    let recurrenteResponse;
    try {
      const res = await fetch(`${RECURRENTE_API_BASE}/checkout_custom_links`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-SECRET-KEY': secretKey,
        },
        body: JSON.stringify(payload),
      });

      const bodyText = await res.text();
      if (!res.ok) {
        console.error(`Recurrente checkout_custom_links failed (${res.status}):`, bodyText);
        throw new HttpsError('internal', 'No se pudo crear el checkout de Recurrente.');
      }
      recurrenteResponse = JSON.parse(bodyText);
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      console.error('Recurrente request error:', err);
      throw new HttpsError('internal', 'No se pudo contactar a Recurrente.');
    }

    const checkoutUrl = recurrenteResponse.checkout_url || recurrenteResponse.url;
    const checkoutId = recurrenteResponse.id || recurrenteResponse.checkout_id;

    if (!checkoutUrl || !checkoutId) {
      console.error('Unexpected Recurrente response shape:', recurrenteResponse);
      throw new HttpsError('internal', 'Respuesta de Recurrente sin checkout_url/id.');
    }

    await db.collection('orders').doc(orderId).set(
      {
        uid,
        orderId,
        amount,
        currency,
        itemName,
        userEmail,
        metadata,
        kind: metadata.kind ?? null,
        status: 'PENDING',
        paymentMethod: 'RECURRENTE',
        mode,
        checkoutId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { success: true, checkoutUrl, checkoutId };
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// cancelRecurrenteSubscription
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Downgrades the caller's own subscription from 'pro' back to 'free'.
 *
 * Nothing to cancel on Recurrente's side: `createRecurrenteCheckout` creates
 * a single `checkout_custom_links` payment (see the flow above — one
 * `orders/{orderId}` doc, one payment_intent.succeeded webhook, no recurring
 * billing object). `metadata.kind === 'subscription'` only tells
 * `accreditOrder` which Firestore doc to flip to 'pro' — it is not a
 * Recurrente-managed recurring subscription with its own lifecycle/ID that
 * would need an API call to stop future charges. So "cancelling" today is
 * purely local: flip `subscriptions/{uid}.tier` back to 'free'. If Recurrente
 * recurring billing is adopted later, this is the function to extend with a
 * call to their subscription-cancellation endpoint before the Firestore
 * write.
 *
 * Firestore rules block the client from ever writing `tier` directly (see
 * firestore.rules, `match /subscriptions/{uid}`), so this Admin-SDK callable
 * is the only path — mirroring how `accreditOrder` is the only path to
 * 'pro'.
 */
const cancelRecurrenteSubscription = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
  }

  const db = admin.firestore();
  const subRef = db.collection('subscriptions').doc(uid);
  const snap = await subRef.get();

  if (!snap.exists || snap.data().tier !== 'pro') {
    // Nothing to cancel — idempotent no-op rather than an error, so a
    // retried client call (e.g. after a flaky connection) doesn't surface
    // a scary failure once the first call already succeeded.
    return { success: true, alreadyFree: true };
  }

  await subRef.set(
    {
      tier: 'free',
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  console.log(`[Recurrente] Cancelled pro subscription for ${uid}.`);
  return { success: true, alreadyFree: false };
});

// ─────────────────────────────────────────────────────────────────────────────
// recurrenteWebhook
// ─────────────────────────────────────────────────────────────────────────────

const recurrenteWebhook = onRequest(
  {
    secrets: [
      RECURRENTE_SECRET_KEY_TEST,
      RECURRENTE_SECRET_KEY,
      RECURRENTE_WEBHOOK_SECRET_TEST,
      RECURRENTE_WEBHOOK_SECRET,
    ],
  },
  async (req, res) => {
    // Event confirmed against Recurrente's own payment_intent.succeeded
    // example payload — flat top-level object, event name at `event_type`
    // (not `type`), checkout status/metadata nested under `checkout`:
    //   { event_type: 'payment_intent.succeeded', id: 'pa_...',
    //     checkout: { id: 'ch_...', status: 'paid', metadata: {...} }, ... }
    // This is the only event that should be selected for this webhook
    // endpoint in the Recurrente dashboard.
    const body = req.body ?? {};
    const eventType = body.event_type;
    const checkout = body.checkout ?? {};

    const isPaidEvent =
      eventType === 'payment_intent.succeeded' || checkout.status === 'paid';
    if (!isPaidEvent) {
      return res.status(200).json({ received: true, ignored: true, reason: 'unhandled_event' });
    }

    const orderId = checkout.metadata?.orderId || checkout.metadata?.order_id;
    if (!orderId) {
      console.error('Recurrente webhook: paid event with no order_id in metadata.', body);
      return res.status(400).json({ received: false, error: 'missing order_id' });
    }

    const db = admin.firestore();
    const orderRef = db.collection('orders').doc(orderId);
    const snap = await orderRef.get();
    if (!snap.exists) {
      console.error(`Recurrente webhook: order ${orderId} not found.`);
      return res.status(200).json({ received: true, ignored: true, reason: 'order_not_found' });
    }

    const order = snap.data();

    const webhookSecret =
      order.mode === 'test'
        ? RECURRENTE_WEBHOOK_SECRET_TEST.value()
        : RECURRENTE_WEBHOOK_SECRET.value();
    const signatureHeader = req.headers[SIGNATURE_HEADER];

    if (!isValidSignature(req.rawBody, signatureHeader, webhookSecret)) {
      console.error(
        `Recurrente webhook: invalid or missing signature for order ${orderId} ` +
        `(mode=${order.mode ?? 'unknown'}).`
      );
      return res.status(401).json({ received: false, error: 'invalid signature' });
    }

    if (order.status === 'PAID') {
      // Already processed (webhook retry) — acknowledge without re-crediting.
      return res.status(200).json({ received: true, alreadyPaid: true });
    }

    await orderRef.update({
      status: 'PAID',
      paymentMethod: 'RECURRENTE',
      transactionId: body.id ?? checkout.id ?? order.checkoutId ?? null,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    try {
      await accreditOrder(db, orderId, order);
    } catch (err) {
      console.error(`accreditOrder failed for order ${orderId}:`, err);
    }

    res.status(200).json({ received: true });
  }
);

module.exports = {
  createRecurrenteCheckout,
  cancelRecurrenteSubscription,
  recurrenteWebhook,
};
