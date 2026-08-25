import { DocumentData, FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  AUTOMATIC_REFUND_REASONS,
  DEFAULT_CURRENCY,
  OPEN_REFUND_REQUEST_STATUSES,
  REFUND_REQUEST_WINDOW_DAYS,
  STRIPE_ACCOUNT_COUNTRY,
} from "./constants";
import { calculateFees } from "./payment-helper-functions";
import { checkRateLimit } from "./rate-limit";
import {
  createStripeRefundForPayment,
  findPaymentDocsByPaymentIntent,
  findPaymentDocsForRefundRequest,
  isRefundOperator,
  isRideObjectivelyRefundable,
  isWithinRefundRequestWindow,
  paymentAmountInCents,
  refundedAmountInCents,
} from "./refund-helper-functions";
import {
  getDriverPayoutEligibilitySnapshot,
  getRidePricePerSeatInCents,
} from "./ride-helper-functions";
import { stripeSecretKey } from "./secrets";
import {
  asRecord,
  finiteNumber,
  getStripeClient,
  mapStripeCapabilityStatus,
  recomputeDriverStats,
  stringOrEmpty,
  stripeObjectId,
  sumBalanceForCurrency,
  syncConnectedAccountSnapshot,
} from "./stripe-helper-functions";
import { db as firestoreDb } from "./firebase-admin";
import {
  StripeAccount,
  StripeAccountLink,
  StripeRefund,
  StripeRefundCreateParams,
} from "./types";
// ============================================
// Stripe: Create Connected Account
// ============================================

export const createConnectedAccount = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    logger.info("createConnectedAccount called", {
      userId: request.data?.userId,
      authUid: request.auth?.uid,
    });

    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 3 account creations per user per hour.
    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "createConnectedAccount",
      3,
      3600,
    );

    const { userId, email } = request.data;
    logger.info("Parsed - userId:", userId, "email:", email);

    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required");
    }

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripeCountry = STRIPE_ACCOUNT_COUNTRY;

    let stripeApiKey: string;
    try {
      stripeApiKey = stripeSecretKey.value().trim();
      logger.info("Stripe API key loaded successfully");
    } catch (err) {
      logger.error("Error getting Stripe secret:", err);
      throw new HttpsError("internal", "Failed to load Stripe API key");
    }

    const stripe = getStripeClient(stripeApiKey);

    const [userDoc, connectedAccountDoc] = await Promise.all([
      firestoreDb.collection("users").doc(userId).get(),
      firestoreDb.collection("driver_connected_accounts").doc(userId).get(),
    ]);
    const userData = userDoc.data();
    const connectedAccountData = connectedAccountDoc.data();

    if (!userData) {
      throw new HttpsError("not-found", "User not found in database");
    }

    if (userData.role !== "driver") {
      throw new HttpsError(
        "failed-precondition",
        "User is not registered as a driver",
      );
    }

    let accountId =
      typeof connectedAccountData?.stripeAccountId === "string" &&
        connectedAccountData.stripeAccountId.trim().length > 0
        ? connectedAccountData.stripeAccountId
        : userData.stripeAccountId;
    let accountDefaultCurrency = DEFAULT_CURRENCY;
    logger.info(
      "User data - role:",
      userData.role,
      "stripeAccountId:",
      accountId,
    );

    if (accountId) {
      logger.info("Found existing stripeAccountId:", accountId);
      try {
        const existingAccount = await stripe.accounts.retrieve(accountId);
        await syncConnectedAccountSnapshot(firestoreDb, stripe, existingAccount, userId);
        accountDefaultCurrency =
          existingAccount.default_currency ?? accountDefaultCurrency;
        logger.info("Existing Stripe account found:", existingAccount.id);
      } catch (error) {
        logger.info(
          "Existing Stripe account not valid, creating new one:",
          error,
        );
        accountId = null;
        await firestoreDb.collection("users").doc(userId).update({
          stripeAccountId: FieldValue.delete(),
          stripeAccountStatus: FieldValue.delete(),
          chargesEnabled: FieldValue.delete(),
          payoutsEnabled: FieldValue.delete(),
          detailsSubmitted: FieldValue.delete(),
        });
      }
    }

    if (!accountId) {
      logger.info("Creating new Stripe Connect account for:", email);

      let createdAccount: StripeAccount;
      try {
        createdAccount = await stripe.accounts.create(
          {
            type: "express",
            country: stripeCountry,
            email,
            capabilities: {
              card_payments: { requested: true },
              transfers: { requested: true },
            },
            business_type: "individual",
            business_profile: {
              mcc: "4121",
              product_description:
                "Carpooling driver on SportConnect - providing shared ride services to passengers for cost-sharing commutes and sports events",
            },
            metadata: { userId, userType: "driver" },
          },
          // Deterministic idempotency key keyed on the driver: a retry or a
          // concurrent invocation (rate limit allows 3/hour) returns the SAME
          // Express account instead of creating a duplicate orphaned account.
          { idempotencyKey: `connect_acct_${userId}` },
        );
      } catch (stripeError: unknown) {
        const e = stripeError as {
          message?: string;
          type?: string;
          code?: string;
        };
        logger.error("stripe.accounts.create failed", {
          error: e.message,
          type: e.type,
          code: e.code,
          userId,
        });
        throw new HttpsError(
          "internal",
          `Stripe account creation failed: ${e.message ?? "unknown error"}`,
        );
      }

      accountId = createdAccount.id;
      accountDefaultCurrency =
        createdAccount.default_currency ?? accountDefaultCurrency;
      logger.info("New Stripe account created:", accountId);

      await syncConnectedAccountSnapshot(firestoreDb, stripe, createdAccount, userId);
    }

    const baseUrl = "https://sportaxitrip.com";

    let accountLink: StripeAccountLink;
    try {
      accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: `${baseUrl}/stripe-refresh.html?userId=${userId}`,
        return_url: `${baseUrl}/stripe-return.html?userId=${userId}`,
        type: "account_onboarding",
      });
    } catch (stripeError: unknown) {
      const e = stripeError as { message?: string };
      logger.error("stripe.accountLinks.create failed", {
        error: e.message,
        accountId,
        userId,
      });
      throw new HttpsError(
        "internal",
        `Failed to generate Stripe onboarding link: ${e.message ?? "unknown error"}`,
      );
    }

    return {
      accountId,
      onboardingUrl: accountLink.url,
      defaultCurrency: accountDefaultCurrency.toUpperCase(),
    };
  },
);

// ============================================
// Stripe: Create Account Link (re-onboarding)
// ============================================

export const createAccountLink = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const uid = request.auth.uid;
    const stripe = getStripeClient(stripeSecretKey.value().trim());

    const connectedAccountDoc = await firestoreDb
      .collection("driver_connected_accounts")
      .doc(uid)
      .get();

    const accountId = connectedAccountDoc.data()?.stripeAccountId;

    if (typeof accountId !== "string" || accountId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "No Stripe connected account found for this user.",
      );
    }

    const baseUrl = "https://sportaxitrip.com";

    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `${baseUrl}/stripe-refresh.html?userId=${uid}`,
      return_url: `${baseUrl}/stripe-return.html?userId=${uid}`,
      type: "account_onboarding",
    });

    return { url: accountLink.url };
  },
);

