import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { RESOLVED_STATUSES } from "./constants";
import { db as firestoreDb } from "./firebase-admin";
import {
  sendPushToMultipleUsers,
} from "./notifications-helper-functions";
import { resendApiKey, supportFromEmail, supportInboxEmail } from "./secrets";
import { asRecord, stringOrEmpty } from "./stripe-helper-functions";
import {
  getSupportInbox,
  listToText,
  sendSupportMail,
} from "./support-helper-functions";

// ============================================
// Trigger: Support Ticket Written (created → email support inbox,
// resolved → email user)
//
// COST NOTE: Combines the former onSupportTicketCreated and
// onSupportTicketResolved functions, which both fired on
// "support_tickets/{ticketId}", into a single onDocumentWritten trigger.
// ============================================

export const onSupportTicketWritten = onDocumentWritten(
  {
    document: "support_tickets/{ticketId}",
    secrets: [resendApiKey, supportFromEmail, supportInboxEmail],
  },
  async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    if (!afterSnap?.exists) return; // ticket deleted — nothing to do

    const ticketId = event.params.ticketId;

    // ── Created → email support inbox ─────────────────────────────────────
    if (!beforeSnap?.exists) {
      const ticket = afterSnap.data() as Record<string, unknown> | undefined;
      if (!ticket) return;

      const userId =
        typeof ticket.userId === "string" ? ticket.userId : "unknown";
      const userName =
        typeof ticket.userName === "string" ? ticket.userName : "Unknown";
      const userEmail =
        typeof ticket.userEmail === "string" ? ticket.userEmail : "Unknown";
      const category =
        typeof ticket.category === "string" ? ticket.category : "General";
      const subject =
        typeof ticket.subject === "string" ? ticket.subject : "(No subject)";
      const message =
        typeof ticket.message === "string" ? ticket.message : "(No message)";
      const attachmentUrls = Array.isArray(ticket.attachmentUrls)
        ? ticket.attachmentUrls.filter(
          (url): url is string => typeof url === "string",
        )
        : [];
      const metadata = asRecord(ticket.metadata);
      const metadataLines = metadata
        ? Object.entries(metadata).map(
          ([key, value]) => `${key}: ${String(value)}`,
        )
        : [];

      const emailSubject = `[Support Ticket][${category}] ${subject}`;
      const emailBody = [
        "A new support ticket was created in SportConnect.",
        "",
        `Ticket ID: ${ticketId}`,
        `User ID: ${userId}`,
        `User Name: ${userName}`,
        `User Email: ${userEmail}`,
        `Category: ${category}`,
        "",
        "Message:",
        message,
        "",
        "Metadata:",
        listToText(metadataLines),
        "",
        "Attachment URLs:",
        listToText(attachmentUrls),
      ].join("\n");

      await sendSupportMail({
        to: getSupportInbox(),
        subject: emailSubject,
        text: emailBody,
      });
      return;
    }

    // ── Updated → email user when resolved ────────────────────────────────
    const before = beforeSnap.data() as Record<string, unknown> | undefined;
    const after = afterSnap.data() as Record<string, unknown> | undefined;
    if (!after) return;

    const beforeStatus =
      typeof before?.status === "string" ? before.status.toLowerCase() : "";
    const afterStatus =
      typeof after.status === "string" ? after.status.toLowerCase() : "";

    if (beforeStatus === afterStatus || !RESOLVED_STATUSES.has(afterStatus)) {
      return;
    }

    const userEmail =
      typeof after.userEmail === "string" ? after.userEmail.trim() : "";
    if (userEmail.length === 0) {
      logger.warn("Support ticket resolved without userEmail", {
        ticketId,
      });
      return;
    }

    const metadata = asRecord(after.metadata);
    const refundRequestId = stringOrEmpty(metadata?.refundRequestId);
    if (refundRequestId.length > 0) {
      await firestoreDb.collection("refund_requests").doc(refundRequestId).set(
        {
          status: afterStatus,
          supportTicketId: ticketId,
          resolvedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    const subject = `Your SportConnect support ticket (${ticketId}) is resolved`;
    const text = [
      "Hello,",
      "",
      "Your SportConnect support request has been marked as resolved.",
      "If you still need help, please open a new ticket from the app.",
      "",
      `Ticket ID: ${ticketId}`,
      "",
      "SportConnect Support",
    ].join("\n");

    await sendSupportMail({ to: userEmail, subject, text });
  },
);

// ============================================
// Trigger: Report Written (created → email support inbox,
// resolved → email reporter)
//
// COST NOTE: Combines the former onReportCreated and onReportResolved
// functions, which both fired on "reports/{reportId}", into a single
// onDocumentWritten trigger.
// ============================================

export const onReportWritten = onDocumentWritten(
  {
    document: "reports/{reportId}",
    secrets: [resendApiKey, supportFromEmail, supportInboxEmail],
  },
  async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    if (!afterSnap?.exists) return; // report deleted — nothing to do

    const reportId = event.params.reportId;

    // ── Created → email support inbox ─────────────────────────────────────
    if (!beforeSnap?.exists) {
      const report = afterSnap.data() as Record<string, unknown> | undefined;
      if (!report) return;

      const reporterId =
        typeof report.reporterId === "string" ? report.reporterId : "unknown";
      const reporterEmail =
        typeof report.reporterEmail === "string"
          ? report.reporterEmail
          : "Unknown";
      const type = typeof report.type === "string" ? report.type : "Other";
      const severity =
        typeof report.severity === "string" ? report.severity : "medium";
      const description =
        typeof report.description === "string"
          ? report.description
          : "(No description)";
      const rideId = typeof report.rideId === "string" ? report.rideId : "N/A";
      const reportedUserId =
        typeof report.reportedUserId === "string"
          ? report.reportedUserId
          : "N/A";
      const attachmentUrls = Array.isArray(report.attachmentUrls)
        ? report.attachmentUrls.filter(
          (url): url is string => typeof url === "string",
        )
        : [];

      const emailSubject = `[Issue Report][${severity}][${type}] ${reportId}`;
      const emailBody = [
        "A new issue report was created in SportConnect.",
        "",
        `Report ID: ${reportId}`,
        `Reporter ID: ${reporterId}`,
        `Reporter Email: ${reporterEmail}`,
        `Type: ${type}`,
        `Severity: ${severity}`,
        `Ride ID: ${rideId}`,
        `Reported User ID: ${reportedUserId}`,
        "",
        "Description:",
        description,
        "",
        "Attachment URLs:",
        listToText(attachmentUrls),
      ].join("\n");

      await sendSupportMail({
        to: getSupportInbox(),
        subject: emailSubject,
        text: emailBody,
      });
      return;
    }

    // ── Updated → email reporter when resolved ────────────────────────────
    const before = beforeSnap.data() as Record<string, unknown> | undefined;
    const after = afterSnap.data() as Record<string, unknown> | undefined;
    if (!after) return;

    const beforeStatus =
      typeof before?.status === "string" ? before.status.toLowerCase() : "";
    const afterStatus =
      typeof after.status === "string" ? after.status.toLowerCase() : "";

    if (beforeStatus === afterStatus || !RESOLVED_STATUSES.has(afterStatus)) {
      return;
    }

    const reporterEmail =
      typeof after.reporterEmail === "string" ? after.reporterEmail.trim() : "";
    if (reporterEmail.length === 0) {
      logger.warn("Issue report resolved without reporterEmail", {
        reportId,
      });
      return;
    }

    const subject = `Your SportConnect report (${reportId}) is resolved`;
    const text = [
      "Hello,",
      "",
      "Your SportConnect issue report has been reviewed and marked as resolved.",
      "If you need more help, you can submit another report from the app.",
      "",
      `Report ID: ${reportId}`,
      "",
      "SportConnect Support",
    ].join("\n");

    await sendSupportMail({ to: reporterEmail, subject, text });
  },
);

// ============================================
// Trigger: New Chat Message
// ============================================

export const onNewMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const senderId = message.senderId as string;
    const senderName = message.senderName as string;
    const chatId = event.params.chatId;

    // FIX: Do NOT include raw message content in the push payload.
    // Sending real content through FCM exposes it on Google's infrastructure.
    // Use a generic body and let the app fetch the actual message on open.
    const notificationBody = "You have a new message";

    const chatDoc = await firestoreDb.collection("chats").doc(chatId).get();
    const chatData = chatDoc.data();
    if (!chatData) return;

    const participantIds = (chatData.participantIds as string[]) || [];
    const recipients = participantIds.filter((id: string) => id !== senderId);

    if (recipients.length === 0) return;

    // FIX: Use batch multicast instead of N individual calls
    await sendPushToMultipleUsers(recipients, senderName, notificationBody, {
      type: "message",
      referenceId: chatId,
      senderId,
    });
  },
);
