#!/usr/bin/env node
// Run with: node --max-old-space-size=4096 scripts/seed_firebase_emulators.mjs

import { createRequire } from "node:module";

const projectId = process.env.FIREBASE_PROJECT_ID ?? "marathon-connect";
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST ?? "127.0.0.1:8080";
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST ?? "127.0.0.1:9099";
const password = process.env.SEED_PASSWORD ?? "Password123!";
const shouldClean = process.env.SEED_CLEAN === "true";

process.env.FIRESTORE_EMULATOR_HOST = firestoreHost;
process.env.FIREBASE_AUTH_EMULATOR_HOST = authHost;

const require = createRequire(import.meta.url);
const admin = require("../functions/node_modules/firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp({ projectId });
}

const auth = admin.auth();
const db = admin.firestore();

const totals = {
  drivers: Number(process.env.SEED_DRIVERS ?? 240),
  riders: Number(process.env.SEED_RIDERS ?? 760),
  events: Number(process.env.SEED_EVENTS ?? 1500),
  rides: Number(process.env.SEED_RIDES ?? 2200),
  privateChats: Number(process.env.SEED_PRIVATE_CHATS ?? 3500),
};

// Real Firebase Auth accounts are only created for the first N users per role.
// Everyone else gets a deterministic UID — no auth round-trip needed.
const AUTH_ACCOUNTS_PER_ROLE = Number(process.env.SEED_AUTH_ACCOUNTS ?? 10);

const firstNames = [
  "Emma",
  "Lucas",
  "Léa",
  "Hugo",
  "Chloé",
  "Gabriel",
  "Manon",
  "Louis",
  "Camille",
  "Jules",
  "Sarah",
  "Nathan",
  "Inès",
  "Théo",
  "Jade",
  "Raphaël",
  "Louise",
  "Adam",
  "Alice",
  "Paul",
];

const lastNames = [
  "Martin",
  "Bernard",
  "Dubois",
  "Thomas",
  "Robert",
  "Petit",
  "Durand",
  "Leroy",
  "Moreau",
  "Simon",
  "Laurent",
  "Lefèvre",
];

const locations = [
  {
    city: "Paris",
    country: "France",
    latitude: 48.8566,
    longitude: 2.3522,
    places: [
      "Stade de France, Saint-Denis",
      "Bois de Boulogne, Paris",
      "Champ de Mars, Paris",
      "Jardin du Luxembourg, Paris",
      "Parc des Buttes-Chaumont, Paris",
    ],
  },
  {
    city: "Lyon",
    country: "France",
    latitude: 45.764,
    longitude: 4.8357,
    places: [
      "Parc de la Tête d'Or, Lyon",
      "Berges du Rhône, Lyon",
      "Stade de Gerland, Lyon",
      "Parc de Gerland, Lyon",
    ],
  },
  {
    city: "Marseille",
    country: "France",
    latitude: 43.2965,
    longitude: 5.3698,
    places: [
      "Stade Vélodrome, Marseille",
      "Parc Borély, Marseille",
      "Plage du Prado, Marseille",
    ],
  },
  {
    city: "Bordeaux",
    country: "France",
    latitude: 44.8378,
    longitude: -0.5792,
    places: [
      "Parc Bordelais, Bordeaux",
      "Quais de la Garonne, Bordeaux",
      "Jardin Public, Bordeaux",
    ],
  },
  {
    city: "Toulouse",
    country: "France",
    latitude: 43.6047,
    longitude: 1.4442,
    places: [
      "Prairie des Filtres, Toulouse",
      "Jardin des Plantes, Toulouse",
      "Stadium de Toulouse",
    ],
  },
  {
    city: "Nice",
    country: "France",
    latitude: 43.7102,
    longitude: 7.262,
    places: [
      "Promenade des Anglais, Nice",
      "Parc de la Colline du Château, Nice",
      "Stade Allianz Riviera, Nice",
    ],
  },
];

const vehicles = [
  ["Toyota", "Corolla", "gasoline"],
  ["Hyundai", "Ioniq", "electric"],
  ["Kia", "Niro", "hybrid"],
  ["Tesla", "Model 3", "electric"],
  ["Honda", "Civic", "gasoline"],
  ["Toyota", "Sienna", "hybrid"],
  ["Mercedes-Benz", "Vito", "diesel"],
  ["Nissan", "Leaf", "electric"],
];

function pick(list, index) {
  return list[index % list.length];
}

function slug(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
}

function isoDays(days, hour = 8, minute = 0) {
  const now = new Date();
  const value = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate() + days,
    hour,
    minute,
    0,
    0,
  );
  return value.toISOString();
}

