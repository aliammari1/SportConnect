import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  AppStoreServerAPIClient,
  Environment,
} from "@apple/app-store-server-library";
import { google } from "googleapis";
import { db } from "./firebase-admin";
import {
  appleIapIssuerId,
  appleIapKeyId,
  appleIapPrivateKeyP8,
  playServiceAccountJson,
} from "./secrets";

/**
 * Public store identifiers for the premium subscription. These describe what
 * the server is willing to grant; they are intentionally NOT accepted from
 * the caller, whose input is limited to an opaque store receipt reference.
 */
const ANDROID_PACKAGE_NAME = "com.sportconnect.sport_connect";
const IOS_BUNDLE_ID = "com.sportconnect.SportConnectApplication";
const ANDROID_PREMIUM_PRODUCT_ID = "sportconnect_premium";
const IOS_PREMIUM_PRODUCT_IDS = new Set([
  "sportconnect_premium_monthly",
  "sportconnect_premium_yearly",
]);

const ANDROIDPUBLISHER_SCOPE =
  "https://www.googleapis.com/auth/androidpublisher";

/**
 * States that carry entitlement. Play grace period and Apple status 4 both
 * mean payment hiccuped but access continues per store policy.
 */
const GRANTING_PLAY_STATES = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
]);
const GRANTING_APPLE_STATUSES = new Set([1, 4]);

interface EntitlementDecision {
  grants: boolean;
  stateLabel: string;
  expiresAt?: Date;
  /** Stable per-purchase key; survives renewals on iOS via originalTransactionId. */
  receiptKey?: string;
}

function requireSecret(value: string | undefined, name: string): string {
  const trimmed = (value ?? "").trim();
  if (!trimmed) {
    throw new HttpsError(
      "failed-precondition",
      `Server is missing configuration for ${name}.`,
    );
  }
  return trimmed;
}

async function evaluateAndroidReceipt(
  token: string,
): Promise<EntitlementDecision> {
  let credentials: { client_email?: string; private_key?: string };
  try {
    credentials = JSON.parse(playServiceAccountJson.value());
  } catch (e) {
    logger.error("verifyPremiumPurchase: PLAY_SERVICE_ACCOUNT_JSON invalid", e);
    throw new HttpsError(
      "failed-precondition",
      "Server is misconfigured for Google Play verification.",
    );
  }
  if (!credentials.client_email || !credentials.private_key) {
    throw new HttpsError(
      "failed-precondition",
      "Server is misconfigured for Google Play verification.",
    );
  }

  let subscriptionState = "";
  let expiresAtMs = Number.NaN;
  try {
    const auth = new google.auth.GoogleAuth({
      credentials: credentials as { client_email: string; private_key: string },
      scopes: [ANDROIDPUBLISHER_SCOPE],
    });
    const publisher = google.androidpublisher({ version: "v3", auth });
    const response = await publisher.purchases.subscriptionsv2.get({
      packageName: ANDROID_PACKAGE_NAME,
      token,
    });
    subscriptionState = response.data.subscriptionState ?? "";

    const premiumItem =
      response.data.lineItems?.find(
        (item) => item.productId === ANDROID_PREMIUM_PRODUCT_ID,
      ) ?? null;

    if (premiumItem?.expiryTime) {
      const parsed = Date.parse(premiumItem.expiryTime);
      if (!Number.isNaN(parsed)) expiresAtMs = parsed;
    }
  } catch (e) {
    logger.error("verifyPremiumPurchase: Play API lookup failed", e);
    throw new HttpsError(
      "failed-precondition",
      "The purchase receipt could not be verified with Google Play.",
    );
  }

  return {
    grants: GRANTING_PLAY_STATES.has(subscriptionState),
    stateLabel: subscriptionState,
    expiresAt: Number.isNaN(expiresAtMs) ? undefined : new Date(expiresAtMs),
  };
}

/** Decodes a JWS payload segment. Transport trust comes from TLS to Apple;
 * full x5c chain verification stays with Apple's SignedDataVerifier as a
 * later hardening step. */
