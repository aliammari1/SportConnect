import { logger } from "firebase-functions/v2";
import { resendApiKey, supportFromEmail, supportInboxEmail } from "./secrets";

export function listToText(values: string[]): string {
  if (values.length === 0) {
    return "None";
  }
  return values.map((value) => `- ${value}`).join("\n");
}

export function getSupportInbox(): string {
  const inbox = supportInboxEmail.value().trim();
  if (inbox.length > 0) {
    return inbox;
  }
  return supportFromEmail.value().trim();
}

export async function sendSupportMail({
  to,
  subject,
  text,
}: {
  to: string;
  subject: string;
  text: string;
}): Promise<void> {
  const apiKey = resendApiKey.value().trim();
  const from = supportFromEmail.value().trim();

  if (apiKey.length === 0 || from.length === 0) {
    throw new Error("Resend email secrets are not configured");
  }

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to,
      subject,
      text,
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    logger.error("Resend email send failed", {
      status: response.status,
      to,
      subject,
      errorBody,
    });
    throw new Error(`Resend email send failed with status ${response.status}`);
  }
}