function startOfToday() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function startOfWeek() {
  const today = startOfToday();
  const daysSinceMonday = (today.getDay() + 6) % 7;
  return new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate() - daysSinceMonday,
  );
}

function startOfMonth() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

function dateAt(days, hour = 8, minute = 0) {
  return new Date(isoDays(days, hour, minute));
}

function addHours(value, hours) {
  return new Date(value.getTime() + hours * 60 * 60 * 1000);
}

function locationFor(index, placeIndex = index) {
  const area = pick(locations, index);
  const address = pick(area.places, placeIndex);
  const jitter = ((index % 9) - 4) * 0.006;
  return {
    latitude: Number((area.latitude + jitter).toFixed(6)),
    longitude: Number((area.longitude - jitter).toFixed(6)),
    address,
    city: area.city,
    country: area.country,
    placeId: `seed_place_${slug(address)}`,
  };
}

function toAdminData(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  if (value instanceof Date) return value;
  if (typeof value === "string") {
    if (/^\d{4}-\d{2}-\d{2}T/.test(value)) return new Date(value);
    return value;
  }
  if (Array.isArray(value)) {
    return value.map(toAdminData).filter((item) => item !== undefined);
  }
  if (typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .map(([key, item]) => [key, toAdminData(item)])
        .filter(([, item]) => item !== undefined),
    );
  }
  return value;
}

// ─── Auth ─────────────────────────────────────────────────────────────────────

async function ensureAuthUser(email, displayName) {
  try {
    const user = await auth.createUser({
      email,
      password,
      displayName,
      emailVerified: true,
    });
    return user.uid;
  } catch (error) {
    if (error.code === "auth/email-already-exists") {
      const existing = await auth.getUserByEmail(email);
      return existing.uid;
    }
    throw error;
  }
}

function deterministicUid(role, index) {
  return `seed_${role}_${String(index + 1).padStart(6, "0")}`;
}

// ─── Seed state ───────────────────────────────────────────────────────────────

const seed = {
  users: [],
  drivers: [],
  riders: [],
  vehicles: [],
  events: [],
  rides: [],
  bookings: [],
  chats: [],
  messages: [],
  payments: [],
  reviews: [],
  driverStats: [],
};

// Fast O(1) lookup maps — built after each phase to avoid O(n²) inner loops.
const defaultVehicleByOwner = new Map(); // ownerId → vehicle
const ridesByDriverId = new Map(); // driverId → ride[]
const paymentsByDriverId = new Map(); // driverId → payment[]
const userByUid = new Map(); // uid → user

function baseUser(email, username, role, index) {
  const loc = locationFor(index);
  return {
    uid: "",
    email,
    username,
    photoUrl: `https://i.pravatar.cc/160?u=${encodeURIComponent(email)}`,
    phoneNumber: `+336${String(10000000 + index * 719).slice(0, 8)}`,
    gender:
      index % 3 === 0 ? "female" : index % 3 === 1 ? "male" : "non_binary",
    fcmToken: "",
    address: loc.address,
    latitude: loc.latitude,
    longitude: loc.longitude,
    isEmailVerified: true,
    isBanned: false,
    isPremium: index % 5 === 0,
    blockedUsers: [],
    expertise: pick(["rookie", "intermediate", "advanced", "expert"], index),
    createdAt: isoDays(-120 + (index % 60), 9),
    updatedAt: isoDays(-index % 12, 12),
    role,
  };
}

// ─── Build phases ─────────────────────────────────────────────────────────────

