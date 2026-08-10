import Stripe from "stripe";

export type StripeClient = Stripe.Stripe;
export type StripeAccount = Awaited<ReturnType<StripeClient["accounts"]["create"]>>;
export type StripeAccountLink = Awaited<
  ReturnType<StripeClient["accountLinks"]["create"]>
>;
export type StripeEvent = ReturnType<StripeClient["webhooks"]["constructEvent"]>;
export type StripePaymentIntent = Awaited<
  ReturnType<StripeClient["paymentIntents"]["retrieve"]>
>;
export type StripeCharge = Awaited<ReturnType<StripeClient["charges"]["retrieve"]>>;
export type StripePayout = Awaited<ReturnType<StripeClient["payouts"]["retrieve"]>>;
export type StripeRefund = Awaited<ReturnType<StripeClient["refunds"]["retrieve"]>>;
export type StripeTransferReversal = Awaited<
  ReturnType<StripeClient["transfers"]["createReversal"]>
>;
export type StripeRefundCreateParams = NonNullable<
  Parameters<StripeClient["refunds"]["create"]>[0]
>;
