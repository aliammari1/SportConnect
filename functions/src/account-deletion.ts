import { FieldValue } from "firebase-admin/firestore";
import * as functionsV1 from "firebase-functions/v1";
import { logger } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";
import { db as firestoreDb, storage } from "./firebase-admin";
import {
  resendApiKey,
  stripeSecretKey,
  supportFromEmail,
  supportInboxEmail,
} from "./secrets";
import {
  anonymizeReviewsForDeletedUser,
  cleanupEventParticipationForDeletedUser,
  cleanupNotificationsForDeletedUser,
  cleanupStripeForDeletedUser,
  cleanupVehiclesForDeletedUser,
  getStripeClient,
} from "./stripe-helper-functions";
import { StripeClient } from "./types";
// ── Account Deletion Request (Web page → RGPD Art.17 / Apple 5.1.1) ────────
//
// Called by the public delete-account.html page. Records the request in
// Firestore and sends a confirmation e-mail so the user has written proof
// that we received it. The actual account + data deletion is performed by
// a human or a scheduled function within 30 days.
export const requestAccountDeletion = onRequest(
  {
    secrets: [resendApiKey, supportFromEmail, supportInboxEmail],
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const { email, reason, comments, requestedAt, source } = req.body as {
      email?: string;
      reason?: string;
      comments?: string;
      requestedAt?: string;
      source?: string;
    };

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      res.status(400).json({ error: "A valid e-mail address is required." });
      return;
    }

    const db = firestoreDb;

    // Record the deletion request so the ops team can act on it.
    const docRef = await db.collection("deletion_requests").add({
      email: email.trim().toLowerCase(),
      reason: reason ?? null,
      comments: comments ?? null,
      requestedAt: requestedAt ?? new Date().toISOString(),
      source: source ?? "web",
      status: "pending",
      createdAt: FieldValue.serverTimestamp(),
    });

    logger.info(`Deletion request recorded: ${docRef.id} for ${email}`);

    // Send confirmation e-mail to the requester via Resend.
    try {
      const fromAddr = supportFromEmail.value();
      const inboxAddr = supportInboxEmail.value();
      const apiKey = resendApiKey.value();

      const confirmationHtml = `
        <p>Bonjour,</p>
        <p>Nous avons bien reçu votre demande de suppression de compte SportConnect pour l'adresse <strong>${email}</strong>.</p>
        <p>Votre demande sera traitée dans un délai de <strong>30 jours</strong> conformément à l'article 17 du RGPD.
        Vous recevrez un e-mail de confirmation une fois la suppression effectuée.</p>
        <p>Référence de votre demande : <code>${docRef.id}</code></p>
        <p>Si vous n'avez pas effectué cette demande, ignorez cet e-mail ou contactez-nous à
        <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.</p>
        <p>— L'équipe SportConnect</p>
      `;

      // Notify the requester
      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          from: fromAddr,
          to: [email.trim()],
          subject: "Demande de suppression de compte reçue - SportConnect",
          html: confirmationHtml,
        }),
      });

      // Notify the support inbox so a human can act on it
      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          from: fromAddr,
          to: [inboxAddr],
          subject: `[Suppression de compte] ${email}`,
          html: `
            <p><strong>Nouvelle demande de suppression de compte</strong></p>
            <p>E-mail : ${email}</p>
            <p>Motif : ${reason ?? "non précisé"}</p>
            <p>Commentaires : ${comments ?? "aucun"}</p>
            <p>Référence Firestore : ${docRef.id}</p>
            <p>Date : ${requestedAt ?? new Date().toISOString()}</p>
          `,
        }),
      });
    } catch (emailErr) {
      // E-mail failure is non-fatal — the request is already recorded in Firestore.
      logger.warn("Deletion confirmation e-mail failed (non-fatal):", emailErr);
    }

    res.status(200).json({ success: true, requestId: docRef.id });
  },
);

export const onAuthUserDeleted = functionsV1
  .runWith({ secrets: [stripeSecretKey] })
  .auth.user()
  .onDelete(async (user) => {
    const uid = user.uid;

    let stripe: StripeClient | undefined;
    try {
      stripe = getStripeClient(stripeSecretKey.value().trim());
    } catch (err) {
      logger.error(
        "cascade cleanup: failed to load Stripe client — skipping Stripe cleanup only",
        { uid, error: err },
      );
    }

    // Run every sub-task in parallel: each is independent, catches its own
    // errors internally, and never throws — so one failing does not stop the
    // others from completing.
    await Promise.all([
      stripe
        ? cleanupStripeForDeletedUser(firestoreDb, stripe, uid)
        : Promise.resolve(),
      cleanupVehiclesForDeletedUser(firestoreDb, storage, uid),
      cleanupNotificationsForDeletedUser(firestoreDb, uid),
      cleanupEventParticipationForDeletedUser(firestoreDb, uid),
      anonymizeReviewsForDeletedUser(firestoreDb, uid),
    ]);

    logger.info("onAuthUserDeleted: cascade cleanup finished", { uid });
  });