async function buildUsers() {
  const authCount = Math.min(
    AUTH_ACCOUNTS_PER_ROLE,
    Math.max(totals.drivers, totals.riders),
  );

  // Resolve real UIDs for the first N of each role in parallel.
  const driverAuthRequests = Array.from(
    { length: Math.min(AUTH_ACCOUNTS_PER_ROLE, totals.drivers) },
    (_, i) => ({
      i,
      name: `${pick(firstNames, i)} ${pick(lastNames, i + 3)}`,
      email: `seed.driver.${String(i + 1).padStart(2, "0")}@sportconnect.test`,
    }),
  );
  const riderAuthRequests = Array.from(
    { length: Math.min(AUTH_ACCOUNTS_PER_ROLE, totals.riders) },
    (_, i) => ({
      i,
      name: `${pick(firstNames, i + 7)} ${pick(lastNames, i + 11)}`,
      email: `seed.rider.${String(i + 1).padStart(2, "0")}@sportconnect.test`,
    }),
  );

  console.log(
    `Creating ${driverAuthRequests.length + riderAuthRequests.length} real auth accounts (parallel)…`,
  );
  const driverUids = new Map();
  const riderUids = new Map();

  await Promise.all([
    ...driverAuthRequests.map(async ({ i, name, email }) => {
      driverUids.set(i, await ensureAuthUser(email, name));
    }),
    ...riderAuthRequests.map(async ({ i, name, email }) => {
      riderUids.set(i, await ensureAuthUser(email, name));
    }),
  ]);

  // Build driver records.
  for (let i = 0; i < totals.drivers; i++) {
    const name = `${pick(firstNames, i)} ${pick(lastNames, i + 3)}`;
    const email = `seed.driver.${String(i + 1).padStart(2, "0")}@sportconnect.test`;
    const uid = driverUids.get(i) ?? deterministicUid("driver", i);
    const vehicleIds = [0, 1].map(
      (n) => `seed_vehicle_${String(i * 2 + n + 1).padStart(3, "0")}`,
    );
    const user = {
      ...baseUser(email, name, "driver", i),
      uid,
      vehicleIds,
      stripeAccountId: `acct_seed_${String(i + 1).padStart(3, "0")}`,
    };
    seed.users.push(user);
    seed.drivers.push(user);
    userByUid.set(uid, user);
  }

  // Build rider records.
  for (let i = 0; i < totals.riders; i++) {
    const name = `${pick(firstNames, i + 7)} ${pick(lastNames, i + 11)}`;
    const email = `seed.rider.${String(i + 1).padStart(2, "0")}@sportconnect.test`;
    const uid = riderUids.get(i) ?? deterministicUid("rider", i);
    const user = {
      ...baseUser(email, name, "rider", i + 100),
      uid,
      stripeCustomerId: `cus_seed_${String(i + 1).padStart(3, "0")}`,
      isStripeCustomerCreated: true,
    };
    seed.users.push(user);
    seed.riders.push(user);
    userByUid.set(uid, user);
  }
  void authCount; // suppress unused-variable lint
}

function buildVehicles() {
  for (let i = 0; i < seed.drivers.length; i++) {
    const driver = seed.drivers[i];
    for (let n = 0; n < 2; n++) {
      const id = `seed_vehicle_${String(i * 2 + n + 1).padStart(3, "0")}`;
      const [make, model, fuelType] = pick(vehicles, i + n);
      const isDefault = n === 0;
      const vehicle = {
        id,
        ownerId: driver.uid,
        make,
        model,
        year: 2018 + ((i + n) % 7),
        color: pick(
          ["Black", "White", "Silver", "Blue", "Green", "Red"],
          i + n,
        ),
        licensePlate: `SC-${String(i + 10).padStart(3, "0")}-${String.fromCharCode(65 + n)}G`,
        ownerName: driver.username,
        ownerPhotoUrl: driver.photoUrl,
        type: n === 1 && i % 5 === 0 ? "van" : "car",
        capacity: n === 1 && i % 5 === 0 ? 7 : 4,
        fuelType,
        imageUrl: `https://picsum.photos/seed/${id}/640/360`,
        imageUrls: [`https://picsum.photos/seed/${id}/640/360`],
        isActive: isDefault,
        isDefault,
        verificationStatus: i % 6 === 0 ? "pending" : "verified",
        hasAC: true,
        hasCharger: i % 2 === 0,
        hasWifi: i % 4 === 0,
        petsAllowed: i % 3 === 0,
        smokingAllowed: i % 9 === 0,
        hasLuggage: true,
        totalRides: 10 + i * 3,
        averageRating: Number((4.2 + (i % 8) / 10).toFixed(1)),
        createdAt: isoDays(-90 + i),
        updatedAt: isoDays(-3),
      };
      seed.vehicles.push(vehicle);
      if (isDefault) defaultVehicleByOwner.set(driver.uid, vehicle);
    }
  }
}