// ============================================
// Stripe: Get Account Status
// ============================================

export const getAccountStatus = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { accountId } = request.data;

    if (!accountId) {
      throw new HttpsError("invalid-argument", "accountId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;

    try {
      const uid = request.auth.uid;
      const [callerDoc, connectedAccountDoc] = await Promise.all([
        db.collection("users").doc(uid).get(),
        db.collection("driver_connected_accounts").doc(uid).get(),
      ]);
      const callerAccountId = callerDoc.data()?.stripeAccountId;
      const connectedAccountId = connectedAccountDoc.data()?.stripeAccountId;
      const authorizedAccountIds = new Set(
        [callerAccountId, connectedAccountId].filter(
          (id): id is string => typeof id === "string" && id.length > 0,
        ),
      );

      if (
        authorizedAccountIds.size > 0 &&
        !authorizedAccountIds.has(accountId)
      ) {
        throw new HttpsError(
          "permission-denied",
          "You are not authorized to access this Stripe account",
        );
      }

      const account = await stripe.accounts.retrieve(accountId);
      if (authorizedAccountIds.size === 0 && account.metadata?.userId !== uid) {
        throw new HttpsError(
          "permission-denied",
          "You are not authorized to access this Stripe account",
        );
      }

      const defaultCurrency = (account.default_currency ?? "eur").toLowerCase();

      // Fetch balance for this connected account. Stripe balance amounts are
      // already in minor units, so keep cents canonical and expose legacy major
      // unit fields only for old app versions.
      let availableBalanceInCents = 0;
      let pendingBalanceInCents = 0;

      try {
        const balance = await stripe.balance.retrieve(
          {},
          {
            stripeAccount: accountId,
          },
        );
        logger.info("Stripe balance retrieved", {
          accountId,
          availableCount: balance.available?.length,
          pendingCount: balance.pending?.length,
          rawAvailable: JSON.stringify(balance.available),
          rawPending: JSON.stringify(balance.pending),
        });

        // Instant payouts draw from instant_available, not available.
        // available only fills after the standard settlement window (T+2) —
        // which never auto-advances in test mode without a test clock.
        const instantAvailableField = ((balance as any).instant_available ??
          balance.available) as typeof balance.available;

        availableBalanceInCents = sumBalanceForCurrency(
          instantAvailableField,
          defaultCurrency,
        );
        // "Processing" = pending minus what's already instantly withdrawable.
        // This matches how Uber/Lyft display balances: available + processing
        // never double-counts instant_available.
        pendingBalanceInCents = Math.max(
          0,
          sumBalanceForCurrency(balance.pending, defaultCurrency) -
          availableBalanceInCents,
        );
        logger.info("Calculated balances", {
          availableBalanceInCents,
          pendingBalanceInCents,
          defaultCurrency,
        });
      } catch (balanceError) {
        logger.warn("Could not fetch balance for account", {
          accountId,
          error: balanceError,
        });
      }

      await syncConnectedAccountSnapshot(db, stripe, account, uid, {
        availableBalanceInCents,
        pendingBalanceInCents,
      });

      return {
        chargesEnabled: account.charges_enabled ?? false,
        payoutsEnabled: account.payouts_enabled ?? false,
        detailsSubmitted: account.details_submitted ?? false,
        requirements: account.requirements?.currently_due ?? [],
        disabledReason: account.requirements?.disabled_reason ?? null,
        capabilities: {
          transfers: mapStripeCapabilityStatus(account.capabilities?.transfers),
          cardPayments: mapStripeCapabilityStatus(
            account.capabilities?.card_payments,
          ),
        },
        availableBalance: availableBalanceInCents / 100,
        pendingBalance: pendingBalanceInCents / 100,
        availableBalanceInCents,
        pendingBalanceInCents,
        currency: defaultCurrency.toUpperCase(),
      };
    } catch (error: unknown) {
      if (error instanceof HttpsError) {
        throw error;
      }
      // FIX: Use typed error handling instead of `any`
      const e = error as { message?: string };
      logger.error("getAccountStatus failed", { accountId, error: e.message });
      throw new HttpsError(
        "not-found",
        `Stripe account not found: ${e.message ?? "unknown error"}`,
      );
    }
  },
);

// ============================================
// Stripe: Driver Payout Eligibility
// ============================================

export const getDriverPayoutEligibility = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "getDriverPayoutEligibility",
      20,
      60,
    );

    const db = firestoreDb;
    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const requestedStripeAccountId =
      typeof request.data?.stripeAccountId === "string"
        ? request.data.stripeAccountId.trim()
        : "";
    const normalizedCurrency =
      typeof request.data?.currency === "string" &&
        request.data.currency.trim().length > 0
        ? request.data.currency.trim().toLowerCase()
        : DEFAULT_CURRENCY;

    const [callerDoc, connectedAccountDoc] = await Promise.all([
      db.collection("users").doc(request.auth.uid).get(),
      db.collection("driver_connected_accounts").doc(request.auth.uid).get(),
    ]);
    const callerData = callerDoc.data();
    const connectedAccountData = connectedAccountDoc.data();
    const callerStripeAccountId =
      typeof callerData?.stripeAccountId === "string"
        ? callerData.stripeAccountId
        : "";
    const connectedStripeAccountId =
      typeof connectedAccountData?.stripeAccountId === "string"
        ? connectedAccountData.stripeAccountId
        : "";
    const stripeAccountId =
      requestedStripeAccountId ||
      connectedStripeAccountId ||
      callerStripeAccountId;

    if (!callerData || !stripeAccountId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver must complete Stripe onboarding before payouts are available",
      );
    }

    if (
      stripeAccountId !== callerStripeAccountId &&
      stripeAccountId !== connectedStripeAccountId
    ) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorized to inspect payouts for this account",
      );
    }

    const eligibility = await getDriverPayoutEligibilitySnapshot(db, stripe, {
      driverId: request.auth.uid,
      stripeAccountId,
      currency: normalizedCurrency,
    });

    try {
      await recomputeDriverStats(db, request.auth.uid);
    } catch (error) {
      logger.warn("getDriverPayoutEligibility: stats recompute failed", {
        driverId: request.auth.uid,
        error,
      });
    }

    return eligibility;
  },
);

// ============================================
// Stripe: Create Instant Payout
// ============================================

