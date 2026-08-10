export const STRIPE_ACCOUNT_COUNTRY = "FR" as const;
export const DEFAULT_CURRENCY = "eur";
export const PLATFORM_FEE_PERCENT = 0.15; // 15%
export const RESOLVED_STATUSES = new Set([
  "resolved",
  "closed",
  "done",
  "completed",
]);
export const OPEN_REFUND_REQUEST_STATUSES = new Set([
  "open",
  "pending",
  "inReview",
  "refunding",
]);
export const REFUND_REQUEST_WINDOW_DAYS = 30;
export const AUTOMATIC_REFUND_REASONS = new Set([
  "cancelledByDriver",
  "driverNoShow",
]);