function buildEvents() {
  for (let i = 0; i < totals.events; i++) {
    const creator = seed.users[i % seed.users.length];
    const startsAt = isoDays(1 + (i % 75), 6 + (i % 12), (i % 4) * 15);
    const participantIds = seed.riders
      .slice(i % 10, (i % 10) + 12)
      .map((u) => u.uid);
    if (i % 4 === 0)
      participantIds.push(seed.drivers[i % seed.drivers.length].uid);
    const rideStatuses = Object.fromEntries(
      participantIds
        .slice(0, 10)
        .map((uid, pIndex) => [
          uid,
          pick(["driving", "need_ride", "self_arranged"], i + pIndex),
        ]),
    );
    const loc = locationFor(i, i + 2);
    seed.events.push({
      id: `seed_event_${String(i + 1).padStart(3, "0")}`,
      creatorId: creator.uid,
      title: `${pick(["Marathon de", "Semi-Marathon de", "10K de", "Trail de", "Foulées de"], i)} ${loc.city}`,
      type: "running",
      location: loc,
      startsAt,
      endsAt: isoDays(1 + (i % 75), 8 + (i % 12), (i % 4) * 15),
      description:
        "Course communautaire avec point de rendez-vous, covoiturage organisé entre coureurs et ambiance conviviale.",
      organizerName: creator.username,
      imageUrl: `https://picsum.photos/seed/seed_event_${i + 1}/900/500`,
      participantIds,
      maxParticipants: 20 + (i % 60),
      isActive: i % 17 !== 0,
      linkedRideIds: [],
      rideStatuses,
      meetupPinLocation: loc,
      chatGroupId: `seed_event_chat_${String(i + 1).padStart(3, "0")}`,
      isRecurring: i % 9 === 0,
      recurringPattern: i % 9 === 0 ? "weekly" : undefined,
      recurringEndDate: i % 9 === 0 ? isoDays(90, 18) : undefined,
      costSplitEnabled: i % 3 === 0,
      createdAt: isoDays(-30 + (i % 20)),
      updatedAt: isoDays(-2),
    });
  }
}

function buildRidesAndBookings() {
  for (let i = 0; i < totals.rides; i++) {
    const driver = seed.drivers[i % seed.drivers.length];
    // O(1) lookup instead of O(n) find
    const vehicle = defaultVehicleByOwner.get(driver.uid) ?? seed.vehicles[0];
    const event = i % 3 === 0 ? seed.events[i % seed.events.length] : null;
    const origin = locationFor(i + 5);
    const destination = event?.location ?? locationFor(i + 11);
    const available = Math.min(vehicle.capacity, 3 + (i % 4));
    const acceptedBookings = i % available;
    const bookingIds = [];
    const tags = [];
    if (
      ["electric", "hybrid", "pluginHybrid", "hydrogen"].includes(
        vehicle.fuelType,
      )
    )
      tags.push("eco");
    if (vehicle.verificationStatus === "verified") tags.push("verified_driver");
    if (vehicle.hasAC || vehicle.hasWifi || vehicle.hasCharger)
      tags.push("premium");

    for (let b = 0; b < acceptedBookings + (i % 5 === 0 ? 1 : 0); b++) {
      const rider = seed.riders[(i + b * 7) % seed.riders.length];
      const id = `seed_booking_${String(seed.bookings.length + 1).padStart(4, "0")}`;
      const status = b < acceptedBookings ? "accepted" : "pending";
      bookingIds.push(id);
      seed.bookings.push({
        id,
        rideId: `seed_ride_${String(i + 1).padStart(4, "0")}`,
        passengerId: rider.uid,
        driverId: driver.uid,
        seatsBooked: 1 + ((i + b) % 2),
        status,
        pickupLocation: origin,
        dropoffLocation: destination,
        note:
          status === "pending"
            ? "Je peux monter à l'entrée principale ?"
            : "Rendez-vous confirmé au point indiqué.",
        createdAt: isoDays(-2 + (b % 3), 10 + b),
        respondedAt: status === "accepted" ? isoDays(-1, 11 + b) : undefined,
        pickupOtp: String(100000 + (((i + b) * 37) % 900000)),
      });
    }

    const rideId = `seed_ride_${String(i + 1).padStart(4, "0")}`;
    const ride = {
      id: rideId,
      driverId: driver.uid,
      route: {
        origin,
        destination,
        waypoints: [],
        distanceKm: Number((4 + (i % 40) * 1.7).toFixed(1)),
        durationMinutes: 18 + (i % 85),
      },
      schedule: {
        departureTime:
          event?.startsAt ?? isoDays(1 + (i % 45), 6 + (i % 14), (i % 4) * 15),
        arrivalTime: undefined,
        flexibilityMinutes: pick([0, 10, 15, 20, 30], i),
        isRecurring: i % 20 === 0,
        recurringDays: i % 20 === 0 ? [1, 3, 5] : [],
        recurringEndDate: i % 20 === 0 ? isoDays(60, 12) : undefined,
      },
      capacity: { available, booked: acceptedBookings },
      pricing: {
        // RidePricing.pricePerSeatInCents is a flat int — must NOT be a nested
        // {amountInCents, currency} object or the Dart model cast crashes.
        pricePerSeatInCents: 500 + (i % 26) * 150,
      },
      preferences: {
        allowPets: i % 4 === 0,
        allowSmoking: i % 15 === 0,
        allowLuggage: i % 5 !== 0,
        isWomenOnly: i % 7 === 0,
        allowChat: true,
        maxDetourMinutes: pick([0, 10, 15, 20, 30, 45], i) || undefined,
      },
      eventId: event?.id,
      eventName: event?.title,
      status: acceptedBookings >= available ? "full" : "active",
      ridePhase: undefined,
      vehicleId: vehicle.id,
      vehicleInfo: `${vehicle.year} ${vehicle.color} ${vehicle.make} ${vehicle.model}`,
      bookingIds,
      bookings: [],
      reviewCount: i % 11,
      averageRating: Number((4 + (i % 10) / 10).toFixed(1)),
      xpReward: 50,
      notes: i % 6 === 0 ? "Seed ride with strict pickup timing." : undefined,
      tags,
      createdAt: isoDays(-8 + (i % 6)),
      updatedAt: isoDays(-1),
    };
    seed.rides.push(ride);

    // Build ridesByDriverId map incrementally.
    const driverRides = ridesByDriverId.get(driver.uid);
    if (driverRides) driverRides.push(ride);
    else ridesByDriverId.set(driver.uid, [ride]);

    if (event) event.linkedRideIds.push(rideId);
  }
}