export const createInstantPayout = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 5 instant payouts per user per hour
    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "createInstantPayout",
      5,
      3600,
    );

    const {
      stripeAccountId,
      amountInCents: requestedAmountInCents,
      amount: legacyAmount,
      currency = "eur",
    } = request.data;
    const normalizedCurrency =
      typeof currency === "string" && currency.trim().length > 0
        ? currency.trim().toLowerCase()
        : "eur";
    const payoutAmountInCents =
      finiteNumber(requestedAmountInCents) !== undefined
        ? Math.round(finiteNumber(requestedAmountInCents)!)
        : finiteNumber(legacyAmount) !== undefined
          ? Math.round(finiteNumber(legacyAmount)!)
          : undefined;

    if (!stripeAccountId || !payoutAmountInCents || payoutAmountInCents <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "stripeAccountId and a positive amountInCents are required",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;

    const [callerDoc, connectedAccountDoc] = await Promise.all([
      db.collection("users").doc(request.auth.uid).get(),
      db.collection("driver_connected_accounts").doc(request.auth.uid).get(),
    ]);
    const callerData = callerDoc.data();
    const connectedAccountData = connectedAccountDoc.data();
    const callerStripeAccountId = callerData?.stripeAccountId;
    const connectedStripeAccountId = connectedAccountData?.stripeAccountId;
    if (
      !callerData ||
      (callerStripeAccountId !== stripeAccountId &&
        connectedStripeAccountId !== stripeAccountId)
    ) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorized to create payouts for this account",
      );
    }

    const account = await stripe.accounts
      .retrieve(stripeAccountId, {
        expand: ["external_accounts"],
      })
      .catch((error: unknown) => {
        const e = error as { message?: string };
        logger.error("createInstantPayout: account verification failed", {
          stripeAccountId,
          uid: request.auth?.uid,
          error: e.message,
        });
        throw new HttpsError(
          "not-found",
          `Stripe account verification failed: ${e.message ?? "unknown error"}`,
        );
      });

    if (!account.payouts_enabled) {
      throw new HttpsError(
        "failed-precondition",
        "Payouts are not enabled for this account",
      );
    }

    const externalAccounts = account.external_accounts?.data ?? [];
    if (externalAccounts.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "No payout destination is attached to this Stripe account",
      );
    }

    // Verify at least one external account supports instant payouts.
    // Bank accounts (IBAN) only have available_payout_methods: ["standard"].
    // Eligible debit cards have: ["standard", "instant"].
    // For FR/EUR test mode use card 4000052500000008 (not the US 4000056655665556).
    const instantEligibleAccount = externalAccounts.find(
      (ea) =>
        (
          ea as unknown as { available_payout_methods?: string[] }
        ).available_payout_methods?.includes("instant") === true,
    );
    if (!instantEligibleAccount) {
      throw new HttpsError(
        "failed-precondition",
        "No external account eligible for instant payouts. Add a debit card to enable instant payouts.",
      );
    }

    const balance = await stripe.balance.retrieve(
      {},
      { stripeAccount: stripeAccountId },
    );

    // Instant payouts draw from instant_available, not available.
    const instantAvailableField = ((balance as any).instant_available ??
      balance.available) as typeof balance.available;

    const availableBalanceInCents = sumBalanceForCurrency(
      instantAvailableField,
      normalizedCurrency,
    );

    if (availableBalanceInCents < payoutAmountInCents) {
      throw new HttpsError(
        "failed-precondition",
        `Insufficient available balance. Available: ${(
          availableBalanceInCents / 100
        ).toFixed(2)} ${normalizedCurrency.toUpperCase()}`,
      );
    }

    const eligibility = await getDriverPayoutEligibilitySnapshot(db, stripe, {
      driverId: request.auth.uid,
      stripeAccountId,
      currency: normalizedCurrency,
      stripeAvailableBalanceInCents: availableBalanceInCents,
    });

    if (eligibility.withdrawableBalanceInCents < payoutAmountInCents) {
      throw new HttpsError(
        "failed-precondition",
        `Only €${(eligibility.withdrawableBalanceInCents / 100).toFixed(2)} is eligible for withdrawal. Ride payments become withdrawable after the ride is completed.`,
      );
    }

    // Include epoch seconds so the same amount can be paid out more than once per day.
    const payoutIdempotencyKey = `payout_${request.auth.uid}_${stripeAccountId}_${payoutAmountInCents}_${normalizedCurrency}_${Math.floor(Date.now() / 1000)}`;

    const payout = await stripe.payouts.create(
      {
        amount: payoutAmountInCents,
        currency: normalizedCurrency,
        method: "instant",
        metadata: {
          driverId: request.auth.uid,
          connectedAccountId: stripeAccountId,
          source: "sportconnect_instant_payout",
        },
      },
      {
        stripeAccount: stripeAccountId,
        idempotencyKey: payoutIdempotencyKey,
      },
    );

    // BUG-CF-04: Guard against duplicate payout docs (idempotency key reuse
    // or webhook race can create two Firestore docs for the same Stripe payout).
    const existingPayoutSnap = await db
      .collection("payouts")
      .where("stripePayoutId", "==", payout.id)
      .limit(1)
      .get();
    if (!existingPayoutSnap.empty) {
      logger.warn("Duplicate payout guard: doc already exists", {
        stripePayoutId: payout.id,
        existingDocId: existingPayoutSnap.docs[0].id,
      });
      return {
        payoutId: existingPayoutSnap.docs[0].id,
        stripePayoutId: payout.id,
        status: payout.status,
        amountInCents: payoutAmountInCents,
        stripeBalanceTransactionId: stripeObjectId(payout.balance_transaction),
        arrivalDate: payout.arrival_date,
      };
    }

    // Stripe always returns "pending" at payout creation time.
    // The lifecycle is: pending → in_transit → paid (via payout.paid webhook).
    // Map to Dart PayoutStatus enum values: pending, inTransit, paid, failed, cancelled.
    const payoutRef = await db.collection("payouts").add({
      driverId: request.auth.uid,
      driverName:
        (callerData.username as string | undefined) ??
        (callerData.displayName as string | undefined) ??
        (callerData.name as string | undefined) ??
        `${callerData.firstName ?? ""} ${callerData.lastName ?? ""}`.trim(),
      stripePayoutId: payout.id,
      connectedAccountId: stripeAccountId,
      amount: payoutAmountInCents / 100,
      amountInCents: payoutAmountInCents,
      currency: normalizedCurrency,
      status: "pending",
      method: payout.method === "instant" ? "instant" : "standard",
      type: payout.type === "card" ? "card" : "bankAccount",
      destination: stripeObjectId(payout.destination),
      stripeBalanceTransactionId: stripeObjectId(payout.balance_transaction),
      transactionIds: [],
      isInstantPayout: true,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      expectedArrivalDate: payout.arrival_date
        ? new Date(payout.arrival_date * 1000)
        : null,
    });

    await db
      .collection("driver_connected_accounts")
      .doc(request.auth.uid)
      .set(
        {
          availableBalance: FieldValue.increment(-(payoutAmountInCents / 100)),
          availableBalanceInCents: FieldValue.increment(-payoutAmountInCents),
          lastPayoutAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

    return {
      payoutId: payoutRef.id,
      stripePayoutId: payout.id,
      status: payout.status,
      amountInCents: payoutAmountInCents,
      stripeBalanceTransactionId: stripeObjectId(payout.balance_transaction),
      arrivalDate: payout.arrival_date,
    };
  },
);

// ============================================
// Stripe: Cancel Instant Payout
// ============================================