function decodeJwsPayload<T>(jws: string): T {
  const payloadPart = jws.split(".")[1];
  if (!payloadPart) {
    throw new Error("Malformed JWS: no payload segment.");
  }
  return JSON.parse(Buffer.from(payloadPart, "base64url").toString("utf8")) as T;
}

function isTransactionNotFound(e: unknown): boolean {
  const label = String(e);
  return label.includes("4040010") || label.includes("TransactionIdNotFound");
}

function appleClients(): AppStoreServerAPIClient[] {
  const issuerId = requireSecret(
    appleIapIssuerId.value(),
    "APPLE_IAP_ISSUER_ID",
  );
  const keyId = requireSecret(appleIapKeyId.value(), "APPLE_IAP_KEY_ID");
  const encodedKey = Buffer.from(appleIapPrivateKeyP8.value()).toString("base64");

  // Official guidance for environment resolution without prior knowledge:
  // call production first; on TransactionIdNotFound (4040010), retry sandbox.
  return [
    new AppStoreServerAPIClient(
      encodedKey,
      keyId,
      issuerId,
      IOS_BUNDLE_ID,
      Environment.PRODUCTION,
    ),
    new AppStoreServerAPIClient(
      encodedKey,
      keyId,
      issuerId,
      IOS_BUNDLE_ID,
      Environment.SANDBOX,
    ),
  ];
}

interface JwsTransactionDecodedPayloadShape {
  productId?: string;
  originalTransactionId?: string;
  transactionId?: string;
  /** Milliseconds since epoch per Apple's JWS docs. */
  expiresDate?: number | string;
}

async function evaluateAppleReceipt(
  transactionId: string,
): Promise<EntitlementDecision> {
  try {
    let signedTxInfo = "";
    let originalTransactionId = "";

    for (const client of appleClients()) {
      try {
        const info = await client.getTransactionInfo(transactionId);
        signedTxInfo = info.signedTransactionInfo ?? "";
        if (!signedTxInfo) continue;
        const decoded = decodeJwsPayload<JwsTransactionDecodedPayloadShape>(
          signedTxInfo,
        );
        originalTransactionId = decoded.originalTransactionId ?? "";
        break;
      } catch (e) {
        if (!isTransactionNotFound(e)) throw e;
      }
    }
    if (!originalTransactionId) {
      throw new Error("Transaction not found in production or sandbox.");
    }

    let statusResponse:
      | Awaited<
          ReturnType<
            AppStoreServerAPIClient["getAllSubscriptionStatuses"]
          >
        >
      | undefined;

    for (const client of appleClients()) {
      try {
        statusResponse = await client.getAllSubscriptionStatuses(
          originalTransactionId,
        );
        break;
      } catch (e) {
        if (!isTransactionNotFound(e)) throw e;
      }
    }
    if (!statusResponse) {
      throw new Error("Subscription statuses not found in either environment.");
    }

    const entries =
      statusResponse.data?.flatMap(
        (group) => group.lastTransactions ?? [],
      ) ?? [];

    for (const entry of entries) {
      if (!entry.signedTransactionInfo) continue;
      const payload = decodeJwsPayload<JwsTransactionDecodedPayloadShape>(
        entry.signedTransactionInfo,
      );
      if (!payload.productId || !IOS_PREMIUM_PRODUCT_IDS.has(payload.productId)) {
        continue;
      }

      const rawExpiry = payload.expiresDate;
      const expiresAtMs =
        typeof rawExpiry === "number"
          ? rawExpiry
          : typeof rawExpiry === "string"
            ? Number(rawExpiry)
            : Number.NaN;

      return {
        grants: GRANTING_APPLE_STATUSES.has(entry.status ?? -1),
        stateLabel: `APPLE_STATUS_${entry.status}`,
        expiresAt:
          !Number.isNaN(expiresAtMs) && expiresAtMs > 0
            ? new Date(expiresAtMs)
            : undefined,
        receiptKey: `ios_${payload.originalTransactionId ?? originalTransactionId}`,
      };
    }

    return { grants: false, stateLabel: "NO_PREMIUM_PRODUCT" };
  } catch (e) {
    logger.error("verifyPremiumPurchase: App Store lookup failed", e);
    throw new HttpsError(
      "failed-precondition",
      "The purchase receipt could not be verified with the App Store.",
    );
  }
}