function chatParticipant(user, isAdmin = false) {
  return {
    uid: user.uid,
    username: user.username,
    photoUrl: user.photoUrl,
    isAdmin,
    isMuted: false,
    lastSeenAt: isoDays(0, 8),
    joinedAt: isoDays(-20, 8),
  };
}

function addChat(chat, messageAuthors) {
  seed.chats.push(chat);
  const bodies = [
    "Je peux venir au point de rendez-vous.",
    "Merci, à très vite !",
    "Tu peux partager le point de rendez-vous exact ?",
    "J'ai quelques minutes de retard mais j'arrive.",
    "C'est confirmé.",
  ];
  for (let i = 0; i < 5; i++) {
    const author = messageAuthors[i % messageAuthors.length];
    seed.messages.push({
      path: `chats/${chat.id}/messages/seed_msg_${String(i + 1).padStart(2, "0")}`,
      data: {
        id: `seed_msg_${String(i + 1).padStart(2, "0")}`,
        chatId: chat.id,
        senderId: author.uid,
        senderName: author.username,
        senderPhotoUrl: author.photoUrl,
        content: bodies[(i + chat.id.length) % bodies.length],
        type: "text",
        status: "read",
        reactions: i === 2 ? { "👍": [messageAuthors[0].uid] } : {},
        readBy: chat.participantIds,
        deliveredTo: chat.participantIds,
        isEdited: false,
        isDeleted: false,
        createdAt: isoDays(-1, 9 + i, i * 7),
      },
    });
  }
}