export const cancelInstantPayout = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { stripePayoutId, payoutDocId } = request.data as {
      stripePayoutId: string;
      payoutDocId: string;
    };

    if (!stripePayoutId || !payoutDocId) {
      throw new HttpsError(
        "invalid-argument",
        "stripePayoutId and payoutDocId are required",
      );
    }

    const db = firestoreDb;
    const stripeSecretKeyVal = stripeSecretKey.value().trim();
    const stripe = getStripeClient(stripeSecretKeyVal);

    // Verify caller owns this payout doc.
    const payoutDoc = await db.collection("payouts").doc(payoutDocId).get();
    if (!payoutDoc.exists) {
      throw new HttpsError("not-found", "Payout not found");
    }
    const payoutData = payoutDoc.data()!;
    if (payoutData.driverId !== request.auth.uid) {
      throw new HttpsError("permission-denied", "You do not own this payout");
    }
    if (payoutData.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        `Payout cannot be cancelled in status: ${payoutData.status}`,
      );
    }
    if (payoutData.stripePayoutId !== stripePayoutId) {
      throw new HttpsError(
        "invalid-argument",
        "stripePayoutId does not match payout doc",
      );
    }

    const stripeAccountId = payoutData.connectedAccountId as string;

    const cancelledPayout = await stripe.payouts
      .cancel(stripePayoutId, {}, { stripeAccount: stripeAccountId })
      .catch((error: unknown) => {
        const e = error as { message?: string };
        throw new HttpsError(
          "failed-precondition",
          `Failed to cancel payout: ${e.message ?? "unknown error"}`,
        );
      });

    const cancelBatch = db.batch();
    cancelBatch.update(db.collection("payouts").doc(payoutDocId), {
      status: "cancelled",
      failureReason: "Cancelled by driver",
      updatedAt: FieldValue.serverTimestamp(),
    });
    cancelBatch.set(
      db.collection("driver_connected_accounts").doc(request.auth.uid),
      {
        availableBalance: FieldValue.increment(
          (cancelledPayout.amount ?? payoutData.amountInCents) / 100,
        ),
        availableBalanceInCents: FieldValue.increment(
          cancelledPayout.amount ?? payoutData.amountInCents,
        ),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await cancelBatch.commit();

    return { success: true, status: cancelledPayout.status };
  },
);

// ============================================
// Stripe: Request Automatic Refund
// ============================================