/**
 * Verifies a store purchase reference and records premium entitlement.
 *
 * Clients may never write isPremium themselves: firestore.rules pins it on
 * user docs, so this callable (Admin SDK, which bypasses rules) is the only
 * writer. Idempotent by construction — every call re-reads the truth from
 * the store and converges local state onto it.
 */
export const verifyPremiumPurchase = onCall(
  {
    secrets: [
      playServiceAccountJson,
      appleIapIssuerId,
      appleIapKeyId,
      appleIapPrivateKeyP8,
    ],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in to verify a purchase.");
    }

    const platform = request.data?.platform;
    const purchaseToken =
      typeof request.data?.purchaseToken === "string"
        ? request.data.purchaseToken.trim()
        : "";
    const transactionId =
      typeof request.data?.transactionId === "string"
        ? request.data.transactionId.trim()
        : "";

    let decision: EntitlementDecision;
    let receiptKey: string;

    if (platform === "android") {
      if (!purchaseToken) {
        throw new HttpsError(
          "invalid-argument",
          "purchaseToken is required for Android receipts.",
        );
      }
      decision = await evaluateAndroidReceipt(purchaseToken);
      receiptKey = `android_${purchaseToken}`;
    }  else if (platform === "ios") {
      if (!transactionId) {
        throw new HttpsError(
          "invalid-argument",
          "transactionId is required for iOS receipts.",
        );
      }
      decision = await evaluateAppleReceipt(transactionId);
      receiptKey = decision.receiptKey ?? `ios_${transactionId}`;
    }  else {
      throw new HttpsError(
        "invalid-argument",
        "platform must be 'android' or 'ios'.",
      );
    }

    const userRef = db.collection("users").doc(uid);
    const receiptRef = db.collection("premium_receipts").doc(receiptKey);

    try {
      await db.runTransaction(async (txn) => {
        const receiptSnap = await txn.get(receiptRef);
        if (receiptSnap.exists && receiptSnap.data()?.uid !== uid) {
          // One store purchase funds one account.
          throw new HttpsError(
            "permission-denied",
            "This purchase is already linked to another account.",
          );
        }
        txn.set(
          receiptRef,
          {
            uid,
            platform,
            entitlementState: decision.stateLabel,
            verifiedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        const updates: Record<string, unknown> = {
          premiumEntitlementStatus: decision.grants
            ? "active"
            : "verification_failed",
          premiumVerifiedAt: FieldValue.serverTimestamp(),
          premiumUpdatedAt: FieldValue.serverTimestamp(),
          premiumVerificationRequired: FieldValue.delete(),
        };

        if (decision.grants) {
          updates.isPremium = true;
          updates.premiumSubscriptionState = decision.stateLabel;
          if (decision.expiresAt) {
            updates.premiumExpiresAt = Timestamp.fromDate(decision.expiresAt);
          }
        }
        // Non-granting outcomes never touch isPremium so an expired receipt
        // cannot revoke an entitlement held through a newer valid one.

        txn.update(userRef, updates);
      });
    } catch (e) {
      if (e instanceof HttpsError) throw e;
      logger.error("verifyPremiumPurchase: entitlement write failed", e);
      throw new HttpsError(
        "internal",
        "Could not record your entitlement. Please retry.",
      );
    }

    logger.info("verifyPremiumPurchase: ok", {
      uid,
      platform,
      state: decision.stateLabel,
      granted: decision.grants,
    });
    return {
      status: decision.grants ? "active" : "not_active",
      platformState: decision.stateLabel,
    };
  },
);