function buildPaymentsAndStats() {
  const now = new Date();
  const todayStart = startOfToday();
  const weekStart = startOfWeek();
  const monthStart = startOfMonth();
  const yesterday = new Date(
    todayStart.getFullYear(),
    todayStart.getMonth(),
    todayStart.getDate() - 1,
  );
  const twoDaysAgo = new Date(
    todayStart.getFullYear(),
    todayStart.getMonth(),
    todayStart.getDate() - 2,
  );
  const safeWeekDayOne = yesterday >= weekStart ? yesterday : todayStart;
  const safeWeekDayTwo = twoDaysAgo >= weekStart ? twoDaysAgo : safeWeekDayOne;
  const safeMonthDayOne = yesterday >= monthStart ? yesterday : todayStart;
  const safeMonthDayTwo =
    twoDaysAgo >= monthStart ? twoDaysAgo : safeMonthDayOne;
  const paymentDates = [
    new Date(now.getTime() - 2 * 60 * 60 * 1000),
    new Date(now.getTime() - 6 * 60 * 60 * 1000),
    addHours(safeWeekDayOne, 10),
    addHours(safeWeekDayTwo, 14),
    addHours(safeMonthDayOne, 9),
    addHours(safeMonthDayTwo, 16),
    dateAt(-45, 12),
    dateAt(-90, 12),
  ];

  for (let i = 0; i < seed.drivers.length; i++) {
    const driver = seed.drivers[i];
    // O(1) map lookup instead of O(n) filter
    const driverRides = ridesByDriverId.get(driver.uid) ?? [];

    for (let p = 0; p < paymentDates.length; p++) {
      const ride =
        driverRides[p % Math.max(driverRides.length, 1)] ??
        seed.rides[(i + p) % seed.rides.length];
      const rider = seed.riders[(i * 11 + p * 7) % seed.riders.length];
      const seatsBooked = 1 + ((i + p) % 2);
      const amountInCents =
        ride.pricing.pricePerSeatInCents * seatsBooked;
      const platformFeeInCents = Math.round(amountInCents * 0.12);
      const stripeFeeInCents = Math.round(amountInCents * 0.029) + 30;
      const driverEarningsInCents = Math.max(
        0,
        amountInCents - platformFeeInCents - stripeFeeInCents,
      );
      const completedAt = paymentDates[p];
      const id = `seed_payment_${String(seed.payments.length + 1).padStart(5, "0")}`;

      const payment = {
        id,
        rideId: ride.id,
        riderId: rider.uid,
        riderName: rider.username,
        driverId: driver.uid,
        driverName: driver.username,
        amountInCents,
        amount: amountInCents / 100,
        currency: "EUR",
        status: "succeeded",
        platformFeeInCents,
        platformFee: platformFeeInCents / 100,
        driverEarningsInCents,
        driverEarnings: driverEarningsInCents / 100,
        stripeFeeInCents,
        stripeFee: stripeFeeInCents / 100,
        paymentMethodType: pick(["card", "applePay", "googlePay"], i + p),
        paymentMethodLast4: String(1000 + (((i + p) * 137) % 9000)),
        stripePaymentIntentId: `pi_seed_${String(seed.payments.length + 1).padStart(5, "0")}`,
        stripeCustomerId: rider.stripeCustomerId,
        seatsBooked,
        createdAt: new Date(
          completedAt.getTime() - 20 * 60 * 1000,
        ).toISOString(),
        updatedAt: completedAt.toISOString(),
        completedAt: completedAt.toISOString(),
        metadata: {
          seed: true,
          period:
            p < 2
              ? "today"
              : p < 4
                ? "this_week"
                : p < 6
                  ? "this_month"
                  : "older",
        },
      };
      seed.payments.push(payment);

      // Build paymentsByDriverId map incrementally.
      const dp = paymentsByDriverId.get(driver.uid);
      if (dp) dp.push(payment);
      else paymentsByDriverId.set(driver.uid, [payment]);
    }
  }

  for (let i = 0; i < seed.drivers.length; i++) {
    const driver = seed.drivers[i];
    // O(1) map lookup instead of O(n) filter
    const payments = paymentsByDriverId.get(driver.uid) ?? [];
    const totalEarningsInCents = payments.reduce(
      (sum, p) => sum + p.driverEarningsInCents,
      0,
    );
    const totalPlatformFeesInCents = payments.reduce(
      (sum, p) => sum + p.platformFeeInCents,
      0,
    );
    const totalStripeFeesInCents = payments.reduce(
      (sum, p) => sum + p.stripeFeeInCents,
      0,
    );

    const inPeriod = (p, start) => new Date(p.completedAt) >= start;
    const todayPayments = payments.filter((p) => inPeriod(p, todayStart));
    const weekPayments = payments.filter((p) => inPeriod(p, weekStart));
    const monthPayments = payments.filter((p) => inPeriod(p, monthStart));
    const latestPayment = payments
      .map((p) => new Date(p.completedAt))
      .sort((a, b) => b.getTime() - a.getTime())[0];

    // O(1) map lookup for rides (used for distance calc).
    const driverRides = ridesByDriverId.get(driver.uid) ?? [];
    const rideDistanceById = new Map(
      driverRides.map((r) => [r.id, r.route.distanceKm]),
    );

    seed.driverStats.push({
      driverId: driver.uid,
      rating: Number((4.1 + (i % 9) / 10).toFixed(1)),
      totalRides: payments.length,
      ridesToday: todayPayments.length,
      ridesThisWeek: weekPayments.length,
      ridesThisMonth: monthPayments.length,
      pendingRequests: i % 5,
      totalEarningsInCents,
      totalPlatformFeesInCents,
      totalStripeFeesInCents,
      earningsTodayInCents: todayPayments.reduce(
        (sum, p) => sum + p.driverEarningsInCents,
        0,
      ),
      earningsThisWeekInCents: weekPayments.reduce(
        (sum, p) => sum + p.driverEarningsInCents,
        0,
      ),
      earningsThisMonthInCents: monthPayments.reduce(
        (sum, p) => sum + p.driverEarningsInCents,
        0,
      ),
      totalEarnings: totalEarningsInCents / 100,
      totalPlatformFees: totalPlatformFeesInCents / 100,
      totalStripeFees: totalStripeFeesInCents / 100,
      earningsToday:
        todayPayments.reduce((sum, p) => sum + p.driverEarningsInCents, 0) /
        100,
      earningsThisWeek:
        weekPayments.reduce((sum, p) => sum + p.driverEarningsInCents, 0) / 100,
      earningsThisMonth:
        monthPayments.reduce((sum, p) => sum + p.driverEarningsInCents, 0) /
        100,
      totalSpentInCents: 0,
      totalDistance: Number(
        payments
          .reduce((sum, p) => sum + (rideDistanceById.get(p.rideId) ?? 0), 0)
          .toFixed(1),
      ),
      lastRideAt: latestPayment?.toISOString(),
      lastUpdatedAt: new Date().toISOString(),
    });
  }
}

