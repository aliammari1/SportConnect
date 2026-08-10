import { defineSecret } from "firebase-functions/params";

export const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
export const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
export const resendApiKey = defineSecret("RESEND_API_KEY");
export const supportFromEmail = defineSecret("SUPPORT_FROM_EMAIL");
export const supportInboxEmail = defineSecret("SUPPORT_INBOX_EMAIL");
