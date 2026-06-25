/**
 * EduPlay – Firebase Cloud Functions
 *
 * Functions:
 *  1. createStripeCheckoutSession  – callable; creates a Stripe Checkout
 *     session and returns the URL so the Flutter client can launch it.
 *
 *  2. stripeWebhook                – HTTP; listens for Stripe webhook events
 *     and flips subscriptions/{uid}.tier = 'pro' on checkout.session.completed.
 *
 *  3. onSessionComplete            – Firestore trigger; fires when a
 *     practice_sessions document transitions isActive: true → false and
 *     sends an email to the parent via SendGrid.
 *
 * Environment config (set via Firebase Secret Manager or .env):
 *   STRIPE_SECRET_KEY           – sk_live_… or sk_test_…
 *   STRIPE_WEBHOOK_SECRET       – whsec_… from Stripe dashboard
 *   STRIPE_PRO_PRICE_ID         – price_… for the EduPlay Pro plan
 *   SENDGRID_API_KEY            – SG.…
 *   SENDGRID_FROM_EMAIL         – noreply@yourdomain.com
 *   APP_URL                     – https://your-app.web.app
 */

'use strict';

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onRequest } = require('firebase-functions/v2/https');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// ── Secrets ───────────────────────────────────────────────────────────────────

const STRIPE_SECRET_KEY     = defineSecret('STRIPE_SECRET_KEY');
const STRIPE_WEBHOOK_SECRET = defineSecret('STRIPE_WEBHOOK_SECRET');
const STRIPE_PRO_PRICE_ID   = defineSecret('STRIPE_PRO_PRICE_ID');
const SENDGRID_API_KEY      = defineSecret('SENDGRID_API_KEY');
const SENDGRID_FROM_EMAIL   = defineSecret('SENDGRID_FROM_EMAIL');
const APP_URL               = defineSecret('APP_URL');

// ─────────────────────────────────────────────────────────────────────────────
// 1. createStripeCheckoutSession
// ─────────────────────────────────────────────────────────────────────────────

exports.createStripeCheckoutSession = onCall(
  { secrets: [STRIPE_SECRET_KEY, STRIPE_PRO_PRICE_ID, APP_URL] },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
    }

    const Stripe = require('stripe');
    const stripe = new Stripe(STRIPE_SECRET_KEY.value(), {
      apiVersion: '2024-06-20',
    });

    // Look up or create the Stripe customer
    const subSnap = await db.collection('subscriptions').doc(uid).get();
    let customerId = subSnap.exists ? subSnap.data()?.stripeCustomerId : null;

    if (!customerId) {
      const userSnap = await db.collection('parents').doc(uid).get();
      const email = userSnap.data()?.email ?? '';
      const customer = await stripe.customers.create({
        email,
        metadata: { firebaseUid: uid },
      });
      customerId = customer.id;
      await db.collection('subscriptions').doc(uid).set(
        { stripeCustomerId: customerId },
        { merge: true }
      );
    }

    const appUrl = APP_URL.value() || 'https://localhost:3000';
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [
        {
          price: STRIPE_PRO_PRICE_ID.value(),
          quantity: 1,
        },
      ],
      success_url: `${appUrl}/#/settings?upgrade=success`,
      cancel_url: `${appUrl}/#/settings?upgrade=cancelled`,
      metadata: { firebaseUid: uid },
    });

    return { sessionUrl: session.url };
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// 2. stripeWebhook
// ─────────────────────────────────────────────────────────────────────────────