function buildChatsReviewsStats() {
  for (let i = 0; i < totals.privateChats; i++) {
    const driver = seed.drivers[i % seed.drivers.length];
    const rider = seed.riders[(i * 3) % seed.riders.length];
    addChat(
      {
        id: `seed_private_chat_${String(i + 1).padStart(3, "0")}`,
        type: "private",
        participants: [chatParticipant(driver), chatParticipant(rider)],
        participantIds: [driver.uid, rider.uid],
        lastMessageContent: "C'est confirmé.",
        lastMessageSenderId: rider.uid,
        lastMessageSenderName: rider.username,
        lastMessageType: "text",
        lastMessageAt: isoDays(0, 9 + (i % 8)),
        unreadCounts: { [driver.uid]: i % 3, [rider.uid]: (i + 1) % 2 },
        mutedBy: {},
        pinnedBy: i % 6 === 0 ? { [rider.uid]: true } : {},
        deletedAtBy: {},
        clearedAtBy: {},
        isActive: true,
        createdAt: isoDays(-20 + (i % 8)),
        updatedAt: isoDays(0, 9 + (i % 8)),
      },
      [driver, rider],
    );
  }

  for (let i = 0; i < 24; i++) {
    const event = seed.events[i];
    const participants = event.participantIds
      .slice(0, 12)
      .map((id) => userByUid.get(id)) // O(1) map lookup
      .filter(Boolean);
    addChat(
      {
        id: event.chatGroupId,
        type: "eventGroup",
        participants: participants.map((user, index) =>
          chatParticipant(user, index === 0),
        ),
        participantIds: participants.map((user) => user.uid),
        groupName: event.title,
        description: "Seeded event group chat",
        eventId: event.id,
        lastMessageContent: "C'est confirmé.",
        lastMessageSenderId: participants[0]?.uid,
        lastMessageSenderName: participants[0]?.username,
        lastMessageType: "text",
        lastMessageAt: isoDays(0, 13),
        unreadCounts: {},
        mutedBy: {},
        pinnedBy: {},
        deletedAtBy: {},
        clearedAtBy: {},
        isActive: true,
        createdAt: isoDays(-10),
        updatedAt: isoDays(0, 13),
      },
      participants,
    );
  }

  for (let i = 0; i < 40; i++) {
    const ride = seed.rides[i];
    const rider = seed.riders[(i * 5) % seed.riders.length];
    seed.reviews.push({
      id: `seed_review_${String(i + 1).padStart(3, "0")}`,
      rideId: ride.id,
      reviewerId: rider.uid,
      revieweeId: ride.driverId,
      rating: 4 + (i % 2),
      comment: pick(
        [
          "Clean vehicle and clear pickup instructions.",
          "Friendly driver and on-time departure.",
          "Good route knowledge and safe driving.",
          "Helpful coordination before the event.",
        ],
        i,
      ),
      createdAt: isoDays(-15 + (i % 12)),
      updatedAt: isoDays(-14 + (i % 12)),
    });
  }

  buildPaymentsAndStats();
}

// ─── Firestore writes ─────────────────────────────────────────────────────────

// Writes items in chunks of CHUNK_SIZE, closing and reopening the BulkWriter
// between chunks so the internal queue never holds more than CHUNK_SIZE documents
// in memory at once.  This is the key fix for OOM on large datasets.
async function writeBulk(items, pathFn, label) {
  const CHUNK = 5000;
  const total = items.length;
  if (total === 0) {
    console.log(`  ${label}: 0`);
    return;
  }

  for (let offset = 0; offset < total; offset += CHUNK) {
    const end = Math.min(offset + CHUNK, total);
    const writer = db.bulkWriter({ throttling: false });
    writer.onWriteError((err) => err.failedAttempts < 5);

    for (let i = offset; i < end; i++) {
      writer.set(db.doc(pathFn(items[i])), toAdminData(items[i]));
    }
    await writer.close();
    process.stdout.write(`\r  ${label}: ${end}/${total}`);
  }
  process.stdout.write("\n");
}