export const requestRefund = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const requestData = asRecord(request.data) ?? {};
    const db = firestoreDb;
    const paymentDocs = await findPaymentDocsForRefundRequest(db, requestData);

    if (paymentDocs.length === 0) {
      throw new HttpsError("not-found", "Payment not found");
    }

    const paymentRef = paymentDocs[0].ref;
    const payment = paymentDocs[0].data();
    const requesterId = request.auth.uid;
    const riderId =
      stringOrEmpty(payment.riderId) || stringOrEmpty(payment.passengerId);

    if (riderId !== requesterId) {
      throw new HttpsError(
        "permission-denied",
        "Only the rider who paid can request a refund",
      );
    }

    const paymentStatus = stringOrEmpty(payment.status);
    if (paymentStatus === "refunded") {
      throw new HttpsError(
        "failed-precondition",
        "This payment has already been refunded",
      );
    }
    if (paymentStatus === "refunding") {
      throw new HttpsError(
        "failed-precondition",
        "A refund is already being processed for this payment",
      );
    }
    if (
      !["succeeded", "partiallyRefunded", "refundFailed"].includes(
        paymentStatus,
      )
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Only completed ride payments can be reviewed for a refund",
      );
    }
    if (!isWithinRefundRequestWindow(payment.createdAt)) {
      throw new HttpsError(
        "failed-precondition",
        `Refund requests must be submitted within ${REFUND_REQUEST_WINDOW_DAYS} days of payment`,
      );
    }

    const paymentIntentId =
      stringOrEmpty(payment.paymentIntentId) ||
      stringOrEmpty(payment.stripePaymentIntentId);
    if (paymentIntentId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "This payment is missing its Stripe payment reference",
      );
    }

    const reason = stringOrEmpty(requestData.reason) || "other";
    const details = stringOrEmpty(requestData.details).slice(0, 2000);
    const amountInCents = paymentAmountInCents(payment);
    const alreadyRefundedInCents = refundedAmountInCents(payment);
    const remainingAmountInCents = Math.max(
      0,
      amountInCents - alreadyRefundedInCents,
    );

    const requestId = `${paymentRef.id}_${requesterId}`;
    const refundRequestRef = db.collection("refund_requests").doc(requestId);
    const existingRequest = await refundRequestRef.get();
    if (existingRequest.exists) {
      const status = stringOrEmpty(existingRequest.data()?.status);
      if (OPEN_REFUND_REQUEST_STATUSES.has(status)) {
        return {
          requestId,
          status,
          alreadyExists: true,
        };
      }
      if (!["notAutomaticallyEligible", "failed"].includes(status)) {
        throw new HttpsError(
          "failed-precondition",
          "This payment already has a reviewed refund request",
        );
      }
    }

    const userSnap = await db.collection("users").doc(requesterId).get();
    const user = userSnap.data() ?? {};
    const requesterEmail =
      stringOrEmpty(user.email) || stringOrEmpty(user.userEmail) || "unknown";
    const rideId = stringOrEmpty(payment.rideId);
    const bookingId = stringOrEmpty(payment.bookingId);
    const driverId = stringOrEmpty(payment.driverId);
    const [rideSnap, bookingSnap] = await Promise.all([
      rideId.length > 0 ? db.collection("rides").doc(rideId).get() : null,
      bookingId.length > 0
        ? db.collection("bookings").doc(bookingId).get()
        : null,
    ]);
    const ride = rideSnap?.data();
    const booking = bookingSnap?.data();
    const policy = isRideObjectivelyRefundable({ reason, ride, booking });

    const metadata = {
      refundRequestId: requestId,
      paymentDocId: paymentRef.id,
      paymentIntentId,
      bookingId,
      rideId,
      driverId,
      requesterId,
      amountInCents,
      remainingAmountInCents,
      reason,
    };

    if (!AUTOMATIC_REFUND_REASONS.has(reason) || !policy.eligible) {
      await refundRequestRef.set({
        ...metadata,
        status: "notAutomaticallyEligible",
        requesterEmail,
        details,
        policyReason: policy.reason,
        paymentStatus,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      throw new HttpsError("failed-precondition", policy.reason);
    }

    await refundRequestRef.set({
      ...metadata,
      status: "refunding",
      requesterEmail,
      details,
      policyReason: policy.reason,
      paymentStatus,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    let refund: StripeRefund;
    try {
      refund = await createStripeRefundForPayment({
        db,
        stripe,
        paymentDocs,
        paymentIntentId,
        reason: policy.reason,
        source: "sportconnect_systematic_refund",
        requestedByUid: requesterId,
        refundRequestId: requestId,
        idempotencyKey: `refund_request_${requestId}`,
      });
    } catch (error) {
      await refundRequestRef.set(
        {
          status: "failed",
          failureReason: error instanceof Error ? error.message : String(error),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      throw error;
    }

    await db.runTransaction(async (txn) => {
      txn.set(
        refundRequestRef,
        {
          ...metadata,
          status: "refunding",
          requesterEmail,
          policyReason: policy.reason,
          paymentStatus,
          details,
          stripeRefundId: refund.id,
          stripeRefundStatus: refund.status ?? "pending",
          requestedRefundAmountInCents: refund.amount ?? remainingAmountInCents,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      txn.update(paymentRef, {
        latestRefundRequestId: requestId,
        latestRefundRequestedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    });

    return {
      requestId,
      refundId: refund.id,
      status: refund.status ?? "pending",
      amount: (refund.amount ?? 0) / 100,
      amountInCents: refund.amount ?? 0,
      alreadyExists: false,
    };
  },
);

// ============================================
// Stripe: Refund Payment
// ============================================

export const refundPayment = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    if (!isRefundOperator(request.auth)) {
      throw new HttpsError(
        "permission-denied",
        "Refunds must be issued by support or an administrator",
      );
    }

    const {
      paymentIntentId,
      amountInCents: requestedAmountInCents,
      amount: legacyAmount,
      reason = "requested_by_customer",
      refundRequestId,
      idempotencyKey,
    } = request.data;

    if (!paymentIntentId) {
      throw new HttpsError("invalid-argument", "paymentIntentId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;

    const paymentDocs = await findPaymentDocsByPaymentIntent(
      db,
      paymentIntentId,
    );

    if (paymentDocs.length === 0) {
      throw new HttpsError("not-found", "Payment not found");
    }

    const refundAmountInCents =
      finiteNumber(requestedAmountInCents) !== undefined
        ? Math.round(finiteNumber(requestedAmountInCents)!)
        : finiteNumber(legacyAmount) !== undefined
          ? Math.round(finiteNumber(legacyAmount)! * 100)
          : undefined;

    if (refundAmountInCents !== undefined && refundAmountInCents <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "amountInCents must be greater than zero",
      );
    }

    const paymentRef = paymentDocs[0].ref;
    let claimedPayment: DocumentData = paymentDocs[0].data();
    let amountToRefundInCents = refundAmountInCents ?? 0;
    try {
      await db.runTransaction(async (txn) => {
        const snap = await txn.get(paymentRef);
        if (!snap.exists) throw new Error("payment_not_found");
        const data = snap.data()!;
        const currentStatus = stringOrEmpty(data.status);
        if (currentStatus === "refunded") {
          throw new Error("already_refunded");
        }
        // "refunding" + stripeRefundId = Stripe accepted it, block duplicate
        // "refunding" without stripeRefundId = previous attempt failed, allow retry
        if (currentStatus === "refunding" && data.stripeRefundId) {
          throw new Error("already_refunded");
        }
        if (
          currentStatus !== "succeeded" &&
          currentStatus !== "partiallyRefunded" &&
          currentStatus !== "refundFailed" &&
          currentStatus !== "refunding"
        ) {
          throw new Error("payment_not_succeeded");
        }

        const originalAmount = paymentAmountInCents(data);
        const remainingAmount = Math.max(
          0,
          originalAmount - refundedAmountInCents(data),
        );
        amountToRefundInCents = refundAmountInCents ?? remainingAmount;
        if (amountToRefundInCents <= 0) {
          throw new Error("already_refunded");
        }
        if (amountToRefundInCents > remainingAmount) {
          throw new Error("invalid_refund_amount");
        }

        claimedPayment = data;
        txn.update(paymentRef, {
          status: "refunding",
          updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      if (message === "already_refunded") {
        throw new HttpsError(
          "failed-precondition",
          "Payment has already been refunded",
        );
      }
      if (message === "payment_not_succeeded") {
        throw new HttpsError(
          "failed-precondition",
          "Only succeeded payments can be refunded",
        );
      }
      if (message === "invalid_refund_amount") {
        throw new HttpsError(
          "invalid-argument",
          "Refund amount exceeds the remaining refundable amount",
        );
      }
      throw error;
    }
    const refundReason = stringOrEmpty(reason);
    const stripeRefundReason: StripeRefundCreateParams["reason"] = [
      "duplicate",
      "fraudulent",
      "requested_by_customer",
    ].includes(refundReason)
      ? (refundReason as StripeRefundCreateParams["reason"])
      : "requested_by_customer";

    const refundParams: StripeRefundCreateParams = {
      payment_intent: paymentIntentId,
      reason: stripeRefundReason,
      reverse_transfer: true,
      refund_application_fee: true,
      metadata: {
        paymentIntentId,
        paymentDocId: paymentRef.id,
        bookingId:
          typeof claimedPayment.bookingId === "string"
            ? claimedPayment.bookingId
            : "",
        driverId:
          typeof claimedPayment.driverId === "string"
            ? claimedPayment.driverId
            : "",
        riderId:
          typeof claimedPayment.riderId === "string"
            ? claimedPayment.riderId
            : "",
        refundReason,
        source: "sportconnect_manual_refund",
      },
    };

    const originalAmountInCents = paymentAmountInCents(claimedPayment);
    if (amountToRefundInCents < originalAmountInCents) {
      refundParams.amount = amountToRefundInCents;
    }

    const stableIdempotencyKey =
      stringOrEmpty(idempotencyKey) ||
      (stringOrEmpty(refundRequestId).length > 0
        ? `refund_request_${stringOrEmpty(refundRequestId)}`
        : `manual_refund_${paymentIntentId}_${amountToRefundInCents}_${request.auth.uid}_${Date.now()}`);

    let refund: StripeRefund;
    try {
      refund = await stripe.refunds.create(refundParams, {
        idempotencyKey: stableIdempotencyKey,
      });
    } catch (stripeError) {
      // Stripe rejected the refund — roll back to "succeeded" so it can be retried
      await paymentRef
        .update({
          status: stringOrEmpty(claimedPayment.status) || "succeeded",
          updatedAt: FieldValue.serverTimestamp(),
        })
        .catch(() => {
          /* best-effort */
        });
      const e = stripeError as { message?: string };
      throw new HttpsError(
        "internal",
        `Stripe refund failed: ${e.message ?? "unknown error"}`,
      );
    }

    for (const doc of paymentDocs) {
      await doc.ref.update({
        status: "refunding",
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        refundReason: refundReason || stripeRefundReason,
        requestedRefundAmountInCents: amountToRefundInCents,
        refundedAt: null,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    const requestId = stringOrEmpty(refundRequestId);
    if (requestId.length > 0) {
      await db
        .collection("refund_requests")
        .doc(requestId)
        .set(
          {
            status: "refunding",
            stripeRefundId: refund.id,
            stripeRefundStatus: refund.status ?? "pending",
            reviewedByUid: request.auth.uid,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    }

    return {
      refundId: refund.id,
      status: refund.status,
      amount: (refund.amount ?? 0) / 100,
      amountInCents: refund.amount ?? 0,
    };
  },
);

// ============================================
// Admin: Resolve Refund / Dispute / Support Issues
// ============================================

export const approveRefundRequest = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    if (!isRefundOperator(request.auth)) {
      throw new HttpsError("permission-denied", "Admin access required");
    }

    const requestData = asRecord(request.data) ?? {};
    const refundRequestId = stringOrEmpty(requestData.refundRequestId);
    const amountInCents =
      finiteNumber(requestData.amountInCents) !== undefined
        ? Math.round(finiteNumber(requestData.amountInCents)!)
        : undefined;

    if (refundRequestId.length === 0) {
      throw new HttpsError("invalid-argument", "refundRequestId is required");
    }

    const db = firestoreDb;
    const refundRequestRef = db
      .collection("refund_requests")
      .doc(refundRequestId);
    const refundRequestSnap = await refundRequestRef.get();
    if (!refundRequestSnap.exists) {
      throw new HttpsError("not-found", "Refund request not found");
    }

    const refundRequest = refundRequestSnap.data()!;
    const paymentIntentId = stringOrEmpty(refundRequest.paymentIntentId);
    if (paymentIntentId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Refund request is missing paymentIntentId",
      );
    }

    const paymentDocs = await findPaymentDocsByPaymentIntent(
      db,
      paymentIntentId,
    );
    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const refund = await createStripeRefundForPayment({
      db,
      stripe,
      paymentDocs,
      paymentIntentId,
      amountInCents,
      reason:
        stringOrEmpty(requestData.reason) ||
        stringOrEmpty(refundRequest.reason) ||
        "requested_by_customer",
      source: "sportconnect_admin_refund",
      requestedByUid: request.auth.uid,
      refundRequestId,
      // Bind the idempotency key to the refund-request identity only — NOT to the
      // operator-supplied amount. Keying on the variable amount let an operator
      // who first refunded "remaining" then submit an explicit amount obtain a
      // fresh key and trigger a second Stripe refund before the first webhook
      // flipped status to "refunded". The in-transaction status/remaining checks
      // in createStripeRefundForPayment remain the source of truth for amounts.
      idempotencyKey: `admin_refund_${refundRequestId}`,
    });

    await refundRequestRef.set(
      {
        status: "refunding",
        reviewedByUid: request.auth.uid,
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        requestedRefundAmountInCents: refund.amount ?? amountInCents ?? null,
        resolutionNote: stringOrEmpty(requestData.note),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return {
      refundId: refund.id,
      status: refund.status,
      amountInCents: refund.amount ?? 0,
    };
  },
);

export const rejectRefundRequest = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  if (!isRefundOperator(request.auth)) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  const requestData = asRecord(request.data) ?? {};
  const refundRequestId = stringOrEmpty(requestData.refundRequestId);
  if (refundRequestId.length === 0) {
    throw new HttpsError("invalid-argument", "refundRequestId is required");
  }

  await firestoreDb
    .collection("refund_requests")
    .doc(refundRequestId)
    .set(
      {
        status: "rejected",
        reviewedByUid: request.auth.uid,
        resolutionNote: stringOrEmpty(requestData.note),
        resolvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  return { success: true };
});

export const resolveSupportTicket = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  if (!isRefundOperator(request.auth)) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  const requestData = asRecord(request.data) ?? {};
  const ticketId = stringOrEmpty(requestData.ticketId);
  if (ticketId.length === 0) {
    throw new HttpsError("invalid-argument", "ticketId is required");
  }

  await firestoreDb
    .collection("support_tickets")
    .doc(ticketId)
    .set(
      {
        status: "resolved",
        resolvedByUid: request.auth.uid,
        resolutionNote: stringOrEmpty(requestData.note),
        resolvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  return { success: true };
});

export const rejectDispute = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  if (!isRefundOperator(request.auth)) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  const requestData = asRecord(request.data) ?? {};
  const disputeId = stringOrEmpty(requestData.disputeId);
  if (disputeId.length === 0) {
    throw new HttpsError("invalid-argument", "disputeId is required");
  }

  await firestoreDb
    .collection("disputes")
    .doc(disputeId)
    .set(
      {
        status: "closed",
        resolution: stringOrEmpty(requestData.note) || "Closed without refund",
        resolvedByUid: request.auth.uid,
        resolvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  return { success: true };
});

export const approveDisputeRefund = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    if (!isRefundOperator(request.auth)) {
      throw new HttpsError("permission-denied", "Admin access required");
    }

    const requestData = asRecord(request.data) ?? {};
    const disputeId = stringOrEmpty(requestData.disputeId);
    const amountInCents =
      finiteNumber(requestData.amountInCents) !== undefined
        ? Math.round(finiteNumber(requestData.amountInCents)!)
        : undefined;
    if (disputeId.length === 0) {
      throw new HttpsError("invalid-argument", "disputeId is required");
    }

    const db = firestoreDb;
    const disputeRef = db.collection("disputes").doc(disputeId);
    const disputeSnap = await disputeRef.get();
    if (!disputeSnap.exists) {
      throw new HttpsError("not-found", "Dispute not found");
    }

    const dispute = disputeSnap.data()!;
    const rideId = stringOrEmpty(dispute.rideId);
    const riderId =
      stringOrEmpty(dispute.complainantId) || stringOrEmpty(dispute.userId);
    if (rideId.length === 0 || riderId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Dispute is missing ride or complainant data",
      );
    }

    let paymentsSnap = await db
      .collection("payments")
      .where("rideId", "==", rideId)
      .where("riderId", "==", riderId)
      .limit(1)
      .get();
    if (paymentsSnap.empty) {
      paymentsSnap = await db
        .collection("payments")
        .where("rideId", "==", rideId)
        .where("passengerId", "==", riderId)
        .limit(1)
        .get();
    }
    if (paymentsSnap.empty) {
      throw new HttpsError("not-found", "No payment found for this dispute");
    }

    const paymentDoc = paymentsSnap.docs[0];
    const payment = paymentDoc.data();
    const paymentIntentId =
      stringOrEmpty(payment.paymentIntentId) ||
      stringOrEmpty(payment.stripePaymentIntentId);
    if (paymentIntentId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Payment is missing paymentIntentId",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const refund = await createStripeRefundForPayment({
      db,
      stripe,
      paymentDocs: [paymentDoc],
      paymentIntentId,
      amountInCents,
      reason: "dispute_resolution",
      source: "sportconnect_dispute_refund",
      requestedByUid: request.auth.uid,
      // Bind the idempotency key to the dispute identity only — NOT to the
      // operator-supplied amount — so a second submission with a different amount
      // cannot bypass idempotency and trigger a duplicate Stripe refund.
      idempotencyKey: `dispute_refund_${disputeId}`,
    });

    await disputeRef.set(
      {
        status: "resolved",
        resolution: stringOrEmpty(requestData.note) || "Refund approved",
        resolvedByUid: request.auth.uid,
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        resolvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return {
      refundId: refund.id,
      status: refund.status,
      amountInCents: refund.amount ?? 0,
    };
  },
);

// ============================================
// Stripe: Get or Create Customer
// ============================================

export const getOrCreateCustomer = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 10 calls per user per 60 s
    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "getOrCreateCustomer",
      10,
      60,
    );

    const { email, name, phone, existingCustomerId } = request.data;

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;
    const userId = request.auth.uid;

    if (existingCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(existingCustomerId);
        if (!existing.deleted) {
          return { customerId: existingCustomerId };
        }
      } catch {
        logger.info("Existing customer not found, creating new one");
      }
    }

    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();
    if (userData?.stripeCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(
          userData.stripeCustomerId,
        );
        if (!existing.deleted) {
          return { customerId: userData.stripeCustomerId };
        }
      } catch {
        logger.info("Stored customer ID invalid, creating new one");
      }
    }

    const customer = await stripe.customers.create({
      email,
      ...(name && { name }),
      ...(phone && { phone }),
      metadata: { userId },
    });

    await db.collection("users").doc(userId).update({
      stripeCustomerId: customer.id,
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { customerId: customer.id };
  },
);

// ============================================
// Stripe: Create Payment Intent
// ============================================

export const createPaymentIntent = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 10 payment intents per user per 60 s
    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "createPaymentIntent",
      10,
      60,
    );

    const {
      amount: legacyAmount,
      amountInCents: requestedAmountInCents,
      rideId,
      driverId,
      riderId,
      riderName,
      driverName,
      driverStripeAccountId,
      description,
      customerId,
      stripeApiVersion,
    } = request.data;

    if (
      finiteNumber(requestedAmountInCents) === undefined &&
      finiteNumber(legacyAmount) === undefined
    ) {
      throw new HttpsError("invalid-argument", "amountInCents is required");
    }

    if (!rideId || !driverId || !riderId) {
      throw new HttpsError("invalid-argument", "Missing required fields");
    }

    if (!driverStripeAccountId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver has not set up Stripe Connect account. Payment cannot be processed.",
      );
    }

    // FIX CF-1: Verify the authenticated caller is actually a passenger on
    // this booking.  Without this check any authenticated user who knows a
    // rideId can initiate a payment charge.
    if (request.auth.uid !== riderId) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorised to pay for this booking",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;

    // FIX P-4: Ignore the client-supplied `amount` and recompute the price
    // server-side from the canonical ride document.  A modified client could
    // otherwise request a €0.01 charge instead of the real fare.
    const rideDoc = await db.collection("rides").doc(rideId).get();
    if (!rideDoc.exists) {
      throw new HttpsError("not-found", "Ride not found");
    }
    const rideData = rideDoc.data()!;
    if (rideData.status !== "active" && rideData.status !== "inProgress") {
      throw new HttpsError(
        "failed-precondition",
        "Ride is no longer available for payment",
      );
    }
    // Payment happens only after driver acceptance; requesting a seat and
    // paying for an accepted seat are separate domain states.
    const bookingsSnap = await db
      .collection("bookings")
      .where("rideId", "==", rideId)
      .where("passengerId", "==", riderId)
      .where("status", "==", "accepted")
      .limit(1)
      .get();
    if (bookingsSnap.empty) {
      throw new HttpsError(
        "failed-precondition",
        "No accepted booking found for this ride",
      );
    }
    const bookingId = bookingsSnap.docs[0].id;
    const bookingData = bookingsSnap.docs[0].data();
    if (bookingData.paidAt || bookingData.paymentIntentId) {
      throw new HttpsError(
        "failed-precondition",
        "This booking has already been paid",
      );
    }
    const seatsBooked = (bookingData.seatsBooked as number) ?? 1;
    const pricePerSeatInCents = getRidePricePerSeatInCents(rideData);
    const requestAmountInCents =
      finiteNumber(requestedAmountInCents) !== undefined
        ? Math.round(finiteNumber(requestedAmountInCents)!)
        : finiteNumber(legacyAmount) !== undefined
          ? Math.round(finiteNumber(legacyAmount)!)
          : Number.NaN;
    const amountInCents =
      pricePerSeatInCents !== undefined
        ? pricePerSeatInCents * seatsBooked
        : requestAmountInCents;

    if (!Number.isFinite(amountInCents) || amountInCents <= 0) {
      throw new HttpsError(
        "failed-precondition",
        "Ride price could not be calculated",
      );
    }

    const paymentCurrency = "eur";

    // FIX: Moved charges_enabled check OUTSIDE the try/catch to preserve
    // the meaningful error message. The original swallowed it into a generic catch.
    const account = await stripe.accounts
      .retrieve(driverStripeAccountId)
      .catch((error: unknown) => {
        const e = error as { message?: string };
        logger.error("Error retrieving Stripe account:", {
          driverStripeAccountId,
          driverId,
          error: e.message,
        });
        throw new HttpsError(
          "failed-precondition",
          `Driver's Stripe account verification failed: ${e.message ?? "unknown error"}`,
        );
      });

    // BUG-CF-02: Verify caller-supplied driverStripeAccountId belongs to driverId.
    // Without this check, a rider could substitute another driver's account ID
    // and route charges through it.
    const accountOwnerSnap = await db
      .collection("driver_connected_accounts")
      .where("driverId", "==", driverId)
      .where("stripeAccountId", "==", driverStripeAccountId)
      .limit(1)
      .get();
    if (accountOwnerSnap.empty) {
      logger.error(
        "Ownership check failed: stripeAccountId not owned by driver",
        {
          driverId,
          driverStripeAccountId,
        },
      );
      throw new HttpsError(
        "permission-denied",
        "The provided Stripe account does not belong to this driver.",
      );
    }

    if (!account.charges_enabled) {
      throw new HttpsError(
        "failed-precondition",
        "Driver's Stripe account is not fully activated. Charges are not enabled.",
      );
    }

    if (!account.payouts_enabled) {
      logger.warn(
        `Driver ${driverId} has charges enabled but payouts disabled`,
      );
    }

    // Use the server-computed amount (P-4) so the client cannot manipulate the charge.
    const { platformFee, driverAmount } = calculateFees(amountInCents);

    const idempotencyKey = `pi_${bookingId}_${amountInCents}`;

    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount: amountInCents,
        currency: paymentCurrency,
        automatic_payment_methods: { enabled: true },
        description: description || `SportConnect ride payment - ${rideId}`,
        // Destination charge: funds land on the driver's connected account
        // at capture; reverse_transfer/refund_application_fee refunds work.
        application_fee_amount: platformFee,
        transfer_data: { destination: driverStripeAccountId },
        metadata: {
          rideId,
          driverId,
          riderId,
          bookingId,
          moneyFlow: "destination_charge",
          driverStripeAccountId,
          platformFeeInCents: String(platformFee),
          driverAmountInCents: String(driverAmount),
        },
      },
      { idempotencyKey },
    );

    const paymentRef = db.collection("payments").doc(paymentIntent.id);
    const existingPaymentDoc = await paymentRef.get();
    if (!existingPaymentDoc.exists) {
      await paymentRef.set({
        paymentIntentId: paymentIntent.id,
        stripePaymentIntentId: paymentIntent.id,
        bookingId,
        rideId,
        driverId,
        riderId,
        riderName: riderName || "",
        driverName: driverName || "",
        driverStripeAccountId,
        amount: amountInCents / 100,
        amountInCents,
        currency: paymentCurrency,
        platformFee: platformFee / 100,
        platformFeeInCents: platformFee,
        driverEarnings: driverAmount / 100,
        driverEarningsInCents: driverAmount,
        moneyFlow: "platform_held",
        payoutStatus: "pending_completion",
        transferStatus: "not_transferred",
        earnedAt: null,
        transferredAt: null,
        stripeFee: 0,
        stripeFeeInCents: 0,
        seatsBooked,
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // FIX: The ephemeral key apiVersion MUST be the version required by the
    // Flutter stripe SDK (client-side), NOT the server API version.
    // The client passes its required version as `stripeApiVersion`.
    // Stripe enforces that ephemeral keys must be created with the client's version.
    let ephemeralKey: string | undefined;
    if (customerId) {
      const ephemeralKeyVersion = stripeApiVersion || "2026-04-22.dahlia";
      const ephemeralKeyObj = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: ephemeralKeyVersion },
      );
      ephemeralKey = ephemeralKeyObj.secret;
    }

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      ...(ephemeralKey && { ephemeralKey }),
    };
  },
);

// ============================================
// Verify Booking Payment (post-PaymentSheet reconciliation)
// ============================================

/**
 * Called by the client immediately after the Stripe PaymentSheet reports
 * success. Stamps the booking `{ paidAt, paymentIntentId, paymentStatus }`
 * so every screen reflects "paid" without waiting for webhook delivery —
 * removing the window where a rider who already paid still sees a
 * "Complete Payment" call to action.
 *
 * The Stripe webhook remains the source of truth for downstream effects
 * (driver balance, notifications) and stays fully idempotent against this
 * write: it only stamps bookings whose `paidAt` is not yet set.
 *
 * Security: success is verified against Stripe itself (the client cannot
 * forge it), and the PaymentIntent's server-set metadata must reference
 * this exact booking. Idempotent: re-running after the webhook lands is a
 * no-op.
 */
export const verifyBookingPayment = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "verifyBookingPayment",
      20,
      60,
    );

    const { bookingId, paymentIntentId } = request.data as {
      bookingId?: string;
      paymentIntentId?: string;
    };

    if (!bookingId || !paymentIntentId) {
      throw new HttpsError(
        "invalid-argument",
        "bookingId and paymentIntentId are required",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());

    // Authoritative status comes from Stripe, never from the client.
    let intent;
    try {
      intent = await stripe.paymentIntents.retrieve(paymentIntentId);
    } catch (error) {
      logger.warn("verifyBookingPayment: failed to retrieve intent", {
        paymentIntentId,
        error,
      });
      throw new HttpsError("not-found", "Payment could not be verified");
    }

    if (intent.status !== "succeeded") {
      throw new HttpsError(
        "failed-precondition",
        "Payment has not succeeded yet",
      );
    }

    // The charge must reference this booking via server-set metadata.
    if (intent.metadata?.bookingId !== bookingId) {
      throw new HttpsError(
        "permission-denied",
        "Payment does not match this booking",
      );
    }

    const bookingRef = firestoreDb.collection("bookings").doc(bookingId);

    await firestoreDb.runTransaction(async (tx) => {
      const snap = await tx.get(bookingRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Booking not found");
      }
      const data = snap.data()!;

      const passengerId = data.passengerId as string | undefined;
      if (passengerId !== request.auth!.uid) {
        throw new HttpsError("permission-denied", "Not your booking");
      }

      // Already reconciled by us or by the webhook — idempotent no-op.
      if (data.paidAt || data.paymentIntentId === paymentIntentId) {
        return;
      }

      const status = data.status as string | undefined;
      if (status === "cancelled" || status === "rejected") {
        throw new HttpsError(
          "failed-precondition",
          "This booking can no longer be marked paid",
        );
      }

      tx.update(bookingRef, {
        paymentIntentId: paymentIntentId,
        paymentStatus: "paid",
        paidAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    });

    return { verified: true };
  },
);

// ============================================
// Sync Driver Stripe Balance
// ============================================

export const syncDriverBalance = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 20 balance syncs per user per 60 s
    await checkRateLimit(
      firestoreDb,
      request.auth.uid,
      "syncDriverBalance",
      20,
      60,
    );

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;
    const driverId = request.auth.uid;

    try {
      // Resolve stripeAccountId from driver_connected_accounts first,
      // then fall back to the users doc. The two collections may be out of
      // sync during onboarding, so checking both prevents false "not-found"
      // errors after a driver completes setup.
      const [connectedAccountDoc, userDoc] = await Promise.all([
        db.collection("driver_connected_accounts").doc(driverId).get(),
        db.collection("users").doc(driverId).get(),
      ]);

      const stripeAccountId: string | undefined =
        (connectedAccountDoc.data()?.stripeAccountId as string | undefined) ??
        (userDoc.data()?.stripeAccountId as string | undefined);

      if (!stripeAccountId) {
        throw new HttpsError(
          "not-found",
          "No Stripe account ID found. Driver must complete onboarding first.",
        );
      }

      // Fetch balance from Stripe
      const balance = await stripe.balance.retrieve(
        {},
        {
          stripeAccount: stripeAccountId,
        },
      );

      const defaultCurrency = (
        (connectedAccountDoc.data()?.defaultCurrency as string | undefined) ??
        (userDoc.data()?.defaultCurrency as string | undefined) ??
        "eur"
      ).toLowerCase();
      const availableBalanceInCents = sumBalanceForCurrency(
        balance.available,
        defaultCurrency,
      );
      const pendingBalanceInCents = sumBalanceForCurrency(
        balance.pending,
        defaultCurrency,
      );

      logger.info("Synced balance for driver", {
        driverId,
        stripeAccountId,
        availableBalanceInCents,
        pendingBalanceInCents,
      });

      // Upsert driver_connected_accounts — if the doc was never created
      // (e.g. onboarding completed via the webhook path) set it now.
      await db
        .collection("driver_connected_accounts")
        .doc(driverId)
        .set(
          {
            driverId,
            stripeAccountId,
            availableBalance: availableBalanceInCents / 100,
            pendingBalance: pendingBalanceInCents / 100,
            availableBalanceInCents,
            pendingBalanceInCents,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

      return {
        success: true,
        availableBalance: availableBalanceInCents / 100,
        pendingBalance: pendingBalanceInCents / 100,
        availableBalanceInCents,
        pendingBalanceInCents,
      };
    } catch (error) {
      const e = error as { message?: string };
      logger.error("syncDriverBalance failed", {
        driverId,
        error: e.message,
      });

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        `Failed to sync balance: ${e.message ?? "unknown error"}`,
      );
    }
  },
);

// ============================================
// Stripe: Customer Sheet Setup
// Creates a SetupIntent + EphemeralKey for managing saved payment methods
// ============================================

export const createCustomerSheetSetup = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { stripeApiVersion } = request.data;
    const userId = request.auth.uid;

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = firestoreDb;

    // Get or verify the user's Stripe customer ID
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    if (!userData) {
      throw new HttpsError("not-found", "User not found");
    }

    let customerId: string | undefined = userData.stripeCustomerId;

    // If user doesn't have a customer ID, create one
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: userData.email,
        name:
          (userData.username as string | undefined) ??
          (userData.displayName as string | undefined),
        metadata: { userId },
      });
      customerId = customer.id;

      await db.collection("users").doc(userId).update({
        stripeCustomerId: customerId,
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      // Verify the customer still exists
      try {
        const existing = await stripe.customers.retrieve(customerId);
        if (existing.deleted) {
          const customer = await stripe.customers.create({
            email: userData.email,
            name: userData.displayName,
            metadata: { userId },
          });
          customerId = customer.id;
          await db.collection("users").doc(userId).update({
            stripeCustomerId: customerId,
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      } catch {
        logger.info("Stored customer invalid, creating new one");
        const customer = await stripe.customers.create({
          email: userData.email,
          name: userData.displayName,
          metadata: { userId },
        });
        customerId = customer.id;
        await db.collection("users").doc(userId).update({
          stripeCustomerId: customerId,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }

    // Create SetupIntent for saving payment methods without charging
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      automatic_payment_methods: { enabled: true },
      metadata: { userId },
    });

    // Create ephemeral key for the customer
    // Must use the client's SDK API version
    const ephemeralKeyVersion = stripeApiVersion || "2026-04-22.dahlia";
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: ephemeralKeyVersion },
    );

    return {
      setupIntentClientSecret: setupIntent.client_secret,
      customerId,
      ephemeralKeySecret: ephemeralKey.secret,
    };
  },
);
