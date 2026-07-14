/// simple route definition holder
class AppRoute {
  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}

class AppRoutes {
  static const splash = AppRoute('/', 'splash');
  static const onboarding = AppRoute('/onboarding', 'onboarding');
  static const login = AppRoute('/login', 'login');
  static const signupWizard = AppRoute('/signup', 'signup-wizard');
  static const roleSelection = AppRoute('/role-selection', 'role-selection');
  static const riderOnboarding = AppRoute(
    '/rider/onboarding',
    'rider-onboarding',
  );

  // Driver Routes
  static const driverOnboarding = AppRoute(
    '/driver/onboarding',
    'driver-onboarding',
  );
  static const driverHome = AppRoute('/driver', 'driver-home');
  static const driverRides = AppRoute('/driver/rides', 'driver-rides');
  static const driverEarnings = AppRoute('/driver/earnings', 'driver-earnings');
  static const driverRequests = AppRoute('/driver/requests', 'driver-requests');
  // Shell branch tab (no :id — own profile)
  static const driverProfileTab = AppRoute(
    '/driver/profile',
    'driver-profile-tab',
  );
  // Deep-link to another driver's profile (has :id param)
  static const driverProfile = AppRoute(
    '/driver/profile/:id',
    'driver-profile',
  );
  // Driver chat shell branch
  static const driverChat = AppRoute('/driver/chat', 'driver-chat');
  static const driverVehicles = AppRoute('/driver/vehicles', 'driver-vehicles');
  static const driverStripeOnboarding = AppRoute(
    '/driver/stripe-onboarding',
    'driver-stripe-onboarding',
  );
  static const driverActiveRide = AppRoute(
    '/driver/active-ride',
    'driver-active-ride',
  );

  // Rider Routes
  static const riderActiveRide = AppRoute(
    '/rider/active-ride',
    'rider-active-ride',
  );
  static const riderViewRide = AppRoute('/rider/ride/:id', 'rider-view-ride');
  static const riderMyRides = AppRoute('/rider/my-rides', 'rider-my-rides');

  // Shared / General
  static const profileSearch = AppRoute('/profile/search', 'profile-search');
  static const home = AppRoute('/home', 'home');
  static const paymentHistory = AppRoute('/payment-history', 'payment-history');
  static const managePaymentMethods = AppRoute(
    '/payment-methods',
    'manage-payment-methods',
  );
  static const premiumSubscribe = AppRoute(
    '/premium/subscribe',
    'premium-subscribe',
  );
  static const premiumCheckout = AppRoute(
    '/premium/checkout',
    'premium-checkout',
  );
  static const profile = AppRoute('/profile', 'profile');
  static const userProfile = AppRoute('/user/profile/:id', 'user-profile');
  static const editProfile = AppRoute('/edit-profile', 'edit-profile');
  static const settings = AppRoute('/settings', 'settings');
  static const achievements = AppRoute('/achievements', 'achievements');
  static const notifications = AppRoute('/notifications', 'notifications');
  static const notificationPreferences = AppRoute(
    '/settings/notifications',
    'notification-preferences',
  );
  static const adminDashboard = AppRoute('/admin', 'admin-dashboard');

  // Chat
  static const chat = AppRoute('/chat', 'chat');
  static const chatDetail = AppRoute('/chat/detail/:id', 'chat-detail');
  static const chatGroup = AppRoute('/chat/group/:id', 'chat-group');
  static const chatRide = AppRoute('/chat/ride/:id', 'chat-ride');

  // Rides
  static const rideDetail = AppRoute('/ride/detail/:id', 'ride-detail');
  static const searchRides = AppRoute('/ride/search', 'search-rides');
  static const driverOfferRide = AppRoute('/driver/offer', 'driver-offer-ride');
  static const driverViewRide = AppRoute(
    '/driver/ride/:id',
    'driver-view-ride',
  );
  static const driverEditRide = AppRoute(
    '/driver/ride/:id/edit',
    'driver-edit-ride',
  );

  // Auth Recovery
  static const forgotPassword = AppRoute('/forgot-password', 'forgot-password');
  static const emailVerification = AppRoute(
    '/email-verification',
    'email-verification',
  );
  static const changePassword = AppRoute('/change-password', 'change-password');

  // Reviews & Ratings
  static const submitReview = AppRoute('/review/submit', 'submit-review');
  static const reviewsList = AppRoute('/reviews/:userId', 'reviews-list');

  // Ride Lifecycle
  static const rideCompletion = AppRoute(
    '/ride/completion/:id',
    'ride-completion',
  );
  static const cancellationReason = AppRoute(
    '/ride/cancel/:id',
    'cancellation-reason',
  );
  static const dispute = AppRoute('/dispute/:id', 'dispute');

  // Booking lifecycle (passenger)
  static const rideBookingPending = AppRoute(
    '/ride/booking-pending/:rideId',
    'ride-booking-pending',
  );
  static const rideBookingReview = AppRoute(
    '/rides/:rideId/booking-review',
    'ride-booking-review',
  );
  static const rideCountdown = AppRoute(
    '/ride/countdown/:bookingId',
    'ride-countdown',
  );

  // Post-ride rating
  static const driverRatePassenger = AppRoute(
    '/driver/rate-passenger/:rideId',
    'driver-rate-passenger',
  );

  // Support & Legal
  static const helpCenter = AppRoute('/help', 'help-center');
  static const contactSupport = AppRoute('/support', 'contact-support');
  static const reportIssue = AppRoute('/report', 'report-issue');
  static const terms = AppRoute('/legal/terms', 'terms');
  static const privacy = AppRoute('/legal/privacy', 'privacy');
  static const about = AppRoute('/about', 'about');

  // Payment Details
  static const payoutDetail = AppRoute('/payout/:id', 'payout-detail');

  // Events
  static const events = AppRoute('/events', 'events');
  static const eventsBrowse = AppRoute('/events/browse', 'events-browse');
  static const createEvent = AppRoute('/events/create', 'create-event');
  static const myEvents = AppRoute('/events/mine', 'my-events');
  static const eventDetail = AppRoute(
    '/events/detail/:id',
    'event-detail',
  ); // ← /detail/ prefix
  static const eventAttendees = AppRoute(
    '/events/detail/:id/attendees',
    'event-attendees',
  );
  static const editEvent = AppRoute('/events/detail/:id/edit', 'edit-event');
}