async function deleteSeedDocs(collection) {
  const snapshot = await db.collection(collection).get();
  const seedDocs = snapshot.docs.filter((doc) => doc.id.startsWith("seed_"));
  const writer = db.bulkWriter({ throttling: false });
  for (const doc of seedDocs) writer.delete(doc.ref);
  await writer.close();
  return seedDocs.length;
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log(`Seeding Firebase emulators for ${projectId}`);
  console.log(`Firestore: ${firestoreHost} | Auth: ${authHost}`);
  console.log(`Totals: ${JSON.stringify(totals)}`);
  console.log(`Real auth accounts: first ${AUTH_ACCOUNTS_PER_ROLE} per role`);
  console.log("");

  if (shouldClean) {
    process.stdout.write("Cleaning previous seed data…");
    const collections = [
      "vehicles",
      "events",
      "rides",
      "bookings",
      "chats",
      "payments",
      "reviews",
      "driver_stats",
    ];
    const deleted = Object.fromEntries(
      await Promise.all(
        collections.map(async (c) => [c, await deleteSeedDocs(c)]),
      ),
    );
    console.log(" done.");
    console.log("Deleted:", deleted);
  } else {
    console.log("Skipping cleanup; deterministic IDs will be overwritten.");
  }

  console.log("\n── Building in-memory data ──");
  const t0 = Date.now();

  await buildUsers();
  console.log(
    `  users: ${seed.users.length} (${seed.drivers.length} drivers, ${seed.riders.length} riders)`,
  );

  buildVehicles();
  console.log(`  vehicles: ${seed.vehicles.length}`);

  buildEvents();
  console.log(`  events: ${seed.events.length}`);

  buildRidesAndBookings();
  console.log(
    `  rides: ${seed.rides.length}, bookings: ${seed.bookings.length}`,
  );

  buildChatsReviewsStats();
  console.log(
    `  chats: ${seed.chats.length}, messages: ${seed.messages.length}`,
  );
  console.log(
    `  payments: ${seed.payments.length}, stats: ${seed.driverStats.length}`,
  );
  console.log(`  Build time: ${((Date.now() - t0) / 1000).toFixed(1)}s\n`);

  console.log(
    "── Writing to Firestore (BulkWriter, sequential, largest-first) ──",
  );
  const t1 = Date.now();
  const counts = {
    authUsers:
      Math.min(AUTH_ACCOUNTS_PER_ROLE, totals.drivers) +
      Math.min(AUTH_ACCOUNTS_PER_ROLE, totals.riders),
    firestoreUsers: seed.users.length,
    vehicles: seed.vehicles.length,
    events: seed.events.length,
    rides: seed.rides.length,
    bookings: seed.bookings.length,
    chats: seed.chats.length,
    messages: seed.messages.length,
    payments: seed.payments.length,
    reviews: seed.reviews.length,
    driverStats: seed.driverStats.length,
  };

  // Sequential writes in descending size order so each freed array reduces
  // peak heap before the next (smaller) collection is written.
  await writeBulk(seed.bookings, (b) => `bookings/${b.id}`, "bookings");
  seed.bookings = [];

  await writeBulk(seed.rides, (r) => `rides/${r.id}`, "rides");
  seed.rides = [];
  ridesByDriverId.clear();

  await writeBulk(seed.payments, (p) => `payments/${p.id}`, "payments");
  seed.payments = [];
  paymentsByDriverId.clear();

  await writeBulk(seed.messages, (m) => m.path, "messages");
  seed.messages = [];

  await writeBulk(seed.events, (e) => `events/${e.id}`, "events");
  seed.events = [];

  await writeBulk(seed.users, (u) => `users/${u.uid}`, "users");
  seed.users = [];
  seed.drivers = [];
  seed.riders = [];
  userByUid.clear();

  await writeBulk(seed.vehicles, (v) => `vehicles/${v.id}`, "vehicles");
  seed.vehicles = [];
  defaultVehicleByOwner.clear();

  await writeBulk(seed.chats, (c) => `chats/${c.id}`, "chats");
  seed.chats = [];

  await writeBulk(
    seed.driverStats,
    (s) => `driver_stats/${s.driverId}`,
    "driver_stats",
  );
  seed.driverStats = [];

  await writeBulk(seed.reviews, (r) => `reviews/${r.id}`, "reviews");
  seed.reviews = [];

  console.log(`\nWrite time: ${((Date.now() - t1) / 1000).toFixed(1)}s`);
  console.log(`Total time: ${((Date.now() - t0) / 1000).toFixed(1)}s`);

  console.log("\nSeed complete.");
  console.table(counts);
  console.log(`\nPassword for all auth accounts: ${password}`);
  console.log("Login accounts (real auth):");
  for (let i = 0; i < Math.min(AUTH_ACCOUNTS_PER_ROLE, 3); i++) {
    console.log(
      `  seed.driver.${String(i + 1).padStart(2, "0")}@sportconnect.test`,
    );
    console.log(
      `  seed.rider.${String(i + 1).padStart(2, "0")}@sportconnect.test`,
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
