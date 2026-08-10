import { FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";
import Stripe from "stripe";
import { StripeAccount, StripeClient } from "./types";

export function asRecord(value: unknown): Record<string, unknown> | undefined {
  if (typeof value !== "object" || value === null) return undefined;
  return value as Record<string, unknown>;
}

export const finiteNumber = (value: unknown): number | undefined =>
  typeof value === "number" && Number.isFinite(value) ? value : undefined;

export function getStripeClient(secretKey: string): StripeClient {
  return new Stripe(secretKey, {
    apiVersion: "2026-04-22.dahlia",
    typescript: true,
  });
}

export function stripeObjectId(value: unknown): string | null {
  if (typeof value === "string" && value.trim().length > 0) {
    return value.trim();
  }

  const record = asRecord(value);
  const id = record?.id;
  return typeof id === "string" && id.trim().length > 0 ? id.trim() : null;
}

export function stringOrEmpty(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function getPaymentIntentIdFromRefund(refund: {
  payment_intent: unknown;
}): string | null {
  return stripeObjectId(refund.payment_intent);
}

export function findDriverIdForConnectedAccount(
  db: Firestore,
  connectedAccountId: string | undefined,
): Promise<string | null> {
  if (!connectedAccountId) return Promise.resolve(null);

  return db
    .collection("driver_connected_accounts")
    .where("stripeAccountId", "==", connectedAccountId)
    .limit(1)
    .get()
    .then((snap) => snap.docs[0]?.id ?? null);
}

export function sumBalanceForCurrency(
  entries:
    | Array<{ amount?: number | null; currency?: string | null }>
    | undefined,
  preferredCurrency: string,
): number {
  if (!entries || entries.length === 0) return 0;

  const normalizedPreferredCurrency = preferredCurrency.toLowerCase();
  const preferredEntries = entries.filter(
    (entry) =>
      (entry.currency ?? "").toLowerCase() === normalizedPreferredCurrency,
  );
  const selectedCurrency =
    preferredEntries.length > 0
      ? normalizedPreferredCurrency
      : (entries[0]?.currency ?? "").toLowerCase();

  return entries
    .filter(
      (entry) => (entry.currency ?? "").toLowerCase() === selectedCurrency,
    )
    .reduce((sum, entry) => sum + (entry.amount ?? 0), 0);
}

export function mapStripeCapabilityStatus(
  value: string | null | undefined,
): "active" | "inactive" | "pending" {
  if (value === "active" || value === "inactive" || value === "pending") {
    return value;
  }
  return "inactive";
}

export function mapStripeDisabledReason(
  value: string | null | undefined,
): string | null {
  switch (value) {
    case "action_required.requested_capabilities":
      return "actionRequiredRequestedCapabilities";
    case "listed":
      return "listed";
    case "other":
      return "other";
    case "platform_paused":
      return "platformPaused";
    case "rejected.fraud":
      return "rejectedFraud";
    case "rejected.incomplete_verification":
      return "rejectedIncompleteVerification";
    case "rejected.listed":
      return "rejectedListed";
    case "rejected.other":
      return "rejectedOther";
    case "rejected.platform_fraud":
      return "rejectedPlatformFraud";
    case "rejected.platform_other":
      return "rejectedPlatformOther";
    case "rejected.platform_terms_of_service":
      return "rejectedPlatformTermsOfService";
    case "rejected.terms_of_service":
      return "rejectedTermsOfService";
    case "requirements.past_due":
      return "requirementsPastDue";
    case "requirements.pending_verification":
      return "requirementsPendingVerification";
    case "under_review":
      return "underReview";
    default:
      return null;
  }
}

export function buildAccountHolderName(account: StripeAccount): string | null {
  const first = account.individual?.first_name?.trim() ?? "";
  const last = account.individual?.last_name?.trim() ?? "";
  const full = `${first} ${last}`.trim();

  if (full) return full;

  const businessName = account.business_profile?.name?.trim();
  if (businessName) return businessName;

  return null;
}

export async function getCompletedRideIds(
  db: Firestore,
  rideIds: string[],
): Promise<Set<string>> {
  const completedRideIds = new Set<string>();
  const uniqueRideIds = [...new Set(rideIds.filter((id) => id.length > 0))];

  for (let index = 0; index < uniqueRideIds.length; index += 100) {
    const chunk = uniqueRideIds.slice(index, index + 100);
    const refs = chunk.map((rideId) => db.collection("rides").doc(rideId));
    const snapshots = await db.getAll(...refs);
    snapshots.forEach((snapshot) => {
      if (snapshot.data()?.status === "completed") {
        completedRideIds.add(snapshot.id);
      }
    });
  }

  return completedRideIds;
}

async function getConnectedAccountBalances(
  stripe: StripeClient,
  accountId: string,
  preferredCurrency: string,
): Promise<{
  availableBalanceInCents: number;
  pendingBalanceInCents: number;
}> {
  try {
    const balance = await stripe.balance.retrieve(
      {},
      { stripeAccount: accountId },
    );

    const instantAvailableField = (balance.instant_available ??
      balance.available) as typeof balance.available;

    const instantAvailableInCents = sumBalanceForCurrency(
      instantAvailableField,
      preferredCurrency,
    );
    const pendingInCents = sumBalanceForCurrency(
      balance.pending,
      preferredCurrency,
    );

    return {
      availableBalanceInCents: instantAvailableInCents,
      pendingBalanceInCents: Math.max(
        0,
        pendingInCents - instantAvailableInCents,
      ),
    };
  } catch {
    return {
      availableBalanceInCents: 0,
      pendingBalanceInCents: 0,
    };
  }
}

export async function syncConnectedAccountSnapshot(
  db: Firestore,
  stripe: StripeClient,
  account: StripeAccount,
  userId: string,
  opts?: {
    availableBalanceInCents?: number;
    pendingBalanceInCents?: number;
  },
): Promise<void> {
  const defaultCurrency = (account.default_currency ?? "eur").toUpperCase();
  const preferredCurrency = defaultCurrency.toLowerCase();
  const accountHolderName = buildAccountHolderName(account);

  const transfersActive = account.capabilities?.transfers === "active";
  const isActive =
    Boolean(account.charges_enabled) &&
    Boolean(account.payouts_enabled) &&
    Boolean(account.details_submitted) &&
    transfersActive;

  let onboardingStatus = "pending";
  if (isActive) {
    onboardingStatus = "active";
  } else if ((account.requirements?.past_due?.length ?? 0) > 0) {
    onboardingStatus = "restricted";
  } else if (
    (account.requirements?.currently_due?.length ?? 0) > 0 ||
    (account.requirements?.pending_verification?.length ?? 0) > 0
  ) {
    onboardingStatus = "incomplete";
  } else if (account.details_submitted) {
    onboardingStatus = "under_review";
  }

  const balances =
    opts?.availableBalanceInCents != null && opts?.pendingBalanceInCents != null
      ? {
          availableBalanceInCents: opts.availableBalanceInCents,
          pendingBalanceInCents: opts.pendingBalanceInCents,
        }
      : await getConnectedAccountBalances(
          stripe,
          account.id,
          preferredCurrency,
        );

  const requirements = {
    currentlyDue: account.requirements?.currently_due ?? [],
    eventuallyDue: account.requirements?.eventually_due ?? [],
    pastDue: account.requirements?.past_due ?? [],
    pendingVerification: account.requirements?.pending_verification ?? [],
    currentDeadline: account.requirements?.current_deadline
      ? new Date(account.requirements.current_deadline * 1000)
      : null,
    disabledReason: mapStripeDisabledReason(
      account.requirements?.disabled_reason,
    ),
  };

  const futureRequirements = {
    currentlyDue: account.future_requirements?.currently_due ?? [],
    eventuallyDue: account.future_requirements?.eventually_due ?? [],
    pastDue: account.future_requirements?.past_due ?? [],
    pendingVerification:
      account.future_requirements?.pending_verification ?? [],
    currentDeadline: account.future_requirements?.current_deadline
      ? new Date(account.future_requirements.current_deadline * 1000)
      : null,
    disabledReason: mapStripeDisabledReason(
      account.future_requirements?.disabled_reason,
    ),
  };

  await db
    .collection("users")
    .doc(userId)
    .set(
      {
        stripeAccountId: account.id,
        stripeAccountStatus: onboardingStatus,
        chargesEnabled: account.charges_enabled ?? false,
        payoutsEnabled: account.payouts_enabled ?? false,
        detailsSubmitted: account.details_submitted ?? false,
        isStripeEnabled: account.charges_enabled ?? false,
        isStripeOnboarded: isActive,
        stripeRequirements: requirements.currentlyDue,
        stripeDisabledReason: requirements.disabledReason,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  const connectedAccountRef = db
    .collection("driver_connected_accounts")
    .doc(userId);
  const existingSnapshot = await connectedAccountRef.get();

  await connectedAccountRef.set(
    {
      driverId: userId,
      stripeAccountId: account.id,
      email: account.email ?? "",
      country: account.country ?? "FR",
      defaultCurrency,
      chargesEnabled: account.charges_enabled ?? false,
      payoutsEnabled: account.payouts_enabled ?? false,
      detailsSubmitted: account.details_submitted ?? false,
      onboardingCompleted: isActive,
      ...(isActive && { onboardingCompletedAt: FieldValue.serverTimestamp() }),
      accountHolderName,
      capabilities: {
        transfers: mapStripeCapabilityStatus(account.capabilities?.transfers),
        cardPayments: mapStripeCapabilityStatus(
          account.capabilities?.card_payments,
        ),
      },
      requirements,
      futureRequirements,
      availableBalanceInCents: balances.availableBalanceInCents,
      pendingBalanceInCents: balances.pendingBalanceInCents,
      updatedAt: FieldValue.serverTimestamp(),
      ...(existingSnapshot.exists
        ? {}
        : { createdAt: FieldValue.serverTimestamp() }),
      metadata: {
        stripeBusinessType: account.business_type ?? null,
        stripeDefaultCurrency: defaultCurrency,
      },
    },
    { merge: true },
  );
}

async function getConnectAccountBalanceTotalCents(
  stripe: StripeClient,
  stripeAccountId: string,
): Promise<number> {
  const balance = await stripe.balance.retrieve(
    {},
    { stripeAccount: stripeAccountId },
  );
  const entries = [...(balance.available ?? []), ...(balance.pending ?? [])];
  return entries.reduce((sum, entry) => sum + (entry.amount ?? 0), 0);
}

async function hasPendingStripePayout(
  stripe: StripeClient,
  stripeAccountId: string,
): Promise<boolean> {
  const payouts = await stripe.payouts.list(
    { limit: 10 },
    { stripeAccount: stripeAccountId },
  );
  return payouts.data.some(
    (p) => p.status === "pending" || p.status === "in_transit",
  );
}

async function hasOpenDisputeForDriver(
  db: Firestore,
  driverId: string,
): Promise<boolean> {
  const paymentsSnap = await db
    .collection("payments")
    .where("driverId", "==", driverId)
    .limit(200)
    .get();
  const rideIds = [
    ...new Set(
      paymentsSnap.docs
        .map((d) => d.data().rideId)
        .filter(
          (id): id is string => typeof id === "string" && id.trim().length > 0,
        ),
    ),
  ];
  if (rideIds.length === 0) return false;

  for (let index = 0; index < rideIds.length; index += 10) {
    const chunk = rideIds.slice(index, index + 10);
    const disputesSnap = await db
      .collection("disputes")
      .where("rideId", "in", chunk)
      .get();
    const openDispute = disputesSnap.docs.some((d) => {
      const status = (d.data().status as string | undefined) ?? "open";
      return status !== "resolved" && status !== "closed";
    });
    if (openDispute) return true;
  }
  return false;
}

async function flagStripeAccountForManualCleanup(
  db: Firestore,
  uid: string,
  stripeAccountId: string,
  reason: string,
): Promise<void> {
  await db.collection("pending_stripe_cleanups").doc(uid).set(
    {
      uid,
      stripeAccountId,
      reason,
      flaggedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

export async function recomputeDriverStats(
  db: Firestore,
  driverId: string,
  earningsDelta?: number,
  ridesDelta?: number,
): Promise<void> {
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const weekStart = new Date(todayStart);
  const daysSinceMonday = (todayStart.getDay() + 6) % 7;
  weekStart.setDate(todayStart.getDate() - daysSinceMonday);
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const yearStart = new Date(now.getFullYear(), 0, 1);

  const paymentsSnap = await db
    .collection("payments")
    .where("driverId", "==", driverId)
    .where("status", "==", "succeeded")
    .get();
  const rideIds = [
    ...new Set(
      paymentsSnap.docs
        .map((doc) => doc.data().rideId)
        .filter(
          (rideId): rideId is string =>
            typeof rideId === "string" && rideId.trim().length > 0,
        ),
    ),
  ];
  const completedRideIds = await getCompletedRideIds(db, rideIds);

  let totalEarningsInCents = 0;
  let totalPlatformFeesInCents = 0;
  let totalStripeFeesInCents = 0;
  let earningsTodayInCents = 0;
  let earningsThisWeekInCents = 0;
  let earningsThisMonthInCents = 0;
  let earningsThisYearInCents = 0;
  let totalPlatformFees = 0;
  let totalStripeFees = 0;
  let earningsToday = 0;
  let earningsThisWeek = 0;
  let earningsThisMonth = 0;
  let earningsThisYear = 0;
  let ridesToday = 0;
  let ridesThisWeek = 0;
  let ridesThisMonth = 0;
  let ridesThisYear = 0;
  let completedPaymentCount = 0;
  let lastRideAt: Date | null = null;

  for (const doc of paymentsSnap.docs) {
    const data = doc.data();
    const rideId = typeof data.rideId === "string" ? data.rideId : "";
    if (!completedRideIds.has(rideId)) continue;
    completedPaymentCount += 1;

    const earningsCents =
      finiteNumber(data.driverEarningsInCents) ??
      Math.round((finiteNumber(data.driverEarnings) ?? 0) * 100);
    const platformFeeCents =
      finiteNumber(data.platformFeeInCents) ??
      Math.round((finiteNumber(data.platformFee) ?? 0) * 100);
    const stripeFeeCents =
      finiteNumber(data.stripeFeeInCents) ??
      Math.round((finiteNumber(data.stripeFee) ?? 0) * 100);
    const earnings = earningsCents / 100;
    const platformFee = platformFeeCents / 100;
    const stripeFee = stripeFeeCents / 100;
    const completedAt =
      (data.rideCompletedAt as Timestamp | null)?.toDate() ??
      (data.completedAt as Timestamp | null)?.toDate() ??
      (data.createdAt as Timestamp | null)?.toDate();

    totalEarningsInCents += earningsCents;
    totalPlatformFeesInCents += platformFeeCents;
    totalStripeFeesInCents += stripeFeeCents;
    totalPlatformFees += platformFee;
    totalStripeFees += stripeFee;

    if (completedAt) {
      if (!lastRideAt || completedAt > lastRideAt) {
        lastRideAt = completedAt;
      }
      if (completedAt >= yearStart) {
        earningsThisYearInCents += earningsCents;
        earningsThisYear += earnings;
        ridesThisYear += 1;
      }
      if (completedAt >= monthStart) {
        earningsThisMonthInCents += earningsCents;
        earningsThisMonth += earnings;
        ridesThisMonth += 1;
      }
      if (completedAt >= weekStart) {
        earningsThisWeekInCents += earningsCents;
        earningsThisWeek += earnings;
        ridesThisWeek += 1;
      }
      if (completedAt >= todayStart) {
        earningsTodayInCents += earningsCents;
        earningsToday += earnings;
        ridesToday += 1;
      }
    }
  }

  const updates: Record<string, unknown> = {
    driverId,
    totalEarningsInCents,
    totalPlatformFeesInCents,
    totalStripeFeesInCents,
    earningsTodayInCents,
    earningsThisWeekInCents,
    earningsThisMonthInCents,
    earningsThisYearInCents,
    totalRides: completedPaymentCount,
    totalPlatformFees,
    totalStripeFees,
    totalEarnings: totalEarningsInCents / 100,
    earningsToday,
    earningsThisWeek,
    earningsThisMonth,
    earningsThisYear,
    ridesToday,
    ridesThisWeek,
    ridesThisMonth,
    ridesThisYear,
    lastUpdatedAt: FieldValue.serverTimestamp(),
  };

  if (lastRideAt) {
    updates.lastRideAt = Timestamp.fromDate(lastRideAt);
  }

  await db
    .collection("driver_stats")
    .doc(driverId)
    .set(updates, { merge: true });
}

export async function cleanupStripeForDeletedUser(
  db: Firestore,
  stripe: StripeClient,
  uid: string,
): Promise<void> {
  const [userDoc, connectedAccountDoc] = await Promise.all([
    db.collection("users").doc(uid).get(),
    db.collection("driver_connected_accounts").doc(uid).get(),
  ]);
  const userData = userDoc.data();
  const connectedAccountData = connectedAccountDoc.data();

  const stripeCustomerId =
    typeof userData?.stripeCustomerId === "string" &&
    userData.stripeCustomerId.trim().length > 0
      ? userData.stripeCustomerId.trim()
      : undefined;
  if (stripeCustomerId) {
    await stripe.customers.del(stripeCustomerId);
  }

  const connectedAccountId =
    typeof connectedAccountData?.stripeAccountId === "string" &&
    connectedAccountData.stripeAccountId.trim().length > 0
      ? connectedAccountData.stripeAccountId.trim()
      : undefined;
  const stripeAccountId =
    connectedAccountId ??
    (typeof userData?.stripeAccountId === "string" &&
    userData.stripeAccountId.trim().length > 0
      ? userData.stripeAccountId.trim()
      : undefined);

  if (!stripeAccountId) return;

  const [balanceTotalCents, pendingPayout, openDispute] = await Promise.all([
    getConnectAccountBalanceTotalCents(stripe, stripeAccountId),
    hasPendingStripePayout(stripe, stripeAccountId),
    hasOpenDisputeForDriver(db, uid),
  ]);

  if (balanceTotalCents !== 0 || pendingPayout || openDispute) {
    const reasons = [
      balanceTotalCents !== 0
        ? `non-zero balance (${balanceTotalCents} cents)`
        : null,
      pendingPayout ? "pending payout" : null,
      openDispute ? "open dispute" : null,
    ].filter((reason): reason is string => reason !== null);

    await flagStripeAccountForManualCleanup(
      db,
      uid,
      stripeAccountId,
      reasons.join(", "),
    );
    return;
  }

  await stripe.accounts.del(stripeAccountId);
}

export async function cleanupVehiclesForDeletedUser(
  db: Firestore,
  storage: {
    bucket(): { deleteFiles(options: { prefix: string }): Promise<void> };
  },
  uid: string,
): Promise<void> {
  const vehiclesSnap = await db
    .collection("vehicles")
    .where("ownerId", "==", uid)
    .get();
  if (vehiclesSnap.empty) return;

  const bucket = storage.bucket();
  for (const doc of vehiclesSnap.docs) {
    await bucket.deleteFiles({ prefix: `vehicles/${doc.id}/` });
  }

  const docs = vehiclesSnap.docs;
  for (let index = 0; index < docs.length; index += 499) {
    const chunk = docs.slice(index, index + 499);
    const batch = db.batch();
    chunk.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
}

export async function cleanupNotificationsForDeletedUser(
  db: Firestore,
  uid: string,
): Promise<void> {
  let totalDeleted = 0;
  for (;;) {
    const snap = await db
      .collection("notifications")
      .where("userId", "==", uid)
      .limit(400)
      .get();
    if (snap.empty) break;
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    totalDeleted += snap.size;
    if (snap.size < 400) break;
  }
}

export async function cleanupEventParticipationForDeletedUser(
  db: Firestore,
  uid: string,
): Promise<void> {
  const eventsSnap = await db
    .collection("events")
    .where("participantIds", "array-contains", uid)
    .get();
  if (eventsSnap.empty) return;

  const docs = eventsSnap.docs;
  for (let index = 0; index < docs.length; index += 499) {
    const chunk = docs.slice(index, index + 499);
    const batch = db.batch();
    chunk.forEach((doc) => {
      batch.update(doc.ref, {
        participantIds: FieldValue.arrayRemove(uid),
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    await batch.commit();
  }
}

export async function anonymizeReviewsForDeletedUser(
  db: Firestore,
  uid: string,
): Promise<void> {
  const reviewsSnap = await db
    .collection("reviews")
    .where("revieweeId", "==", uid)
    .get();
  if (reviewsSnap.empty) return;

  const docs = reviewsSnap.docs;
  for (let index = 0; index < docs.length; index += 499) {
    const chunk = docs.slice(index, index + 499);
    const batch = db.batch();
    chunk.forEach((doc) => {
      batch.update(doc.ref, {
        revieweeName: "Deleted user",
        revieweePhotoUrl: null,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    await batch.commit();
  }
}
