import { Firestore } from "firebase-admin/firestore";
import { StripeClient } from "./types";

function asRecord(value: unknown): Record<string, unknown> | undefined {
  if (typeof value !== "object" || value === null) return undefined;
  return value as Record<string, unknown>;
}

const finiteNumber = (value: unknown): number | undefined =>
  typeof value === "number" && Number.isFinite(value) ? value : undefined;

function sumBalanceForCurrency(
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

export function getRidePricePerSeatInCents(
  rideData: Record<string, unknown>,
): number | undefined {
  const pricing = asRecord(rideData.pricing);
  const pricePerSeatInCents = asRecord(pricing?.pricePerSeatInCents);
  const amountInCents = finiteNumber(pricePerSeatInCents?.amountInCents);
  if (amountInCents !== undefined) return Math.round(amountInCents);

  const legacyPricePerSeat = asRecord(pricing?.pricePerSeat);
  const legacyAmountInCents = finiteNumber(legacyPricePerSeat?.amountInCents);
  if (legacyAmountInCents !== undefined) {
    return Math.round(legacyAmountInCents);
  }

  const legacyAmount = finiteNumber(legacyPricePerSeat?.amount);
  if (legacyAmount !== undefined) return Math.round(legacyAmount * 100);

  return undefined;
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

export async function getDriverPayoutEligibilitySnapshot(
  db: Firestore,
  stripe: StripeClient,
  opts: {
    driverId: string;
    stripeAccountId: string;
    currency: string;
    stripeAvailableBalanceInCents?: number;
  },
): Promise<{
  completedEarningsInCents: number;
  activePayoutsInCents: number;
  eligibleBalanceInCents: number;
  stripeAvailableBalanceInCents: number;
  withdrawableBalanceInCents: number;
  blockedPendingRideEarningsInCents: number;
}> {
  const paymentsSnap = await db
    .collection("payments")
    .where("driverId", "==", opts.driverId)
    .where("status", "==", "succeeded")
    .get();
  const rideIds = paymentsSnap.docs
    .map((doc) => doc.data().rideId)
    .filter(
      (rideId): rideId is string =>
        typeof rideId === "string" && rideId.trim().length > 0,
    );
  const completedRideIds = await getCompletedRideIds(db, rideIds);

  let completedEarningsInCents = 0;
  let blockedPendingRideEarningsInCents = 0;

  for (const doc of paymentsSnap.docs) {
    const data = doc.data();
    const amountInCents =
      finiteNumber(data.driverEarningsInCents) ??
      Math.round((finiteNumber(data.driverEarnings) ?? 0) * 100);
    const rideId = typeof data.rideId === "string" ? data.rideId : "";

    if (completedRideIds.has(rideId)) {
      completedEarningsInCents += amountInCents;
    } else {
      blockedPendingRideEarningsInCents += amountInCents;
    }
  }

  const payoutsSnap = await db
    .collection("payouts")
    .where("driverId", "==", opts.driverId)
    .where("status", "in", ["pending", "inTransit", "paid"])
    .get();

  const activePayoutsInCents = payoutsSnap.docs.reduce((sum, doc) => {
    const data = doc.data();
    const amountInCents =
      finiteNumber(data.amountInCents) ??
      Math.round((finiteNumber(data.amount) ?? 0) * 100);
    return sum + amountInCents;
  }, 0);

  let stripeAvailableBalanceInCents = opts.stripeAvailableBalanceInCents;
  if (stripeAvailableBalanceInCents === undefined) {
    const balance = await stripe.balance.retrieve(
      {},
      { stripeAccount: opts.stripeAccountId },
    );
    const instantAvailableField = (balance.instant_available ??
      balance.available) as typeof balance.available;
    stripeAvailableBalanceInCents = sumBalanceForCurrency(
      instantAvailableField,
      opts.currency,
    );
  }

  const eligibleBalanceInCents = Math.max(
    0,
    completedEarningsInCents - activePayoutsInCents,
  );

  return {
    completedEarningsInCents,
    activePayoutsInCents,
    eligibleBalanceInCents,
    stripeAvailableBalanceInCents,
    withdrawableBalanceInCents: Math.max(
      0,
      Math.min(eligibleBalanceInCents, stripeAvailableBalanceInCents),
    ),
    blockedPendingRideEarningsInCents,
  };
}
