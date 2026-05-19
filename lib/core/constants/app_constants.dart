/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SportConnect';
  static const String appVersion = '1.1.22';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ridesCollection = 'rides';
  static const String eventsCollection = 'events';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  static const String notificationsCollection = 'notifications';
  static const String vehiclesCollection = 'vehicles';
  static const String paymentsCollection = 'payments';
  static const String payoutsCollection = 'payouts';
  static const String reviewsCollection = 'reviews';
  static const String reportsCollection = 'reports';
  static const String bookingsCollection = 'bookings';
  static const String supportTicketsCollection = 'support_tickets';
  static const String connectedAccountsCollection = 'driver_connected_accounts';
  static const String driverStatsCollection = 'driver_stats';
  static const String typingCollection = 'typing';
  static const String blockedUsersCollection = 'blockedUsers';
  static const String disputesCollection = 'disputes';
  static const String archivedTransactionsCollection = 'archived_transactions';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  static const String vehicleImagesPath = 'vehicle_images';

  // Pagination
  static const int pageSize = 20;
  static const int maxSearchRadius = 50; // km

  // Map Settings
  static const double defaultZoom = 13;
  static const double minZoom = 3;
  static const double maxZoom = 18;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);
  static const Duration httpConnectTimeout = Duration(seconds: 15);
  static const Duration httpReceiveTimeout = Duration(seconds: 15);

  // External API URLs
  static const String osrmBaseUrl = 'https://router.project-osrm.org';
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String overpassApiUrl =
      'https://overpass-api.de/api/interpreter';
  static const String hostingDomain = 'sportaxitrip.com';
  static const String userAgent = 'SportConnect/1.0 (contact@sportconnect.app)';

  // Map tile URLs
  static const String osmStandardTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmHotTileUrl =
      'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
  static const String openTopoTileUrl =
      'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
  static const String cartoDarkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  static const String cartoLightTileUrl =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  static const String stadiaDarkTileUrl =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';
  static const String stadiaWatercolorTileUrl =
      'https://tiles.stadiamaps.com/tiles/stamen_watercolor/{z}/{x}/{y}.jpg';
  static const String arcgisSatelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
}