exports.stripeWebhook = onRequest(
  { secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET] },
  async (req, res) => {
    const Stripe = require('stripe');
    const stripe = new Stripe(STRIPE_SECRET_KEY.value(), {
      apiVersion: '2024-06-20',
    });

    const sig = req.headers['stripe-signature'];
    let event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        STRIPE_WEBHOOK_SECRET.value()
      );
    } catch (err) {
      console.error('Webhook signature verification failed:', err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const uid = session.metadata?.firebaseUid;

      if (uid) {
        await db.collection('subscriptions').doc(uid).set(
          {
            tier: 'pro',
            stripeCustomerId: session.customer,
            stripeSubscriptionId: session.subscription,
            activatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
        console.log(`Upgraded user ${uid} to pro.`);
      }
    }

    if (event.type === 'customer.subscription.deleted') {
      const sub = event.data.object;
      // Find user by customerId
      const snap = await db
        .collection('subscriptions')
        .where('stripeCustomerId', '==', sub.customer)
        .limit(1)
        .get();

      if (!snap.empty) {
        const docRef = snap.docs[0].ref;
        await docRef.set(
          {
            tier: 'free',
            cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
        console.log(`Downgraded user ${snap.docs[0].id} to free.`);
      }
    }

    res.json({ received: true });
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// 3. onSessionComplete – email parent when child finishes a practice session
// ─────────────────────────────────────────────────────────────────────────────

exports.onSessionComplete = onDocumentUpdated(
  {
    document: 'practice_sessions/{sessionId}',
    secrets: [SENDGRID_API_KEY, SENDGRID_FROM_EMAIL, APP_URL],
  },
  async (event) => {
    const before = event.data.before.data();
    const after  = event.data.after.data();

    // Only fire when isActive transitions true → false
    if (before.isActive !== true || after.isActive !== false) return;

    const parentUid = after.parentUid;
    if (!parentUid) return;

    // Check notification preference
    const parentSnap = await db.collection('parents').doc(parentUid).get();
    if (!parentSnap.exists) return;

    const parentData = parentSnap.data();
    const prefs = parentData?.notificationPrefs ?? {};
    if (prefs.emailSessionComplete === false) return;

    const parentEmail = parentData?.email;
    if (!parentEmail) return;

    // Fetch child profile name
    const childId = after.childProfileId;
    let childName = 'tu hijo/a';
    try {
      const childSnap = await db
        .collection('parents')
        .doc(parentUid)
        .collection('child_profiles')
        .doc(childId)
        .get();
      if (childSnap.exists) {
        childName = childSnap.data()?.name ?? childName;
      }
    } catch (_) {}

    // Build score summary
    const scoreMap = after.scoreMap ?? {};
    const gameEntries = Object.entries(scoreMap);
    const avgScore = gameEntries.length > 0
      ? Math.round(
          gameEntries.reduce((sum, [, s]) => sum + s, 0) / gameEntries.length
        )
      : null;

    const scoreText = avgScore !== null
      ? `puntuación promedio: <strong>${avgScore}/100</strong>`
      : 'sesión completada';

    const appUrl = APP_URL.value() || 'https://localhost:3000';

    // Send email via SendGrid
    const sgMail = require('@sendgrid/mail');
    sgMail.setApiKey(SENDGRID_API_KEY.value());

    const msg = {
      to: parentEmail,
      from: SENDGRID_FROM_EMAIL.value(),
      subject: `✅ ${childName} completó una sesión de práctica en EduPlay`,
      html: `
        <div style="font-family: 'Nunito', Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 24px; background: #F8F7FF; border-radius: 16px;">
          <div style="text-align: center; margin-bottom: 24px;">
            <h1 style="font-size: 28px; color: #1E1B6A; margin: 0;">🎉 ¡Sesión completada!</h1>
          </div>
          <p style="color: #374151; font-size: 16px; line-height: 1.6;">
            Hola, <strong>${parentData?.name ?? 'Papá/Mamá'}</strong>.<br><br>
            <strong>${childName}</strong> acaba de terminar una sesión de práctica en EduPlay con ${scoreText}.
          </p>
          <div style="background: #EEEDF8; border-radius: 12px; padding: 16px 20px; margin: 24px 0;">
            <p style="margin: 0; color: #1E1B6A; font-weight: 700; font-size: 14px;">Resumen de la sesión</p>
            <p style="margin: 8px 0 0; color: #6B7280; font-size: 13px;">
              Juegos asignados: <strong>${(after.assignedGameIds ?? []).length}</strong><br>
              ${avgScore !== null ? `Puntuación promedio: <strong>${avgScore}/100</strong>` : ''}
            </p>
          </div>
          <div style="text-align: center; margin-top: 28px;">
            <a href="${appUrl}/#/progress-reports"
               style="display: inline-block; background: #1E1B6A; color: white; text-decoration: none;
                      padding: 14px 28px; border-radius: 12px; font-weight: 700; font-size: 15px;">
              Ver informe completo
            </a>
          </div>
          <p style="color: #9CA3AF; font-size: 12px; text-align: center; margin-top: 32px;">
            Puedes gestionar tus preferencias de notificación en
            <a href="${appUrl}/#/settings" style="color: #1E1B6A;">Configuración → Notificaciones</a>.
          </p>
        </div>
      `,
    };

    try {
      await sgMail.send(msg);
      console.log(`Session-complete email sent to ${parentEmail}.`);
    } catch (err) {
      console.error('SendGrid error:', err.response?.body ?? err.message);
    }
  }
);
