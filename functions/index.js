/**
 * EduPlay – Firebase Cloud Functions
 *
 * Functions:
 *  1. onSessionComplete            – ON HOLD, commented out below in the
 *     "onSessionComplete (on hold)" section. Firestore trigger; would fire
 *     when a practice_sessions document transitions isActive: true → false
 *     and send an email to the parent via SendGrid.
 *
 *  2. onDeletionRequestCreated     – Firestore trigger; fires when an
 *     independent student (who has a guardian email on file) requests
 *     account deletion. Emails the guardian an approve/deny link — the
 *     student's own account is never deleted unless they click approve.
 *
 *  3. resolveDeletion              – HTTP; the approve/deny link target.
 *     Runs with the Admin SDK (bypasses Firestore rules on purpose — this
 *     is the ONE place a deletion_requests doc may ever be resolved) and,
 *     on approve, performs the actual account/data deletion.
 *
 *  4. createRecurrenteCheckout     – Callable; see payments/recurrente.js.
 *     Creates a Recurrente checkout link and a matching orders/{orderId}
 *     doc in Firestore (status PENDING).
 *
 *  5. recurrenteWebhook            – HTTP; see payments/recurrente.js.
 *     Recurrente's payment-confirmation callback. Marks the order PAID and
 *     credits the purchase (subscription upgrade today; store items are a
 *     documented no-op pending a target write, see accreditOrder()).
 *
 *  6. cancelRecurrenteSubscription – Callable; see payments/recurrente.js.
 *     Downgrades the caller's own subscriptions/{uid} from 'pro' back to
 *     'free'. Purely a local Firestore flip — Recurrente checkouts here are
 *     one-off payments, not a Recurrente-managed recurring subscription, so
 *     there is nothing to cancel on their side (see the function's own
 *     docstring for the full reasoning).
 *
 *  7. lookupClassByJoinCode        – Callable; see classes.js. Looks up a
 *     teacher class by its join code via the Admin SDK, so the client no
 *     longer needs broad read access to classes/{classId} to do this.
 *
 *  8. joinClassByCode              – Callable; see classes.js. Re-validates
 *     the code server-side and performs the same join transaction the
 *     client used to run directly (member doc + studentCount increment).
 *
 *  9. generateUniqueJoinCode       – Callable; see classes.js. Scans across
 *     all classes (not just the caller's own) for a join-code collision —
 *     needed once classes/{classId} read is tightened, since the client can
 *     otherwise only see its own classes.
 *
 * Environment config (set via Firebase Secret Manager or .env):
 *   SENDGRID_API_KEY            – SG.…
 *   SENDGRID_FROM_EMAIL         – noreply@yourdomain.com
 *   APP_URL                     – https://your-app.web.app
 *   RECURRENTE_SECRET_KEY_TEST     – sk_test_…
 *   RECURRENTE_SECRET_KEY          – sk_live_…
 *   RECURRENTE_WEBHOOK_SECRET_TEST – webhook signing secret, test mode
 *   RECURRENTE_WEBHOOK_SECRET      – webhook signing secret, live mode
 */

'use strict';

const { onRequest } = require('firebase-functions/v2/https');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

const {
  createRecurrenteCheckout,
  cancelRecurrenteSubscription,
  recurrenteWebhook,
} = require('./payments/recurrente');

const {
  lookupClassByJoinCode,
  joinClassByCode,
  generateUniqueJoinCode,
} = require('./classes');

// ── Secrets ───────────────────────────────────────────────────────────────────
// SendGrid is active but only for onDeletionRequestCreated (guardian-consent
// emails) — onSessionComplete stays disabled in its own "on hold" section
// further down.
const SENDGRID_API_KEY    = defineSecret('SENDGRID_API_KEY');
const SENDGRID_FROM_EMAIL = defineSecret('SENDGRID_FROM_EMAIL');
const APP_URL             = defineSecret('APP_URL');

/* ── onSessionComplete (on hold) ─────────────────────────────────────────────
 * Not being turned on yet. Kept here, disabled, rather than deleted. To
 * re-enable: delete this opening "/*" and the matching closing "*\/" below.

// ─────────────────────────────────────────────────────────────────────────────
// 1. onSessionComplete – email parent when child finishes a practice session
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

*/ // ── end onSessionComplete (on hold) ─────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// 2. onDeletionRequestCreated – email the guardian an approve/deny link
// ─────────────────────────────────────────────────────────────────────────────

exports.onDeletionRequestCreated = onDocumentCreated(
  {
    document: 'deletion_requests/{requestId}',
    secrets: [SENDGRID_API_KEY, SENDGRID_FROM_EMAIL, APP_URL],
  },
  async (event) => {
    const data = event.data.data();
    const requestId = event.params.requestId;

    const guardianEmail = data.guardianEmail;
    const token = data.token;
    if (!guardianEmail || !token) return;

    const studentName = data.studentName || 'tu hijo/a';
    const appUrl = APP_URL.value() || 'https://localhost:3000';
    // Points at the resolveDeletion HTTP function directly (not the app) —
    // the guardian never needs an EduPlay account to act on this.
    const region = 'us-central1';
    const projectId = process.env.GCLOUD_PROJECT;
    const fnBase = `https://${region}-${projectId}.cloudfunctions.net/resolveDeletion`;
    const approveUrl = `${fnBase}?id=${requestId}&token=${token}&action=approve`;
    const denyUrl = `${fnBase}?id=${requestId}&token=${token}&action=deny`;

    const sgMail = require('@sendgrid/mail');
    sgMail.setApiKey(SENDGRID_API_KEY.value());

    const msg = {
      to: guardianEmail,
      from: SENDGRID_FROM_EMAIL.value(),
      subject: `Solicitud para eliminar la cuenta de ${studentName} en EduPlay`,
      html: `
        <div style="font-family: 'Nunito', Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 24px; background: #F8F7FF; border-radius: 16px;">
          <div style="text-align: center; margin-bottom: 24px;">
            <h1 style="font-size: 24px; color: #1E1B6A; margin: 0;">Solicitud de eliminación de cuenta</h1>
          </div>
          <p style="color: #374151; font-size: 15px; line-height: 1.6;">
            <strong>${studentName}</strong> solicitó eliminar permanentemente su cuenta de EduPlay,
            incluyendo su progreso, puntos y racha. Como dejó tu correo registrado como tutor,
            necesitamos tu aprobación antes de eliminar nada.
          </p>
          <p style="color: #374151; font-size: 15px; line-height: 1.6;">
            Si no respondes, la cuenta permanece activa y no se elimina ningún dato.
          </p>
          <div style="text-align: center; margin: 28px 0;">
            <a href="${approveUrl}"
               style="display: inline-block; background: #C0392B; color: white; text-decoration: none;
                      padding: 14px 24px; border-radius: 12px; font-weight: 700; font-size: 14px; margin: 0 8px;">
              Aprobar eliminación
            </a>
            <a href="${denyUrl}"
               style="display: inline-block; background: #1E1B6A; color: white; text-decoration: none;
                      padding: 14px 24px; border-radius: 12px; font-weight: 700; font-size: 14px; margin: 0 8px;">
              No, mantener la cuenta
            </a>
          </div>
          <p style="color: #9CA3AF; font-size: 12px; text-align: center; margin-top: 32px;">
            EduPlay · ${appUrl}
          </p>
        </div>
      `,
    };

    try {
      await sgMail.send(msg);
      console.log(`Deletion-consent email sent to ${guardianEmail} for request ${requestId}.`);
    } catch (err) {
      console.error('SendGrid error:', err.response?.body ?? err.message);
    }
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// 3. resolveDeletion – approve/deny link target; performs the actual deletion
// ─────────────────────────────────────────────────────────────────────────────

exports.resolveDeletion = onRequest(async (req, res) => {
  const { id, token, action } = req.query;

  const htmlPage = (title, body) => `
    <!DOCTYPE html>
    <html lang="es"><head><meta charset="utf-8"><title>${title}</title></head>
    <body style="font-family: Arial, sans-serif; max-width: 480px; margin: 60px auto; text-align: center; color: #1E1B6A;">
      <h2>${title}</h2>
      <p>${body}</p>
    </body></html>
  `;

  if (!id || !token || !['approve', 'deny'].includes(action)) {
    return res.status(400).send(htmlPage('Enlace inválido', 'Este enlace no es válido.'));
  }

  const requestRef = db.collection('deletion_requests').doc(id);
  const snap = await requestRef.get();
  if (!snap.exists) {
    return res.status(404).send(htmlPage('Solicitud no encontrada', 'Es posible que ya haya sido resuelta.'));
  }

  const data = snap.data();
  if (data.status !== 'pending') {
    return res.status(200).send(
      htmlPage('Ya resuelto', `Esta solicitud ya fue ${data.status === 'approved' ? 'aprobada' : 'rechazada'} anteriormente.`)
    );
  }
  if (data.token !== token) {
    return res.status(403).send(htmlPage('Enlace inválido', 'Este enlace no coincide con la solicitud.'));
  }

  if (action === 'deny') {
    await requestRef.update({
      status: 'denied',
      decidedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.status(200).send(
      htmlPage('Cuenta conservada', 'Gracias — la cuenta y todos sus datos siguen activos, no se eliminó nada.')
    );
  }

  // action === 'approve': delete everything belonging to this student.
  const uid = data.uid;
  try {
    const profilesSnap = await db
      .collection('parents')
      .doc(uid)
      .collection('child_profiles')
      .get();

    for (const doc of profilesSnap.docs) {
      const pin = doc.data().pin;
      if (pin) {
        await db.collection('child_pins').doc(pin).delete().catch(() => {});
      }
      const studentDoc = db.collection('students').doc(doc.id);
      const scoresSnap = await studentDoc.collection('scores').get();
      for (const scoreDoc of scoresSnap.docs) {
        await scoreDoc.ref.delete();
      }
      await studentDoc.delete().catch(() => {});
      await doc.ref.delete();
    }

    await db.collection('parents').doc(uid).delete().catch(() => {});
    await db.collection('independent_students').doc(uid).delete().catch(() => {});
    await db.collection('subscriptions').doc(uid).delete().catch(() => {});
    await admin.auth().deleteUser(uid).catch((err) => {
      console.error(`Failed to delete auth user ${uid}:`, err.message);
    });

    await requestRef.update({
      status: 'approved',
      decidedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(200).send(
      htmlPage('Cuenta eliminada', 'La cuenta y todos sus datos se eliminaron permanentemente. Gracias.')
    );
  } catch (err) {
    console.error(`resolveDeletion approve failed for ${uid}:`, err);
    return res.status(500).send(htmlPage('Error', 'No pudimos completar la eliminación. Intenta de nuevo más tarde.'));
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// 4-6. Recurrente payments (createRecurrenteCheckout,
//      cancelRecurrenteSubscription, recurrenteWebhook)
// ─────────────────────────────────────────────────────────────────────────────

exports.createRecurrenteCheckout = createRecurrenteCheckout;
exports.cancelRecurrenteSubscription = cancelRecurrenteSubscription;
exports.recurrenteWebhook = recurrenteWebhook;

// ─────────────────────────────────────────────────────────────────────────────
// 7-9. Teacher-class join-by-code (lookupClassByJoinCode, joinClassByCode,
//      generateUniqueJoinCode)
// ─────────────────────────────────────────────────────────────────────────────

exports.lookupClassByJoinCode = lookupClassByJoinCode;
exports.joinClassByCode = joinClassByCode;
exports.generateUniqueJoinCode = generateUniqueJoinCode;
