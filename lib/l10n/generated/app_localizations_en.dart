// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navRides => 'Rides';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsPushNotificationsDesc =>
      'Receive push notifications for important updates';

  @override
  String get settingsRideReminders => 'Ride Reminders';

  @override
  String get settingsRideRemindersDesc => 'Get reminded about upcoming rides';

  @override
  String get settingsChatMessages => 'Chat Messages';

  @override
  String get settingsChatMessagesDesc => 'Notifications for new messages';

  @override
  String get settingsMarketingTips => 'Marketing & Tips';

  @override
  String get settingsMarketingTipsDesc => 'Receive tips and promotional offers';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeDesc => 'Switch to dark theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'App display language';

  @override
  String get settingsDistanceUnit => 'Distance Unit';

  @override
  String get settingsDistanceUnitDesc => 'Preferred distance measurement';

  @override
  String get settingsPrivacySafety => 'Privacy & Safety';

  @override
  String get settingsPublicProfile => 'Public Profile';

  @override
  String get settingsPublicProfileDesc => 'Allow others to see your profile';

  @override
  String get settingsShowLocation => 'Show Location';

  @override
  String get settingsShowLocationDesc =>
      'Share your live location during rides';

  @override
  String get settingsAutoAcceptRides => 'Auto-Accept Rides';

  @override
  String get settingsAutoAcceptRidesDesc =>
      'Automatically accept ride requests';

  @override
  String get settingsBlockedUsers => 'Blocked Users';

  @override
  String get settingsBlockedUsersDesc => 'Manage blocked users';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsEditProfileDesc => 'Update your profile information';

  @override
  String get settingsPaymentMethods => 'Payment Methods';

  @override
  String get settingsPaymentMethodsDesc => 'Manage your payment options';

  @override
  String get managePaymentMethodsDesc =>
      'Add, remove, or update saved payment methods for faster checkout.';

  @override
  String get selectedPaymentMethod => 'Selected Payment Method';

  @override
  String get changePaymentMethod => 'Change Payment Method';

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String get settingsVerifyAccount => 'Verify Account';

  @override
  String get settingsVerifyAccountDesc => 'Complete identity verification';

  @override
  String get settingsSupport => 'Support & Legal';

  @override
  String get settingsHelpCenter => 'Help Center';

  @override
  String get settingsHelpCenterDesc => 'Get help and support';

  @override
  String get settingsReportProblem => 'Report a Problem';

  @override
  String get settingsReportProblemDesc => 'Report bugs or issues';

  @override
  String get settingsTermsConditions => 'Terms & Conditions';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDesc => 'App version and information';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsLogoutDesc => 'Sign out of your account';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountDesc =>
      'Permanently delete your account and data';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorInvalidInput => 'Invalid input. Please check your entry.';

  @override
  String get errorPermissionDenied => 'Permission denied.';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get goHome => 'Go Home';

  @override
  String stepValueOfValue(Object value1, Object value2) {
    return 'Step $value1 of $value2';
  }

  @override
  String get skipTour => 'Skip tour';

  @override
  String get logs => 'Logs';

  @override
  String get theme => 'Theme';

  @override
  String get themePlayground => 'Theme Playground';

  @override
  String get colorScheme => 'Color Scheme';

  @override
  String surfaceBlendValue(Object value) {
    return 'Surface Blend: $value%';
  }

  @override
  String get useMaterial3 => 'Use Material 3';

  @override
  String get componentPreview => 'Component Preview';

  @override
  String get elevated => 'Elevated';

  @override
  String get filled => 'Filled';

  @override
  String get outlined => 'Outlined';

  @override
  String get text => 'Text';

  @override
  String get textField => 'Text Field';

  @override
  String get enterText => 'Enter text...';

  @override
  String get cardTitle => 'Card Title';

  @override
  String get cardSubtitleWithDescription => 'Card subtitle with description';

  @override
  String get chip1 => 'Chip 1';

  @override
  String get action => 'Action';

  @override
  String get colorPalette => 'Color Palette';

  @override
  String get primary => 'primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get surface => 'Surface';

  @override
  String get background => 'Background';

  @override
  String get error => 'error';

  @override
  String get copyThemeCode => 'Copy Theme Code';

  @override
  String get applyTheme => 'Apply Theme';

  @override
  String get themeCodeCopiedToLogs => 'Theme code copied to logs!';

  @override
  String themeValueApplied(Object value) {
    return 'Theme \"$value\" applied!';
  }

  @override
  String lvlValue(Object value) {
    return 'LVL $value';
  }

  @override
  String valueValueXp(Object value1, Object value2) {
    return '$value1 / $value2 XP';
  }

  @override
  String value(Object value) {
    return '$value%';
  }

  @override
  String value2(Object value) {
    return '$value';
  }

  @override
  String get dayStreak => 'Day Streak';

  @override
  String value3(Object value) {
    return '#$value';
  }

  @override
  String get you => 'You';

  @override
  String valueXp(Object value) {
    return '+$value XP';
  }

  @override
  String valueValue(Object value1, Object value2) {
    return '$value1/$value2';
  }

  @override
  String get standard => 'standard';

  @override
  String get standard2 => 'Standard';

  @override
  String get terrain => 'terrain';

  @override
  String get terrain2 => 'Terrain';

  @override
  String get dark => 'dark';

  @override
  String get light => 'light';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get humanitarian => 'humanitarian';

  @override
  String get humanitarian2 => 'Humanitarian';

  @override
  String get searchAddressCityOrPlace => 'Search address, city, or place...';

  @override
  String get popularCities => 'Popular Cities';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get nearbyPlaces => 'Nearby Places';

  @override
  String get findUsefulSpotsAlongYour => 'Find useful spots along your route';

  @override
  String get searchRadius => 'Search Radius';

  @override
  String get selectACategoryToSearch => 'Select a category to search';

  @override
  String get tapOnAnyCategoryAbove =>
      'Tap on any category above to find nearby places';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryIncreasingTheSearchRadius => 'Try increasing the search radius';

  @override
  String lvValue(Object value) {
    return 'Lv.$value';
  }

  @override
  String value4(Object value) {
    return '+$value';
  }

  @override
  String get text99 => '99+';

  @override
  String get text9 => '9+';

  @override
  String valueRidesValue(Object value1, Object value2) {
    return '$value1 rides • $value2';
  }

  @override
  String value5(Object value) {
    return '$value €';
  }

  @override
  String valueSeatsLeft(Object value) {
    return '$value seats left';
  }

  @override
  String get fullyBooked => 'Fully booked';

  @override
  String get bookNow => 'Book Now';

  @override
  String valueSeats(Object value) {
    return '$value seats';
  }

  @override
  String errorSavingVehicleValue(Object value) {
    return 'Error saving vehicle: $value';
  }

  @override
  String get driverSetup => 'Driver Setup';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get payouts => 'payouts';

  @override
  String get addYourVehicle => 'Add Your Vehicle';

  @override
  String get fuelType => 'Fuel Type';

  @override
  String get setupPayouts => 'Setup Payouts';

  @override
  String get securePayments => 'Secure Payments';

  @override
  String get fastTransfers => 'Fast Transfers';

  @override
  String get easyTracking => 'Easy Tracking';

  @override
  String get skipForNowILl => 'Skip for now, I\'ll set this up later';

  @override
  String get youCanStillOfferRides =>
      'You can still offer rides without setting up payouts, but you won\'t be able to receive payments until you complete this step.';

  @override
  String get sportconnect => 'SportConnect';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinueYour => 'Sign in to continue your running journey';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get donTHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get enterYourEmailAddressAnd =>
      'Enter your email address and we\'ll send you instructions to reset your password.';

  @override
  String get passwordResetEmailSentCheck =>
      'Password reset email sent! Check your inbox.';

  @override
  String get pleaseAgreeToTheTerms => 'Please agree to the Terms of Service';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinOurCommunityOfEco =>
      'Join our community of eco-friendly riders';

  @override
  String get welcomeBonus => 'Welcome Bonus';

  @override
  String get get100XpWhenYou => 'Get 100 XP when you complete your profile!';

  @override
  String get iWantTo => 'I want to:';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? ';

  @override
  String get findRides => 'Find rides';

  @override
  String get offerRides => 'Offer rides';

  @override
  String get pleaseSelectARoleTo => 'Please select a role to continue';

  @override
  String errorValue(Object value) {
    return 'Error: $value';
  }

  @override
  String get iMARider => 'I\'m a Rider';

  @override
  String get iMADriver => 'I\'m a Driver';

  @override
  String get youCanChangeYourRole =>
      'You can change your role later in settings';

  @override
  String get howWillYouUseSportconnect => 'How will you use SportConnect?';

  @override
  String get chooseYourRoleToGet =>
      'Choose your role to get started.\nThis will customize your experience.';

  @override
  String get text2 => '🎉';

  @override
  String get join10000EcoRiders => 'Join 10,000+ eco-riders';

  @override
  String get get100XpWelcomeBonus => 'Get 100 XP welcome bonus!';

  @override
  String get orSignUpWith => 'Or sign up with';

  @override
  String get strongPasswordTips => 'Strong Password Tips';

  @override
  String get use8CharactersWithLetters =>
      'Use 8+ characters with letters, numbers & symbols';

  @override
  String get passwordStrength => 'Password Strength';

  @override
  String get yourInterestsOptional => 'Your Interests (Optional)';

  @override
  String get selectSportsYouReInterested =>
      'Select sports you\'re interested in';

  @override
  String get addAProfilePhoto => 'Add a Profile Photo';

  @override
  String get thisHelpsOthersRecognizeYou => 'This helps others recognize you';

  @override
  String get readyToJoin => 'Ready to Join!';

  @override
  String emailValue(Object value) {
    return 'Email: $value';
  }

  @override
  String roleValue(Object value) {
    return 'Role: $value';
  }

  @override
  String get carpoolingForRunners => 'CARPOOLING FOR RUNNERS';

  @override
  String get shareRidesRunTogetherGo =>
      'Share rides. Run together.\nGo further.';

  @override
  String get loading => 'Loading...';

  @override
  String get offerRide => 'Offer Ride';

  @override
  String get driver => 'Driver';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get acceptingRideRequests => 'Accepting ride requests';

  @override
  String get tapToGoOnlineAnd => 'Tap to go online and start earning';

  @override
  String get failedToLoadStatus => 'Failed to load status';

  @override
  String get todaySEarnings => 'Today\'s Earnings';

  @override
  String get live => 'Live';

  @override
  String value6(Object value) {
    return '€$value';
  }

  @override
  String valueRides(Object value) {
    return '$value rides';
  }

  @override
  String get failedToLoadEarnings => 'Failed to load earnings';

  @override
  String get rideRequests => 'Ride Requests';

  @override
  String get viewAll => 'View All';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get failedToLoadRequests => 'Failed to load requests';

  @override
  String get noAcceptedRequestsYet => 'No accepted requests yet';

  @override
  String get acceptedRequestsWillAppearHere =>
      'Accepted ride requests will appear here';

  @override
  String get upcomingRides => 'Upcoming Rides';

  @override
  String get noUpcomingRides => 'No upcoming rides';

  @override
  String get failedToLoadRides => 'Failed to load rides';

  @override
  String get kNew => 'New';

  @override
  String valueSeatValue(Object value1, Object value2) {
    return '$value1 seat$value2';
  }

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String valueValue2(Object value1, Object value2) {
    return '$value1 → $value2';
  }

  @override
  String get earned => 'earned';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get loadingRoute => 'Loading route...';

  @override
  String valueKm(Object value) {
    return '$value km';
  }

  @override
  String get rides => 'Rides';

  @override
  String get seats => 'seats';

  @override
  String get whereAreYouGoing => 'Where are you going?';

  @override
  String get hotspots => 'Hotspots';

  @override
  String get nearbyRides => 'Nearby Rides';

  @override
  String get followLocation => 'Follow Location';

  @override
  String valueMin(Object value) {
    return '$value min';
  }

  @override
  String get mapStyle => 'Map Style';

  @override
  String get dark2 => 'Dark';

  @override
  String get findARide => 'Find a Ride';

  @override
  String get filters => 'Filters';

  @override
  String get fromWhere => 'From where?';

  @override
  String get toWhere => 'To where?';

  @override
  String valueAvailable(Object value) {
    return '$value available';
  }

  @override
  String get noRidesAvailableNearby => 'No rides available nearby';

  @override
  String get tryExpandingYourSearchRadius => 'Try expanding your search radius';

  @override
  String get pickupPoint => 'Pickup point';

  @override
  String get destination => 'Destination';

  @override
  String get eco => 'Eco';

  @override
  String get premium => 'Premium';

  @override
  String get pickupLocation => 'Pickup location';

  @override
  String get bookThisRide => 'Book This Ride';

  @override
  String get ride => 'Ride';

  @override
  String get seat => 'seat';

  @override
  String get sendingImage => 'Sending image...';

  @override
  String failedToSendImageValue(Object value) {
    return 'Failed to send image: $value';
  }

  @override
  String failedToStartCallValue(Object value) {
    return 'Failed to start call: $value';
  }

  @override
  String get viewProfile => 'View Profile';

  @override
  String get searchInChat => 'Search in Chat';

  @override
  String get muteNotifications => 'Mute Notifications';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get notificationsMutedForThisChat =>
      'Notifications muted for this chat';

  @override
  String get areYouSureYouWant =>
      'Are you sure you want to delete all messages? This action cannot be undone.';

  @override
  String get chatCleared => 'Chat cleared';

  @override
  String get clear => 'clear';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get sendAMessageToStart => 'Send a message to start the conversation';

  @override
  String get typing => 'typing';

  @override
  String replyingToValue(Object value) {
    return 'Replying to $value';
  }

  @override
  String get tapToOpenMap => 'Tap to open map';

  @override
  String get open => 'Open';

  @override
  String get thisMessageWasDeleted => 'This message was deleted';

  @override
  String get edited => 'edited';

  @override
  String get reply => 'Reply';

  @override
  String get copy => 'Copy';

  @override
  String get messageCopied => 'Message copied';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get document => 'Document';

  @override
  String get location => 'Location';

  @override
  String get gettingYourLocation => 'Getting your location...';

  @override
  String get locationShared => 'Location shared';

  @override
  String get coordinatesCopiedToClipboard => 'Coordinates copied to clipboard';

  @override
  String couldNotOpenMapsValue(Object value) {
    return 'Could not open maps: $value';
  }

  @override
  String get messages => 'Messages';

  @override
  String get pleaseLoginToViewChats => 'Please login to view chats';

  @override
  String get failedToLoadChats => 'Failed to load chats';

  @override
  String get retry => 'Retry';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get noGroupChats => 'No group chats';

  @override
  String get noRideChats => 'No ride chats';

  @override
  String get callHistory => 'Call History';

  @override
  String get noCallHistory => 'No call history';

  @override
  String get videoCall => 'Video call';

  @override
  String get text3 => ' • ';

  @override
  String get newMessage => 'New Message';

  @override
  String get searchUsersByName => 'Search users by name...';

  @override
  String get searchForAUserTo => 'Search for a user to start chatting';

  @override
  String get typeAtLeast2Characters => 'Type at least 2 characters';

  @override
  String noUsersFoundForValue(Object value) {
    return 'No users found for \"$value\"';
  }

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get clearAllNotifications => 'Clear All Notifications';

  @override
  String get areYouSureYouWant2 =>
      'Are you sure you want to clear all notifications?';

  @override
  String get allNotificationsCleared => 'All notifications cleared';

  @override
  String get failedToClearNotifications => 'Failed to clear notifications';

  @override
  String get clearAll => 'Clear All';

  @override
  String get pleaseSignInToView => 'Please sign in to view notifications';

  @override
  String get unread => 'Unread';

  @override
  String valueNew(Object value) {
    return '$value new';
  }

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearAll2 => 'Clear all';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get youReAllCaughtUp => 'You\'re all caught up!';

  @override
  String couldNotOpenChatValue(Object value) {
    return 'Could not open chat: $value';
  }

  @override
  String get youReReadyToRun => 'You\'re Ready to Run';

  @override
  String get createAnAccountToStart =>
      'Create an account to start tracking your runs and connect with other runners.';

  @override
  String get kContinue => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get earnings => 'Earnings';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String thisWeekValue(Object value) {
    return 'This week: $value €';
  }

  @override
  String get earningsOverview => 'Earnings Overview';

  @override
  String get active => 'Active';

  @override
  String get ridesEarnings => 'Rides Earnings';

  @override
  String get tipsBonuses => 'Tips & Bonuses';

  @override
  String get environmentalImpact => 'Environmental Impact';

  @override
  String get totalDistance => 'Total Distance';

  @override
  String valueKgCoSaved(Object value) {
    return '$value kg CO₂ saved';
  }

  @override
  String get stripeConnected => 'Stripe Connected';

  @override
  String get setUpPayouts => 'Set Up Payouts';

  @override
  String get receivePaymentsFromRiders => 'Receive payments from riders';

  @override
  String get completeVerification => 'Complete Verification';

  @override
  String get connectYourBankAccount => 'Connect your bank account';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get confirmPayout => 'Confirm Payout';

  @override
  String withdrawValueToYourConnected(Object value) {
    return 'Withdraw $value € to your connected bank account?';
  }

  @override
  String get withdraw => 'Withdraw';

  @override
  String payoutOfValueInitiated(Object value) {
    return 'Payout of $value € initiated!';
  }

  @override
  String get payoutFailedPleaseTryAgain => 'Payout failed. Please try again.';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get failedToLoadTransactions => 'Failed to load transactions';

  @override
  String valueValue3(Object value1, Object value2) {
    return '$value1$value2 €';
  }

  @override
  String get getPaidForYourRides => 'Get Paid for Your Rides';

  @override
  String get connectYourBankAccountTo =>
      'Connect your bank account to receive payments directly from riders. Powered by Stripe for secure transactions.';

  @override
  String get instantPayouts => 'Instant Payouts';

  @override
  String get secureProtected => 'Secure & Protected';

  @override
  String get clearTracking => 'Clear Tracking';

  @override
  String get lowFees => 'Low Fees';

  @override
  String get youLlBeRedirectedTo =>
      'You\'ll be redirected to Stripe to complete setup';

  @override
  String get connectStripe => 'Connect Stripe';

  @override
  String get stripeAccountConnectedSuccessfully =>
      'Stripe account connected successfully!';

  @override
  String errorLoadingPageValue(Object value) {
    return 'Error loading page: $value';
  }

  @override
  String get pleaseSignInToView2 => 'Please sign in to view payment history';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get yourTransactions => 'Your Transactions';

  @override
  String get noPaymentsFound => 'No payments found';

  @override
  String get yourPaymentHistoryWillAppear =>
      'Your payment history will appear here';

  @override
  String get ridePayment => 'Ride Payment';

  @override
  String get unknownDate => 'Unknown Date';

  @override
  String valueValue4(Object value1, Object value2) {
    return '$value1 $value2';
  }

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get amount => 'Amount';

  @override
  String get status => 'Status';

  @override
  String get seats2 => 'Seats';

  @override
  String get platformFee => 'Platform Fee';

  @override
  String get card => 'Card';

  @override
  String value7(Object value) {
    return '•••• $value';
  }

  @override
  String get date => 'Date';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get requestRefund => 'Request Refund';

  @override
  String get errorLoadingAchievements => 'Error loading achievements';

  @override
  String levelValueValue(Object value1, Object value2) {
    return 'Level $value1 - $value2';
  }

  @override
  String valueXp2(Object value) {
    return '$value XP';
  }

  @override
  String valueXpToLevelValue(Object value1, Object value2) {
    return '$value1 XP to Level $value2';
  }

  @override
  String get text4 => '🏆';

  @override
  String get badges => 'Badges';

  @override
  String get text5 => '🎯';

  @override
  String get challenges => 'Challenges';

  @override
  String get text6 => '🚗';

  @override
  String get text7 => '🌍';

  @override
  String get kgCo => 'kg CO₂';

  @override
  String get unlocked => '✓ Unlocked';

  @override
  String get locked => '🔒 Locked';

  @override
  String valueComplete(Object value) {
    return '$value% Complete';
  }

  @override
  String get text8 => '🥈';

  @override
  String get mikeC => 'Mike C.';

  @override
  String get text112k => '11.2K';

  @override
  String get text10 => '🥇';

  @override
  String get sarahJ => 'Sarah J.';

  @override
  String get text124k => '12.4K';

  @override
  String get text11 => '🥉';

  @override
  String get emilyD => 'Emily D.';

  @override
  String get text98k => '9.8K';

  @override
  String levelValue(Object value) {
    return 'Level $value';
  }

  @override
  String get verifiedDriver => 'Verified Driver';

  @override
  String get rating => 'Rating';

  @override
  String get trips => 'Trips';

  @override
  String get member => 'Member';

  @override
  String get text12 => '...';

  @override
  String get text00 => '0.0';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get performanceOverview => 'Performance Overview';

  @override
  String get totalTrips => 'Total Trips';

  @override
  String valueThisMonth(Object value) {
    return '+$value this month';
  }

  @override
  String valueThisMonth2(Object value) {
    return '+$value € this month';
  }

  @override
  String get coSaved => 'CO₂ Saved';

  @override
  String valueKg(Object value) {
    return '$value kg';
  }

  @override
  String get sinceJoining => 'Since joining';

  @override
  String get avgRating => 'Avg Rating';

  @override
  String get last100Trips => 'Last 100 trips';

  @override
  String get noData => 'No data';

  @override
  String get text0 => '0 €';

  @override
  String get text0Kg => '0 kg';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get ratingBreakdown => 'Rating Breakdown';

  @override
  String get tripsThisWeek => 'Trips this week';

  @override
  String valueTrips(Object value) {
    return '$value trips';
  }

  @override
  String get driverSettings => 'Driver Settings';

  @override
  String get ridePreferences => 'Ride Preferences';

  @override
  String get autoAcceptRequests => 'Auto-Accept Requests';

  @override
  String get automaticallyAcceptRideRequestsThat =>
      'Automatically accept ride requests that match your criteria';

  @override
  String get allowInstantBooking => 'Allow Instant Booking';

  @override
  String get letPassengersBookWithoutWaiting =>
      'Let passengers book without waiting for approval';

  @override
  String get maximumPickupDistance => 'Maximum Pickup Distance';

  @override
  String get onlyReceiveRequestsWithinThis =>
      'Only receive requests within this distance';

  @override
  String get paymentSettings => 'Payment Settings';

  @override
  String get acceptCashPayments => 'Accept Cash Payments';

  @override
  String get allowPassengersToPayWith => 'Allow passengers to pay with cash';

  @override
  String get acceptCardPayments => 'Accept Card Payments';

  @override
  String get allowPassengersToPayWith2 =>
      'Allow passengers to pay with card in-app';

  @override
  String get payoutMethod => 'Payout Method';

  @override
  String get bankAccountEndingIn4532 => 'Bank Account ending in 4532';

  @override
  String get taxDocuments => 'Tax Documents';

  @override
  String get viewAndDownloadTaxForms => 'View and download tax forms';

  @override
  String get navigationMap => 'Navigation & Map';

  @override
  String get showOnDriverMap => 'Show on Driver Map';

  @override
  String get allowPassengersToSeeYour =>
      'Allow passengers to see your location';

  @override
  String get preferredNavigationApp => 'Preferred Navigation App';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get playSoundsForNewRequests =>
      'Play sounds for new requests and messages';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateForImportantAlerts => 'Vibrate for important alerts';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get customizeWhatNotificationsYouReceive =>
      'Customize what notifications you receive';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get reduceEyeStrainInLow => 'Reduce eye strain in low light';

  @override
  String get accountSecurity => 'Account & Security';

  @override
  String get driverDocuments => 'Driver Documents';

  @override
  String get licenseInsuranceAndRegistration =>
      'License, insurance, and registration';

  @override
  String get backgroundCheck => 'Background Check';

  @override
  String get viewYourVerificationStatus => 'View your verification status';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updateYourAccountPassword => 'Update your account password';

  @override
  String get twoFactorAuthentication => 'Two-Factor Authentication';

  @override
  String get addExtraSecurityToYour => 'Add extra security to your account';

  @override
  String get support => 'Support';

  @override
  String get driverHelpCenter => 'Driver Help Center';

  @override
  String get faqsAndTroubleshootingGuides => 'FAQs and troubleshooting guides';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get chatWithOurSupportTeam => 'Chat with our support team';

  @override
  String get reportASafetyIssue => 'Report a Safety Issue';

  @override
  String get reportIncidentsOrConcerns => 'Report incidents or concerns';

  @override
  String get accountActions => 'Account Actions';

  @override
  String get switchToRiderMode => 'Switch to Rider Mode';

  @override
  String get useTheAppAsA => 'Use the app as a passenger';

  @override
  String get signOut => 'Sign Out';

  @override
  String get logOutOfYourAccount => 'Log out of your account';

  @override
  String get pauseDriverAccount => 'Pause Driver Account';

  @override
  String get temporarilyStopReceivingRequests =>
      'Temporarily stop receiving requests';

  @override
  String get deleteDriverAccount => 'Delete Driver Account';

  @override
  String get permanentlyRemoveYourDriverProfile =>
      'Permanently remove your driver profile';

  @override
  String get sportconnectDriver => 'SportConnect Driver';

  @override
  String get version210 => 'Version 2.1.0';

  @override
  String get areYouSureYouWant3 =>
      'Are you sure you want to sign out of your account?';

  @override
  String get thisActionCannotBeUndone =>
      'This action cannot be undone. All your driver data, earnings history, and ratings will be permanently deleted.';

  @override
  String get pleaseSignInToManage => 'Please sign in to manage vehicles';

  @override
  String get myVehicles => 'My Vehicles';

  @override
  String get manageYourVehicles => 'Manage your vehicles';

  @override
  String get createdAndJoinedEvents => 'Created & joined events';

  @override
  String get viewYourBadgesAndRewards => 'View your badges & rewards';

  @override
  String get appPreferencesAndPrivacy => 'App preferences & privacy';

  @override
  String get permissionPhotoLibraryMessage =>
      'Access to your photo library is needed to send images in this chat. Your photos are only shared when you choose to send them.';

  @override
  String get yourFleet => 'Your Fleet';

  @override
  String get noActiveVehicle => 'No active vehicle';

  @override
  String get noVehiclesAdded => 'No Vehicles Added';

  @override
  String get addYourFirstVehicleTo =>
      'Add your first vehicle to start\noffering rides';

  @override
  String get addVehicle => 'Add Vehicle';

  @override
  String get vehicleSetAsActive => 'Vehicle set as active';

  @override
  String get deleteVehicle => 'Delete Vehicle';

  @override
  String areYouSureYouWant4(Object value) {
    return 'Are you sure you want to delete $value?';
  }

  @override
  String get vehicleDeleted => 'Vehicle deleted';

  @override
  String get setActive => 'Set Active';

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get color => 'Color';

  @override
  String get licensePlate => 'License Plate';

  @override
  String get passengerCapacity => 'Passenger Capacity';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get capacity => 'Capacity';

  @override
  String valuePassengers(Object value) {
    return '$value passengers';
  }

  @override
  String get totalRides => 'Total Rides';

  @override
  String value8(Object value) {
    return '$value ⭐';
  }

  @override
  String get features => 'Features';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get aboutYou => 'About You';

  @override
  String get demographics => 'Demographics';

  @override
  String get gender => 'Gender';

  @override
  String get birthday => 'Birthday';

  @override
  String get sportsInterests => 'Sports Interests';

  @override
  String get add => '+ Add';

  @override
  String get noInterestsSelected => 'No interests selected';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get selectSportsInterests => 'Select Sports Interests';

  @override
  String get discardChanges => 'Discard Changes?';

  @override
  String get youHaveUnsavedChanges => 'You have unsaved changes.';

  @override
  String get discard => 'Discard';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get pleaseCheckYourConnectionAnd =>
      'Please check your connection and try again';

  @override
  String get myProfile => 'My Profile';

  @override
  String memberSinceValue(Object value) {
    return 'Member since $value';
  }

  @override
  String get newMember => 'New member';

  @override
  String get verifiedInfo => 'Verified Info';

  @override
  String get verified => 'Verified';

  @override
  String get notVerified => 'Not verified';

  @override
  String get inactive => 'Inactive';

  @override
  String get rideStatistics => 'Ride Statistics';

  @override
  String get saved => 'Saved';

  @override
  String get earned2 => 'Earned';

  @override
  String get profileNotFound => 'Profile Not Found';

  @override
  String get yourProfileDataCouldNot =>
      'Your profile data could not be loaded.\nThis may happen if you\'re a new user.';

  @override
  String get signOutTryAgain => 'Sign out & try again';

  @override
  String get findPeople => 'Find People';

  @override
  String get searchByName => 'Search by name';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get findFellowRiders => 'Find Fellow Riders';

  @override
  String get searchForUsersByTheir =>
      'Search for users by their name\nto connect and share rides';

  @override
  String get popularSearches => 'Popular Searches';

  @override
  String get searching => 'Searching...';

  @override
  String get noResultsFound2 => 'No Results Found';

  @override
  String noUsersFoundMatchingValue(Object value) {
    return 'No users found matching \"$value\"';
  }

  @override
  String get tryADifferentSearchTerm => 'Try a different search term';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get vehicles => 'vehicles';

  @override
  String get legal => 'Legal';

  @override
  String get sportconnectV100 => 'SportConnect v0.0.11';

  @override
  String get noBlockedUsers => 'No Blocked Users';

  @override
  String get usersYouBlockWillAppear => 'Users you block will appear here';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get paymentIntegrationWillBeAvailable =>
      'Payment integration will be available soon';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get update => 'Update';

  @override
  String get gettingStarted => 'Getting Started';

  @override
  String get ridesCarpooling => 'Rides & Carpooling';

  @override
  String get safetyTrust => 'Safety & Trust';

  @override
  String get accountSettings => 'Account & Settings';

  @override
  String openingValue(Object value) {
    return 'Opening: $value';
  }

  @override
  String get weReHereToHelp =>
      'We\'re here to help! Choose how you\'d like to reach us.';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get couldNotOpenEmailApp => 'Could not open email app';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get liveChatWillBeAvailable => 'Live chat will be available soon!';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get category => 'Category';

  @override
  String get describeTheProblem => 'Describe the problem';

  @override
  String get pleaseDescribeWhatHappened => 'Please describe what happened...';

  @override
  String get thankYouYourReportHas =>
      'Thank you! Your report has been submitted.';

  @override
  String get submit => 'Submit';

  @override
  String get areYouSureYouWant5 =>
      'Are you sure you want to log out of SportConnect?';

  @override
  String get thisActionCannotBeUndone2 =>
      'This action cannot be undone. All your data, including:';

  @override
  String get rideHistoryAndBookings => 'Ride history and bookings';

  @override
  String get profileAndAchievements => 'Profile and achievements';

  @override
  String get messagesAndConnections => 'Messages and connections';

  @override
  String get paymentInformation => 'Payment information';

  @override
  String get typeDeleteToConfirm => 'Type \"DELETE\" to confirm:';

  @override
  String failedToDeleteAccountValue(Object value) {
    return 'Failed to delete account: $value';
  }

  @override
  String get addRide => 'Add Ride';

  @override
  String get userNotFound => 'User not found';

  @override
  String get errorLoadingVehicles => 'Error loading vehicles';

  @override
  String get myGarage => 'My Garage';

  @override
  String valueVehicles(Object value) {
    return '$value Vehicles';
  }

  @override
  String get setDefault => 'Set Default';

  @override
  String get pending => 'Pending';

  @override
  String get plate => 'Plate';

  @override
  String get garageIsEmpty => 'Garage is Empty';

  @override
  String get addAVehicleToStart =>
      'Add a vehicle to start your journey. Connect with others and share rides.';

  @override
  String get quickTip => 'Quick Tip';

  @override
  String get swipeRightOnAVehicle =>
      'Swipe right on a vehicle card to set it as default. Swipe left to remove it.';

  @override
  String get deleteRide => 'Delete Ride?';

  @override
  String areYouSureYouWant6(Object value) {
    return 'Are you sure you want to remove $value? This cannot be undone.';
  }

  @override
  String get keepIt => 'Keep It';

  @override
  String get vehicleRemovedFromGarage => 'Vehicle removed from garage';

  @override
  String get editRide => 'Edit Ride';

  @override
  String get newRide => 'New Ride';

  @override
  String get seatsCapacity => 'Seats Capacity';

  @override
  String valueSReviews(Object value) {
    return '$value\'s Reviews';
  }

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get failedToLoadReviews => 'Failed to load reviews';

  @override
  String valueReviews(Object value) {
    return '$value reviews';
  }

  @override
  String get rider => 'Rider';

  @override
  String get response => 'Response';

  @override
  String get leaveAReview => 'Leave a Review';

  @override
  String get howWasYourExperience => 'How was your experience?';

  @override
  String get whatStoodOut => 'What stood out?';

  @override
  String get additionalCommentsOptional => 'Additional comments (optional)';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get yourDriver => 'Your Driver';

  @override
  String get yourPassenger => 'Your Passenger';

  @override
  String get shareYourExperience => 'Share your experience...';

  @override
  String get thankYouForYourReview => 'Thank you for your review!';

  @override
  String valueValue5(Object value1, Object value2) {
    return '$value1$value2';
  }

  @override
  String get errorLoadingRide => 'Error loading ride';

  @override
  String get goBack => 'Go Back';

  @override
  String get tooltipShowPassword => 'Show password';

  @override
  String get tooltipHidePassword => 'Hide password';

  @override
  String get activeRide => 'Active Ride';

  @override
  String get noActiveRide => 'No active ride';

  @override
  String get startARideToSee => 'Start a ride to see navigation';

  @override
  String get headingToPickup => 'Heading to pickup';

  @override
  String get headingToDestination => 'Heading to destination';

  @override
  String etaValueMinValueKm(Object value1, Object value2) {
    return 'ETA: $value1 min • $value2 km remaining';
  }

  @override
  String arrivingAtValue(Object value) {
    return 'Arriving at $value';
  }

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Duration';

  @override
  String get fare => 'Fare';

  @override
  String get call => 'Call';

  @override
  String get message => 'Message';

  @override
  String get text5Min => '5 min';

  @override
  String valueMore(Object value) {
    return '+$value more';
  }

  @override
  String valuePassengerValue(Object value1, Object value2) {
    return '$value1 passenger$value2';
  }

  @override
  String valueSeatValueBooked(Object value1, Object value2) {
    return '• $value1 seat$value2 booked';
  }

  @override
  String valueSeatValueBooked2(Object value1, Object value2) {
    return '$value1 seat$value2 booked';
  }

  @override
  String get passengers => 'Passengers';

  @override
  String get seat2 => '€/seat';

  @override
  String get min => 'min';

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Dropoff';

  @override
  String valuePassengerValueBookedFor(Object value1, Object value2) {
    return '$value1 passenger$value2 booked for this ride';
  }

  @override
  String get cancelRide => 'Cancel Ride?';

  @override
  String get areYouSureYouWant7 =>
      'Are you sure you want to cancel this ride? This may affect your driver rating.';

  @override
  String get continueRide => 'Continue Ride';

  @override
  String get cancelRide2 => 'Cancel Ride';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get manageYourRidesEarnings => 'Manage your rides & earnings';

  @override
  String get requests => 'Requests';

  @override
  String get thisMonth => 'This Month';

  @override
  String get noPendingRequests2 => 'No Pending Requests';

  @override
  String get newRequest => 'NEW REQUEST';

  @override
  String get tapToRespond => 'Tap to respond';

  @override
  String value9(Object value) {
    return '+€$value';
  }

  @override
  String get earnings2 => 'earnings';

  @override
  String valueValue6(Object value1, Object value2) {
    return '$value1 • $value2';
  }

  @override
  String get failedToLoadUser => 'Failed to load user';

  @override
  String get noActiveRides => 'No Active Rides';

  @override
  String get rideInProgress => 'RIDE IN PROGRESS';

  @override
  String valueValuePassengers(Object value1, Object value2) {
    return '$value1/$value2 passengers';
  }

  @override
  String get navigate => 'Navigate';

  @override
  String get complete => 'Complete';

  @override
  String get noScheduledRides => 'No Scheduled Rides';

  @override
  String valueSeat(Object value) {
    return '€$value/seat';
  }

  @override
  String get noCompletedRides => 'No Completed Rides';

  @override
  String valueValuePassengers2(Object value1, Object value2) {
    return '$value1 • $value2 passengers';
  }

  @override
  String get loadingYourRides => 'Loading your rides...';

  @override
  String get signInRequired => 'Sign In Required';

  @override
  String get bookingAccepted => 'Booking accepted!';

  @override
  String get bookingDeclined => 'Booking declined';

  @override
  String get rideCompletedWellDone => 'Ride completed! Well done 🎉';

  @override
  String get manageVehicles => 'Manage Vehicles';

  @override
  String get earningsHistory => 'Earnings History';

  @override
  String get preferences => 'Preferences';

  @override
  String get offerARide => 'Offer a Ride';

  @override
  String get driverAccountRequired => 'Driver Account Required';

  @override
  String get youNeedToRegisterAs =>
      'You need to register as a driver and add a vehicle to offer rides.';

  @override
  String get shareYourJourneyEarnMoney => 'Share your journey, earn money';

  @override
  String get yourRoute => 'Your Route';

  @override
  String get startingPoint => 'Starting Point';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get recurringRide => 'Recurring Ride';

  @override
  String get offerThisRideRegularly => 'Offer this ride regularly';

  @override
  String get addAVehicleToStart2 => 'Add a vehicle to start offering rides';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get add2 => 'Add';

  @override
  String get availableSeats => 'Available Seats';

  @override
  String maxValuePassengers(Object value) {
    return 'Max $value passengers';
  }

  @override
  String get selectAVehicleFirst => 'Select a vehicle first';

  @override
  String get pricePerSeat => 'Price per Seat';

  @override
  String get priceNegotiable => 'Price Negotiable';

  @override
  String get acceptOnlinePayment => 'Accept Online Payment';

  @override
  String get receivePaymentsViaStripe => 'Receive payments via Stripe';

  @override
  String get allowLuggage => 'Allow Luggage';

  @override
  String get allowPets => 'Allow Pets';

  @override
  String get allowSmoking => 'Allow Smoking';

  @override
  String get womenOnly => 'Women Only';

  @override
  String get maxDetour => 'Max Detour';

  @override
  String get howFarYouLlGo => 'How far you\'ll go to pick up passengers';

  @override
  String get rideCreatedSuccessfully => 'Ride created successfully!';

  @override
  String get newRideRequestsWillAppear => 'New ride requests will appear here';

  @override
  String get noDeclinedRequests => 'No Declined Requests';

  @override
  String get youHavenTDeclinedAny => 'You haven\'t declined any requests yet';

  @override
  String get acceptRequest => 'Accept Request?';

  @override
  String youAreAboutToAccept(Object value1, Object value2, Object value3) {
    return 'You are about to accept $value1\'s ride request for $value2 at $value3.';
  }

  @override
  String requestAcceptedValueHasBeen(Object value) {
    return 'Request accepted! $value has been notified.';
  }

  @override
  String get failedToAcceptRequest => 'Failed to accept request';

  @override
  String get requestDeclined => 'Request declined';

  @override
  String get failedToDeclineRequest => 'Failed to decline request';

  @override
  String requestedValue(Object value) {
    return 'Requested $value';
  }

  @override
  String valueSeatValue2(Object value1, Object value2) {
    return '• $value1 seat$value2';
  }

  @override
  String valueSeatValueRequested(Object value1, Object value2) {
    return '$value1 seat$value2 requested';
  }

  @override
  String get acceptRequest2 => 'Accept Request';

  @override
  String acceptedValue(Object value) {
    return 'Accepted $value';
  }

  @override
  String valueAtValue(Object value1, Object value2) {
    return '$value1 at $value2';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String declinedValue(Object value) {
    return 'Declined $value';
  }

  @override
  String reasonValue(Object value) {
    return 'Reason: $value';
  }

  @override
  String get declineRequest => 'Decline Request';

  @override
  String pleaseLetValueKnowWhy(Object value) {
    return 'Please let $value know why you can\'t accept this ride.';
  }

  @override
  String get pleaseSpecify => 'Please specify...';

  @override
  String get rideNotFound => 'Ride not found';

  @override
  String get yourRide => 'Your Ride';

  @override
  String get couldnTLoadRide => 'Couldn\'t load ride';

  @override
  String get seatsFilled => 'Seats filled';

  @override
  String get perSeat => 'Per seat';

  @override
  String get route => 'Route';

  @override
  String value10(Object value) {
    return '~$value';
  }

  @override
  String valueTotalSeats(Object value) {
    return '$value total seats';
  }

  @override
  String get notes => 'Notes';

  @override
  String get newBookingRequestsWillAppear =>
      'New booking requests will appear here';

  @override
  String get noPassengersYet => 'No passengers yet';

  @override
  String get acceptBookingRequestsToAdd =>
      'Accept booking requests to add passengers';

  @override
  String get shareRide => 'Share Ride';

  @override
  String get duplicateRide => 'Duplicate Ride';

  @override
  String get callPassenger => 'Call Passenger';

  @override
  String get removePassenger => 'Remove Passenger';

  @override
  String bookingConfirmedForValue(Object value) {
    return 'Booking confirmed for $value';
  }

  @override
  String get declineBooking => 'Decline Booking';

  @override
  String declineBookingRequestFromValue(Object value) {
    return 'Decline booking request from $value?';
  }

  @override
  String removeValueFromThisRide(Object value) {
    return 'Remove $value from this ride?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get startRide => 'Start Ride';

  @override
  String get markThisRideAsStarted =>
      'Mark this ride as started? Passengers will be notified.';

  @override
  String get confirmPickup => 'Confirm Pickup';

  @override
  String get passengersPickedUpStartTrip => 'Passengers Picked Up — Start Trip';

  @override
  String get confirmAllPassengersPickedUp =>
      'Confirm all passengers have been picked up and you are ready to start the trip.';

  @override
  String get start => 'Start';

  @override
  String get completeRide => 'Complete Ride';

  @override
  String get markThisRideAsCompleted =>
      'Mark this ride as completed? You can then rate your passengers.';

  @override
  String get areYouSureYouWant8 =>
      'Are you sure you want to cancel this ride? All passengers will be notified and refunded.';

  @override
  String get keepRide => 'Keep Ride';

  @override
  String get failedToLoadRide => 'Failed to load ride';

  @override
  String get thisRideMayHaveBeen =>
      'This ride may have been completed or cancelled';

  @override
  String get rideConfirmed => 'Ride Confirmed';

  @override
  String get driverOnTheWay => 'Driver on the way';

  @override
  String get rideCompleted => 'Ride Completed';

  @override
  String valueRides2(Object value) {
    return '• $value rides';
  }

  @override
  String get routeDetails => 'Route Details';

  @override
  String get perSeat2 => 'per seat';

  @override
  String get seatsLeft => 'seats left';

  @override
  String get departure => 'Departure';

  @override
  String passengersValue(Object value) {
    return 'Passengers ($value)';
  }

  @override
  String get phoneNumberNotAvailable => 'Phone number not available';

  @override
  String get cannotMakePhoneCalls => 'Cannot make phone calls on this device';

  @override
  String get failedToLaunchDialer => 'Failed to launch phone dialer';

  @override
  String get areYouSureYouWant9 =>
      'Are you sure you want to cancel this ride? Cancellation policies may apply.';

  @override
  String get rideCancelledSuccessfully => 'Ride cancelled successfully';

  @override
  String failedToCancelRideValue(Object value) {
    return 'Failed to cancel ride: $value';
  }

  @override
  String get rateYourRide => 'Rate your ride';

  @override
  String get ratingFeatureComingSoonThank =>
      'Rating feature coming soon! Thank you for using SportConnect.';

  @override
  String get myTrips => 'My Trips';

  @override
  String get trackManageYourRides => 'Track & manage your rides';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get history => 'History';

  @override
  String get noActiveTrips => 'No Active Trips';

  @override
  String get tripInProgress => 'TRIP IN PROGRESS';

  @override
  String get text49 => '4.9';

  @override
  String get noUpcomingTrips => 'No Upcoming Trips';

  @override
  String get noTripHistory => 'No Trip History';

  @override
  String get rebook => 'Rebook';

  @override
  String get findRide => 'Find Ride';

  @override
  String get loadingYourTrips => 'Loading your trips...';

  @override
  String get cancelTrip => 'Cancel Trip?';

  @override
  String areYouSureYouWant10(Object value) {
    return 'Are you sure you want to cancel your trip to $value?';
  }

  @override
  String get tripCancelled => 'Trip cancelled';

  @override
  String get openingChat => 'Opening chat...';

  @override
  String failedToOpenChatValue(Object value) {
    return 'Failed to open chat: $value';
  }

  @override
  String get startingCall => 'Starting call...';

  @override
  String get whereTo => 'Where to?';

  @override
  String get findThePerfectRideFor => 'Find the perfect ride for your journey';

  @override
  String get whereFrom => 'Where from?';

  @override
  String get when => 'When?';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get pickDate => 'Pick Date';

  @override
  String get departureTime2 => 'Departure time';

  @override
  String get howManySeatsDoYou => 'How many seats do you need?';

  @override
  String get availableRides => 'Available Rides';

  @override
  String get sort => 'Sort';

  @override
  String get noRidesFound => 'No rides found';

  @override
  String get tryAdjustingYourSearchCriteria =>
      'Try adjusting your search criteria\nor check back later';

  @override
  String get findingRides => 'Finding rides...';

  @override
  String get sortBy => 'Sort by';

  @override
  String get recommended => 'recommended';

  @override
  String get earliestDeparture => 'Earliest departure';

  @override
  String get lowestPrice => 'Lowest price';

  @override
  String get highestRated => 'Highest rated';

  @override
  String get searchFailedPleaseTryAgain => 'Search failed. Please try again.';

  @override
  String get rideDetails => 'Ride Details';

  @override
  String value11(Object value) {
    return '$value • ';
  }

  @override
  String valueLeft(Object value) {
    return '$value left';
  }

  @override
  String valueMin2(Object value) {
    return '~$value min';
  }

  @override
  String valueKgCoSavedPer(Object value) {
    return '$value kg CO₂ saved per person';
  }

  @override
  String get negotiable => 'Negotiable';

  @override
  String get onlinePay => 'Online Pay';

  @override
  String get reviews => 'reviews';

  @override
  String get seeAll => 'See all';

  @override
  String get seats3 => 'Seats:';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get pricePerSeat2 => 'Price per seat';

  @override
  String get total => 'Total';

  @override
  String get addANoteToThe => 'Add a note to the driver (optional)';

  @override
  String get bookingRequestSent => 'Booking request sent!';

  @override
  String get seatsLeft2 => 'Seats left';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get departure2 => 'Departure';

  @override
  String get amenities => 'Amenities';

  @override
  String get pets => 'Pets';

  @override
  String get smoking => 'Smoking';

  @override
  String get luggage => 'Luggage';

  @override
  String yourPassengersValue(Object value) {
    return 'Your Passengers ($value)';
  }

  @override
  String valueValueSeats(Object value1, Object value2) {
    return '$value1/$value2 seats';
  }

  @override
  String get noPassengersAcceptedYet => 'No passengers accepted yet';

  @override
  String get noPassengersBookedYet => 'No passengers booked yet';

  @override
  String valueHasBookedThisRide(Object value) {
    return '$value has booked this ride';
  }

  @override
  String valuePassengersHaveBooked(Object value) {
    return '$value passengers have booked';
  }

  @override
  String pendingRequestsValue(Object value) {
    return 'Pending Requests ($value)';
  }

  @override
  String get requestAccepted => 'Request accepted! 🎉';

  @override
  String get seatsBooked => 'Seats Booked';

  @override
  String get editRideFeatureComingSoon => 'Edit ride feature coming soon!';

  @override
  String get numberOfSeats => 'Number of seats';

  @override
  String value12(Object value) {
    return '× $value';
  }

  @override
  String get securePaymentWithStripe => 'Secure payment with Stripe';

  @override
  String get pleaseLogInToBook => 'Please log in to book a ride';

  @override
  String get paymentSucceededButBookingFailed =>
      'Payment succeeded but booking failed. Please contact support.';

  @override
  String get paymentCancelled => 'Payment cancelled';

  @override
  String paymentFailedValue(Object value) {
    return 'Payment failed: $value';
  }

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get thisDriverAcceptsCashPayment =>
      'This driver accepts cash payment only.';

  @override
  String get payWithCash => 'Pay with Cash';

  @override
  String get failedToBookRidePlease => 'Failed to book ride. Please try again.';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String youPaidValueValue(Object value1, Object value2) {
    return 'You paid $value1 $value2';
  }

  @override
  String get yourRideHasBeenBooked => 'Your ride has been booked.';

  @override
  String get youEarned25Xp => 'You earned 25 XP!';

  @override
  String get backToSearch => 'Back to Search';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get yourRideHasBeenBooked2 =>
      'Your ride has been booked. Pay the driver in cash.';

  @override
  String get pleaseEnterBothLocations => 'Please enter both locations';

  @override
  String get pleaseSelectLocationsFromThe =>
      'Please select locations from the picker';

  @override
  String maxValue(Object value) {
    return 'Max $value €';
  }

  @override
  String get femaleOnly => 'Female only';

  @override
  String get instantBook => 'Instant book';

  @override
  String get petFriendly => 'Pet friendly';

  @override
  String valueRating(Object value) {
    return '$value+ rating';
  }

  @override
  String get activeFilters => 'Active Filters';

  @override
  String valueRidesAvailable(Object value) {
    return '$value rides available';
  }

  @override
  String filtersValue(Object value) {
    return 'Filters$value';
  }

  @override
  String get reset => 'Reset';

  @override
  String get priceRange => 'Price Range';

  @override
  String get text52 => '5 €';

  @override
  String get text100 => '100 €';

  @override
  String get minimumRating => 'Minimum Rating';

  @override
  String get any => 'any';

  @override
  String value13(Object value) {
    return '$value+';
  }

  @override
  String get verifiedDriver2 => 'Verified driver';

  @override
  String get musicAllowed => 'Music allowed';

  @override
  String get noSmoking => 'No Smoking';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get electric => 'Electric';

  @override
  String get comfort => 'comfort';

  @override
  String get book => 'Book';

  @override
  String get sortBy2 => 'Sort By';

  @override
  String get lowestPrice2 => 'Lowest Price';

  @override
  String get earliestDeparture2 => 'Earliest Departure';

  @override
  String get highestRated2 => 'Highest Rated';

  @override
  String get shortestDuration => 'Shortest Duration';

  @override
  String get signInFailedPleaseTry => 'Sign in failed. Please try again.';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get orSignInWithEmail => 'or sign in with email';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get avgPerRide => 'Avg per Ride';

  @override
  String get driveTime => 'Drive Time';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get checkYourConnectionAndTry => 'Check your connection and try again';

  @override
  String get couldNotOpenChat => 'Could not open chat';

  @override
  String get searchConversations => 'Search conversations...';

  @override
  String get searchChatsOrPeople => 'Search chats or people';

  @override
  String get peopleResults => 'People';

  @override
  String get direct => 'Direct';

  @override
  String get groups => 'Events';

  @override
  String get all => 'All';

  @override
  String get startAConversationWith =>
      'Start a conversation with your ride partners';

  @override
  String get joinOrCreateAGroup => 'Join or create a group to start chatting';

  @override
  String get joinARideToChat => 'Join a ride to chat with fellow travelers';

  @override
  String get driverCreateRide => 'Create Ride';

  @override
  String get driverThisWeek => 'This Week';

  @override
  String get driverThisMonth => 'This Month';

  @override
  String get driverCo2Saved => 'CO₂ Saved';

  @override
  String get driverHoursOnline => 'Hours Online';

  @override
  String get locationRequired => 'Location Required';

  @override
  String get enableLocationForBetterExperience =>
      'Enable location for a better driving experience';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get enable => 'Enable';

  @override
  String get createARideToStartEarning => 'Create a ride to start earning';

  @override
  String get wizardStepWelcome => 'Welcome';

  @override
  String get wizardStepWelcomeSubtitle => 'Let\'s get you started';

  @override
  String get wizardStepSecurity => 'Security';

  @override
  String get wizardStepSecuritySubtitle => 'Create a secure password';

  @override
  String get wizardStepRole => 'Your Role';

  @override
  String get wizardStepRoleSubtitle => 'How will you use SportConnect?';

  @override
  String get wizardStepProfile => 'Profile';

  @override
  String get wizardStepProfileSubtitle => 'Make it personal';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPhoneOptional => 'Phone Number (Optional)';

  @override
  String get authPhoneHint => 'Enter Your Phone Number';

  @override
  String get authDateOfBirth => 'Date of Birth *';

  @override
  String get authDobPrompt => 'Tap to select (must be 18+)';

  @override
  String get authDobMinAge =>
      'You must be at least 18 years old to use SportConnect.';

  @override
  String get authDobPicker => 'Select your date of birth';

  @override
  String get authCreatePassword => 'Create Password';

  @override
  String get authPasswordHint => 'Min 8 characters';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authAboutYou => 'About You (Optional)';

  @override
  String get authAboutYouHint => 'Tell us a bit about yourself...';

  @override
  String get wizardFindRides => 'Find Rides';

  @override
  String get wizardFindRidesDesc =>
      'Search for rides to sporting events, practices, and games';

  @override
  String get wizardOfferRides => 'Offer Rides';

  @override
  String get wizardOfferRidesDesc =>
      'Share your car and earn money while helping others';

  @override
  String get wizardContinue => 'Continue';

  @override
  String get authAgreeTermsError => 'Please agree to the Terms of Service';

  @override
  String get authDobError => 'Please enter your date of birth.';

  @override
  String get otpTitle => 'Phone Verification';

  @override
  String get otpEnterPhone => 'Enter your phone number';

  @override
  String get otpPhoneHint => 'Phone number';

  @override
  String get otpSendCode => 'Send Verification Code';

  @override
  String get otpVerifyTitle => 'Verify OTP';

  @override
  String get otpEnterCode => 'Enter the 6-digit code sent to';

  @override
  String get otpVerify => 'Verify';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpResendCode => 'Resend Code';

  @override
  String get otpInvalidCode => 'Invalid verification code. Please try again.';

  @override
  String get otpExpired =>
      'Verification code expired. Please request a new one.';

  @override
  String get otpPhoneRequired => 'Phone number is required';

  @override
  String get otpInvalidPhone => 'Please enter a valid phone number';

  @override
  String get otpSending => 'Sending verification code...';

  @override
  String get otpVerifying => 'Verifying...';

  @override
  String get otpCodeLabel => 'OTP Code';

  @override
  String get otpPhoneVerified => 'Phone Verified!';

  @override
  String get otpPhoneVerifiedDesc =>
      'Your phone number has been verified successfully.';

  @override
  String get otpContinue => 'Continue';

  @override
  String get otpChangePhone => 'Change phone number';

  @override
  String get otpTryAgain => 'Try Again';

  @override
  String get otpBackToLogin => 'Back to Login';

  @override
  String get reauthTitle => 'Verify Your Identity';

  @override
  String get reauthSubtitle =>
      'For your security, please confirm your identity before continuing with this action.';

  @override
  String get reauthPassword => 'Password';

  @override
  String get reauthPasswordHint => 'Enter your current password';

  @override
  String get reauthPasswordRequired => 'Please enter your password';

  @override
  String get reauthConfirm => 'Confirm';

  @override
  String get reauthWithGoogle => 'Verify with Google';

  @override
  String get reauthCancel => 'Cancel';

  @override
  String get reauthWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get reauthFailed => 'Authentication failed. Please try again.';

  @override
  String get reauthGoogleFailed => 'Google re-authentication failed.';

  @override
  String get emailVerifyTitle => 'Verify Email';

  @override
  String get emailVerifyHeading => 'Verify Your Email';

  @override
  String get emailVerifySentTo => 'We\'ve sent a verification link to:';

  @override
  String get emailVerifyWaiting => 'Waiting for verification...';

  @override
  String get emailVerifyResend => 'Resend Verification Email';

  @override
  String emailVerifyResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get emailVerifyCheckButton => 'I\'ve Verified My Email';

  @override
  String get emailVerifySent => 'Verification email sent!';

  @override
  String get emailVerifySendFailed =>
      'Failed to send verification email. Please try again.';

  @override
  String get emailVerified => 'Email Verified!';

  @override
  String get emailVerifiedRedirecting =>
      'Your email has been verified. Redirecting...';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordHeading => 'Update Your Password';

  @override
  String get changePasswordDesc =>
      'Choose a strong password with at least 8 characters, including uppercase, lowercase, and numbers.';

  @override
  String get changePasswordNew => 'New Password';

  @override
  String get changePasswordNewHint => 'Enter new password';

  @override
  String get changePasswordConfirm => 'Confirm Password';

  @override
  String get changePasswordConfirmHint => 'Re-enter new password';

  @override
  String get changePasswordUpdate => 'Update Password';

  @override
  String get changePasswordSuccess => 'Password Updated!';

  @override
  String get changePasswordSuccessDesc =>
      'Your password has been changed successfully. Use your new password next time you sign in.';

  @override
  String get changePasswordDone => 'Done';

  @override
  String get changePasswordWeakError =>
      'Password is too weak. Please choose a stronger password.';

  @override
  String get changePasswordGenericError =>
      'Could not update password. Please try again.';

  @override
  String get forgotPasswordCheckEmail => 'Check Your Email';

  @override
  String get forgotPasswordResendEmail => 'Resend Email';

  @override
  String forgotPasswordResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get forgotPasswordEmailRequired => 'Please enter your email';

  @override
  String get forgotPasswordInvalidEmail => 'Please enter a valid email';

  @override
  String get forgotPasswordSendError =>
      'Could not send reset email right now. Please try again.';

  @override
  String get roleSelectionError => 'Something went wrong. Please try again.';

  @override
  String get accountExistsError =>
      'An account already exists with a different sign-in method. Try signing in with email/password or the original provider.';

  @override
  String get loginErrorUserNotFound => 'No account found with this email.';

  @override
  String get loginErrorWrongPassword =>
      'Incorrect email or password. Please try again.';

  @override
  String get loginErrorTooManyRequests =>
      'Too many login attempts. Please try again later.';

  @override
  String get loginErrorNetwork =>
      'Network error. Please check your connection.';

  @override
  String get loginErrorInvalidEmail => 'Invalid email address.';

  @override
  String get signUpFailedPleaseTry => 'Sign up failed. Please try again.';

  @override
  String get periodToday => 'Today';

  @override
  String get periodThisWeek => 'This Week';

  @override
  String get periodThisMonth => 'This Month';

  @override
  String get periodAllTime => 'All Time';

  @override
  String get statRides => 'Rides';

  @override
  String get statEarnings => 'Earnings';

  @override
  String get statOnlineHours => 'Online Hours';

  @override
  String get statAvgRating => 'Avg Rating';

  @override
  String get connectStripeAccount => 'Connect Stripe Account';

  @override
  String get benefitInstantPayoutsDesc => 'Get your money in minutes, not days';

  @override
  String get benefitSecureDesc => 'Bank-level security with Stripe';

  @override
  String get benefitTrackingDesc => 'See every ride payment in detail';

  @override
  String get benefitLowFeesDesc => 'Keep 85% of every ride payment';

  @override
  String get pleaseSignInToContinue => 'Please sign in to continue';

  @override
  String get poweredByStripe => 'Powered by Stripe • Secure and encrypted';

  @override
  String get cancelSetupTitle => 'Cancel Setup?';

  @override
  String get cancelSetupMessage =>
      'Are you sure you want to cancel? You won\'t be able to receive payouts until you complete this setup.';

  @override
  String get continueSetup => 'Continue Setup';

  @override
  String get filterAll => 'All';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterRefunded => 'Refunded';

  @override
  String get filterFailed => 'Failed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get statusPartiallyRefunded => 'Partially Refunded';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get details => 'Details';

  @override
  String get refundRequestSubmitted => 'Refund request submitted successfully';

  @override
  String get refundRequestFailed => 'Refund request failed. Please try again.';

  @override
  String get payoutDetails => 'Payout Details';

  @override
  String get payoutNotFound => 'Payout not found';

  @override
  String get totalPayout => 'Total Payout';

  @override
  String get breakdown => 'Breakdown';

  @override
  String get timeline => 'Timeline';

  @override
  String get grossEarnings => 'Gross Earnings';

  @override
  String get netPayout => 'Net Payout';

  @override
  String get payoutCreated => 'Payout Created';

  @override
  String get fees => 'Fees';

  @override
  String get payoutAmount => 'Payout Amount';

  @override
  String get instantPayout => 'Instant Payout';

  @override
  String get payoutDetailsSection => 'Details';

  @override
  String get expectedArrival => 'Expected Arrival';

  @override
  String get arrivedAt => 'Arrived At';

  @override
  String get bankName => 'Bank Name';

  @override
  String get accountEnding => 'Account Ending';

  @override
  String get failureReason => 'Failure Reason';

  @override
  String get cancelPayout => 'Cancel Payout';

  @override
  String get cancelPayoutConfirm =>
      'Are you sure you want to cancel this payout? This action cannot be undone.';

  @override
  String get payoutCancelled => 'Payout cancelled successfully';

  @override
  String get payoutCancelFailed => 'Failed to cancel payout. Please try again.';

  @override
  String get payoutPendingDesc =>
      'Your payout is being processed and will be sent shortly.';

  @override
  String get payoutInTransit => 'In Transit';

  @override
  String get payoutInTransitDesc =>
      'Your payout has been sent and is on its way to your bank.';

  @override
  String get payoutPaid => 'Paid';

  @override
  String get payoutPaidDesc => 'Your payout has arrived in your bank account.';

  @override
  String get payoutFailedDesc =>
      'This payout failed. Check the failure reason below.';

  @override
  String get payoutCancelledDesc => 'This payout was cancelled.';

  @override
  String get stripeVerifyingAccount => 'Verifying your account...';

  @override
  String get stripeAccountCreationFailed =>
      'Failed to create Stripe account. Please try again.';

  @override
  String get stripeSetupFailed =>
      'Could not start Stripe setup right now. Please try again.';

  @override
  String get stripePageLoadFailed => 'Failed to load page. Please try again.';

  @override
  String get stripeLoadingConnect => 'Loading Stripe Connect...';

  @override
  String get stripeAdditionalInfoNeeded =>
      'Additional information needed. Please complete all fields.';

  @override
  String get stripeVerifyFailed =>
      'Could not verify account right now. Please try again.';

  @override
  String get unableToLoadData => 'Unable to load data. Pull to refresh.';

  @override
  String get exportEarningsReport => 'Earnings Report';

  @override
  String get exportGenerated => 'Generated';

  @override
  String get exportEarningsSummary => 'EARNINGS SUMMARY';

  @override
  String get exportRideStatistics => 'RIDE STATISTICS';

  @override
  String get exportRecentTransactions => 'RECENT TRANSACTIONS';

  @override
  String get driverProfileTitle => 'Complete Your Profile';

  @override
  String get driverProfileSubtitle =>
      'Tell us about yourself so riders can get to know you.';

  @override
  String get driverCityLabel => 'City';

  @override
  String get driverCityHint => 'Where are you based?';

  @override
  String get driverCityRequired => 'Please enter your city';

  @override
  String get driverGenderRequired => 'Please select your gender.';

  @override
  String get expertiseLevel => 'Expertise Level';

  @override
  String get expertiseLevelRequired => 'Please select your expertise level.';

  @override
  String get driverInterestsRequired => 'Please select at least one interest.';

  @override
  String get driverTermsLabel =>
      'I agree to the Terms of Service and Privacy Policy.';

  @override
  String get driverTermsRequired =>
      'You must accept Terms and Privacy to continue.';

  @override
  String get driverSaveAndContinue => 'Save & Continue';

  @override
  String get ratingExcellent => 'Excellent!';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingAverage => 'Average';

  @override
  String get ratingBelowAverage => 'Below Average';

  @override
  String get ratingPoor => 'Poor';

  @override
  String get findRidesNearYou => 'Find Rides Near You';

  @override
  String get exploreOnMap => 'Explore on Map';

  @override
  String get howItWorks => 'How it works';

  @override
  String get pickupAndDropoff => 'Pickup & Drop-off';

  @override
  String get enterPickupAndDestination =>
      'Enter your pickup and destination locations';

  @override
  String get selectDate => 'Select Date';

  @override
  String get chooseWhenYouWantToTravel => 'Choose when you want to travel';

  @override
  String get findAndBook => 'Find & Book';

  @override
  String get browseAvailableRidesAndBook =>
      'Browse available rides and book instantly';

  @override
  String get verifiedDrivers => 'Verified Drivers';

  @override
  String get allDriversAreVerified =>
      'All drivers are verified for your safety and comfort';

  @override
  String get locationGateDescription =>
      'Enable location to discover rides near you, get accurate pickup times, and navigate safely.';

  @override
  String get locationBenefitFind => 'Find rides near your location';

  @override
  String get locationBenefitNavigate => 'Get turn-by-turn navigation';

  @override
  String get locationBenefitSafety => 'Enhanced safety features';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get browseWithoutLocation => 'Browse without location';

  @override
  String get findingYourLocation => 'Finding your location...';

  @override
  String get thisWillOnlyTakeAMoment => 'This will only take a moment';

  @override
  String get locationNotEnabled => 'Location Not Enabled';

  @override
  String get locationNotEnabledDescription =>
      'Location access is off. You can still browse rides by city.';

  @override
  String get browseByCity => 'Browse by City';

  @override
  String get locationPermissionBlocked => 'Location Permission Blocked';

  @override
  String get locationPermissionBlockedDescription =>
      'Location access is off in device settings. Features that need your current location are unavailable until changed in Settings.';

  @override
  String get locationServicesOff => 'Location Services Off';

  @override
  String get locationServicesOffDescription =>
      'Your device\'s location services are turned off. Features that need your current location are unavailable until changed in Settings.';

  @override
  String get openLocationSettings => 'Open Location Settings';

  @override
  String get events => 'events';

  @override
  String get satellite => 'Satellite';

  @override
  String get maxSeatsReached => 'Maximum 4 seats per booking';

  @override
  String get tryADifferentDate => 'Try a different date';

  @override
  String get tapToOpenNavigation => 'Tap to open navigation';

  @override
  String get completePayment => 'Complete Payment';

  @override
  String get bookingAcceptedPaymentRequired =>
      'Your booking is accepted. Payment required.';

  @override
  String get tapToViewCountdown => 'Tap to view countdown';

  @override
  String get departingTomorrow => 'Departing tomorrow';

  @override
  String departingValue(String value) {
    return 'Departing $value';
  }

  @override
  String awaitingDriverCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Awaiting driver • $count pending',
      one: 'Awaiting driver',
    );
    return '$_temp0';
  }

  @override
  String departingTodayAt(String h, String m) {
    return 'Departing today at $h:$m';
  }

  @override
  String departingInDays(int days) {
    return 'Departing in $days days';
  }

  @override
  String get createEventTitle => 'Create Event';

  @override
  String get editEventTitle => 'Edit Event';

  @override
  String get myEventsTitle => 'My Events';

  @override
  String get discoverEventsTitle => 'Discover Events';

  @override
  String get eventSportType => 'Sport Type';

  @override
  String get eventTitleField => 'Event Title *';

  @override
  String get eventTitleRequired => 'Title is required';

  @override
  String get eventTitleMinLength => 'Title must be at least 3 characters';

  @override
  String get eventVenueName => 'Venue Name (optional)';

  @override
  String get eventDescriptionField => 'Description (optional)';

  @override
  String get eventCoverImage => 'Cover Image (optional)';

  @override
  String get eventTapToAddPhoto => 'Tap to add a cover photo';

  @override
  String get eventLocationField => 'Location *';

  @override
  String get eventTapToPickLocation => 'Tap to pick a location on the map';

  @override
  String get eventWhenField => 'When *';

  @override
  String get eventStartDate => 'Start date';

  @override
  String get eventStartTime => 'Start time';

  @override
  String get eventEndDate => 'End date';

  @override
  String get eventEndTime => 'End time';

  @override
  String get eventOptional => 'Optional';

  @override
  String get eventEndLabel => 'End';

  @override
  String get eventAddEndTime => '+ Add end time';

  @override
  String get eventMaxParticipants => 'Max Participants';

  @override
  String get eventUnlimited => 'Unlimited';

  @override
  String get eventParkingInstructions => 'Parking instructions (optional)';

  @override
  String get eventRecurring => 'Recurring Event';

  @override
  String get eventRecurringSubtitle => 'Repeats on selected days each week';

  @override
  String eventRepeatsUntil(String date) {
    return 'Repeats until $date';
  }

  @override
  String get eventRepeatEndDate => 'Repeat end date (optional)';

  @override
  String get eventUploadingCover => 'Uploading cover…';

  @override
  String get eventCreating => 'Creating…';

  @override
  String get eventCreateButton => 'Create Event';

  @override
  String get eventSaveChanges => 'Save Changes';

  @override
  String get eventStartTimeFuture => 'Start time must be in the future.';

  @override
  String get eventEndTimeAfterStart => 'End time must be after start time.';

  @override
  String get eventLocationTitle => 'Event Location';

  @override
  String get eventDeleteConfirmTitle => 'Delete Event?';

  @override
  String get eventDeleteWarning =>
      'This action cannot be undone. All participants will be removed.';

  @override
  String get eventAbout => 'About';

  @override
  String get eventParticipants => 'Participants';

  @override
  String get eventLeave => 'Leave Event';

  @override
  String get eventFull => 'Event Full';

  @override
  String get eventJoin => 'Join Event';

  @override
  String get eventEdit => 'Edit Event';

  @override
  String get eventDelete => 'Delete Event';

  @override
  String get eventNoRidesOffered => 'No rides offered yet';

  @override
  String get eventCouldNotLoadRides => 'Could not load rides';

  @override
  String get eventHowGettingThere => 'How are you getting there?';

  @override
  String get eventImDriving => 'I\'m Driving';

  @override
  String get eventNeedRide => 'Need Ride';

  @override
  String get eventSelfArranged => 'Self-Arranged';

  @override
  String get eventYouAreOrganizer => 'You are the organizer';

  @override
  String get eventYouOrganized => 'You organized this event';

  @override
  String get eventYoureGoing => 'You\'re going';

  @override
  String get eventYouAttended => 'You attended';

  @override
  String get eventNotJoinedYet => 'You haven\'t joined yet';

  @override
  String get eventHasEnded => 'This event has ended';

  @override
  String get eventRidesToEvent => 'Rides to This Event';

  @override
  String get eventRecurringTitle => 'Recurring Event';

  @override
  String get eventEvery => 'Every';

  @override
  String eventUntilDate(String date) {
    return 'until $date';
  }

  @override
  String get eventCostSplitEnabled => 'Cost Split Enabled';

  @override
  String get eventMeetupPoint => 'Post-Event Meetup Point';

  @override
  String get eventNoMeetupPoint => 'No meetup point set yet';

  @override
  String get eventSetMeetupPoint => 'Set Meetup Point';

  @override
  String get eventGroupChat => 'Event Group Chat';

  @override
  String get eventNotFound => 'Event not found.';

  @override
  String get eventOrganizedThis => 'You organized this event';

  @override
  String eventParticipantsCount(int count) {
    return 'Participants ($count)';
  }

  @override
  String eventSeatsLeftCount(int count) {
    return '$count left';
  }

  @override
  String eventCountdownDaysHours(int days, int hours) {
    return 'In ${days}d ${hours}h';
  }

  @override
  String eventCountdownHoursMinutes(int hours, int minutes) {
    return 'In ${hours}h ${minutes}m';
  }

  @override
  String eventCountdownMinutes(int minutes) {
    return 'In ${minutes}m';
  }

  @override
  String get eventNeedRideHome => 'Need Ride Home';

  @override
  String get eventFindRides => 'Find Rides to Event';

  @override
  String get eventOfferRide => 'Offer Ride to Event';

  @override
  String get eventOrganizer => 'Organizer';

  @override
  String get myEventsCreatedTab => 'Created';

  @override
  String get myEventsJoinedTab => 'Joined';

  @override
  String get signInFirstMessage => 'Sign in first.';

  @override
  String get unableToLoadEvents => 'Unable to load events.';

  @override
  String get noCreatedEvents => 'You haven\'t created any events yet.';

  @override
  String get noJoinedEvents => 'You haven\'t joined any events yet.';

  @override
  String get browseEventsButton => 'Browse Events';

  @override
  String get eventPastStatus => 'Past';

  @override
  String get eventFullStatus => 'Full';

  @override
  String get searchEventsHint => 'Search events…';

  @override
  String get noEventsFound => 'No events found';

  @override
  String noEventsInCategory(String category) {
    return 'No upcoming $category events.';
  }

  @override
  String get beFirstToCreate => 'Be the first to create one!';

  @override
  String get eventJoinArrow => 'Join →';

  @override
  String eventByOrganizer(String name) {
    return 'by $name';
  }

  @override
  String get createLabel => 'Create';

  @override
  String get selectLocationError => 'Please select a location.';

  @override
  String get pastStartTimeError => 'Start time must be in the future.';

  @override
  String get endBeforeStartError => 'End time must be after start time.';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get legalVersionBadge => 'Feb 2026';

  @override
  String get loadingTermsOfService => 'Loading Terms of Service…';

  @override
  String get loadingPrivacyPolicy => 'Loading Privacy Policy…';

  @override
  String get reportIssueTitle => 'Report an Issue';

  @override
  String get attachEvidence => 'Attach evidence';

  @override
  String get whatHappenedQuestion => 'What happened?';

  @override
  String get howSevereQuestion => 'How severe is this issue?';

  @override
  String get describeIssueLabel => 'Describe the issue';

  @override
  String get describeIssuePlaceholder =>
      'Please provide at least 50 characters...';

  @override
  String get evidenceOptionalLabel => 'Evidence (optional)';

  @override
  String get attachScreenshotsPlaceholder =>
      'Tap to attach screenshots or evidence';

  @override
  String filesAttachedCount(int count, int max) {
    return '$count/$max files attached';
  }

  @override
  String get supportsImagesHint => 'Supports images (max 10MB each)';

  @override
  String get submitReportButton => 'Submit Report';

  @override
  String get reportSubmittedTitle => 'Report Submitted';

  @override
  String get reportSubmittedMessage =>
      'Thank you for reporting this issue. Our safety team will review it and take appropriate action within 24-48 hours. You will receive an email when your issue is resolved.';

  @override
  String get doneButton => 'Done';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String rideInfoLabel(String id) {
    return 'Ride: $id';
  }

  @override
  String get reportSafety => 'Safety';

  @override
  String get reportSafetyDesc => 'Safety concerns or dangerous behavior';

  @override
  String get reportPayment => 'Payment';

  @override
  String get reportPaymentDesc => 'Billing or payment issues';

  @override
  String get reportBehavior => 'Behavior';

  @override
  String get reportBehaviorDesc => 'Inappropriate or rude behavior';

  @override
  String get reportTechnical => 'Technical';

  @override
  String get reportTechnicalDesc => 'App bugs or technical issues';

  @override
  String get reportDiscrimination => 'Discrimination';

  @override
  String get reportDiscriminationDesc =>
      'Discriminatory treatment or harassment';

  @override
  String get reportOther => 'Other';

  @override
  String get reportOtherDesc => 'Issues not listed above';

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';

  @override
  String get severityCritical => 'Critical';

  @override
  String get driverMyRidesTitle => 'My Rides';

  @override
  String get viewRequestsTooltip => 'View requests';

  @override
  String get pendingRequestsTitle => 'Pending Requests';

  @override
  String get noPendingRequestsTitle => 'No Pending Requests';

  @override
  String get noPendingRequestsMessage =>
      'New booking requests will appear here.';

  @override
  String get upcomingRidesTitle => 'Upcoming Rides';

  @override
  String get noUpcomingRidesTitle => 'No Upcoming Rides';

  @override
  String get useButtonToOfferRide =>
      'Use the button below to offer a new ride.';

  @override
  String get couldNotLoadRequests =>
      'Could not load requests. Pull to refresh.';

  @override
  String get couldNotLoadRides => 'Could not load rides. Pull to refresh.';

  @override
  String get declineRequestTitle => 'Decline Request?';

  @override
  String get declineRequestMessage =>
      'This will decline the booking request. The passenger will be notified.';

  @override
  String get keepButton => 'Keep';

  @override
  String get declineButton => 'Decline';

  @override
  String get acceptRequestTitle => 'Accept Request?';

  @override
  String acceptRequestMessage(String name) {
    return 'Accept this booking from $name?';
  }

  @override
  String get acceptButton => 'Accept';

  @override
  String get cancelRideTitle => 'Cancel Ride';

  @override
  String get cancelRideConfirmMessage =>
      'Are you sure you want to cancel this ride? This action cannot be undone.';

  @override
  String get keepRideButton => 'Keep Ride';

  @override
  String get pickupLabel => 'Pickup';

  @override
  String get dropoffLabel => 'Dropoff';

  @override
  String seatsCount(int count) {
    return '$count seat(s)';
  }

  @override
  String get offerARideTitle => 'Offer a Ride';

  @override
  String get editRideTitle => 'Edit Ride';

  @override
  String get routeStep => 'Route';

  @override
  String get detailsStep => 'Details';

  @override
  String get preferencesStep => 'Preferences';

  @override
  String get driverProfileRequired => 'Driver Profile Required';

  @override
  String get completeDriverProfileMessage =>
      'Complete your driver profile to offer rides.';

  @override
  String get becomeDriverButton => 'Become a Driver';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get selectPickupLocation => 'Select pickup location';

  @override
  String get selectDropoffLocation => 'Select dropoff location';

  @override
  String get swapLocationsTooltip => 'Swap locations';

  @override
  String get departureTimeLabel => 'Departure Time';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get selectDatePlaceholder => 'Select Date';

  @override
  String get selectTimePlaceholder => 'Select Time';

  @override
  String get intermediateStopsLabel => 'Intermediate Stops';

  @override
  String get addStopButton => 'Add Stop';

  @override
  String get addStopsHint =>
      'Add stops along your route to pick up more passengers';

  @override
  String get rideDetailsTitle => 'Ride Details';

  @override
  String get quickSwitchButton => 'Quick Switch';

  @override
  String get noVehiclesError =>
      'No vehicles found. Please add a vehicle to your profile.';

  @override
  String get addVehicleButton => 'Add Vehicle';

  @override
  String get availableSeatsLabel => 'Available Seats';

  @override
  String get totalCapacityLabel => 'Total Capacity:';

  @override
  String get pricePerSeatLabel => 'Price per Seat';

  @override
  String get minimumPriceError => 'Minimum €1';

  @override
  String get priceNegotiableToggle => 'Price Negotiable';

  @override
  String get acceptOnlinePaymentToggle => 'Accept Online Payment';

  @override
  String get preferencesRulesTitle => 'Preferences & Rules';

  @override
  String get rideSummaryLabel => 'Ride Summary';

  @override
  String get allowPetsToggle => 'Allow Pets';

  @override
  String get allowSmokingToggle => 'Allow Smoking';

  @override
  String get allowLuggageToggle => 'Allow Luggage';

  @override
  String get womenOnlyToggle => 'Women Only';

  @override
  String get maxDetourLabel => 'Max Detour for Pickups';

  @override
  String get maxDetourHint =>
      'How far you\'re willing to go off-route to pick up passengers';

  @override
  String get noneLabel => 'None';

  @override
  String get sixtyMinLabel => '60 min';

  @override
  String get backButton => 'Back';

  @override
  String get nextButton => 'Next';

  @override
  String get createRideButton => 'Create Ride';

  @override
  String get recurringRideTitle => 'Recurring Ride';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String stopNumberLabel(int number) {
    return 'Stop $number';
  }

  @override
  String get tapToSetLocation => 'Tap to set location';

  @override
  String get editWaypointTooltip => 'Edit waypoint';

  @override
  String get removeWaypointTooltip => 'Remove waypoint';

  @override
  String selectStopTitle(int number) {
    return 'Select Stop $number';
  }

  @override
  String editStopTitle(int number) {
    return 'Edit Stop $number';
  }

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String totalCapacityCount(int count) {
    return 'Total Capacity: $count';
  }

  @override
  String totalPriceForSeats(String price, int seats) {
    return 'Total: €$price for $seats seats';
  }

  @override
  String get decreasePriceTooltip => 'Decrease price';

  @override
  String get increasePriceTooltip => 'Increase price';

  @override
  String get allowPetsSubtitle => 'Pets are allowed in the car';

  @override
  String get allowSmokingSubtitle => 'Smoking is allowed during the ride';

  @override
  String get allowLuggageSubtitle => 'Passengers can bring luggage';

  @override
  String get womenOnlySubtitle => 'Ride is for women only';

  @override
  String get notSetPlaceholder => 'Not set';

  @override
  String get notSelectedPlaceholder => 'Not selected';

  @override
  String get summaryStopsLabel => 'Stops';

  @override
  String intermediateStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intermediate stops',
      one: '1 intermediate stop',
    );
    return '$_temp0';
  }

  @override
  String get departureSummaryLabel => 'Departure';

  @override
  String get seatsSummaryLabel => 'Seats';

  @override
  String seatsAvailableCount(int count) {
    return '$count available';
  }

  @override
  String get priceSummaryLabel => 'Price';

  @override
  String pricePerSeatSummary(String price) {
    return '€$price per seat';
  }

  @override
  String pricePerSeatNegotiableSummary(String price) {
    return '€$price per seat (negotiable)';
  }

  @override
  String get eventSummaryLabel => 'Event';

  @override
  String get recurringSummaryLabel => 'Recurring';

  @override
  String get selectOriginTitle => 'Select Origin';

  @override
  String get selectDestinationTitle => 'Select Destination';

  @override
  String maxDetourMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get timeInPastWarning =>
      'Selected time is in the past — the Create Ride button will be disabled';

  @override
  String get departureMinimumWarning =>
      'Departure should be at least 15 minutes from now for passengers to join';

  @override
  String get departureAfterEventWarning =>
      'Departure time is after the event ends — please choose an earlier time';

  @override
  String get rideUpdatedSuccess => 'Ride updated successfully!';

  @override
  String get rideCreatedSuccess => 'Ride created successfully!';

  @override
  String get bookingRequestTitle => 'Booking Request';

  @override
  String get requestSentTitle => 'Request Sent!';

  @override
  String get bookingAcceptedTitle => 'Booking Accepted!';

  @override
  String get waitingForConfirmation =>
      'Waiting for the driver to confirm your booking. You\'ll be notified as soon as they respond.';

  @override
  String get completePaymentMessage =>
      'Complete your payment to confirm the ride.';

  @override
  String get processingPaymentLoading => 'Processing payment...';

  @override
  String get completePaymentButton => 'Complete Payment';

  @override
  String get expiresInLabel => 'Expires in';

  @override
  String get cancelRequestButton => 'Cancel Request';

  @override
  String get viewAllMyRidesButton => 'View All My Rides';

  @override
  String get yourDriverLabel => 'Your Driver';

  @override
  String get yourRideTitle => 'Your Ride';

  @override
  String get bookingConfirmedBadge => 'Booking Confirmed';

  @override
  String get departureInLabel => 'Departure in';

  @override
  String get departingSoonLabel => 'Departing soon!';

  @override
  String get rideStartedMessage => 'Ride has started!';

  @override
  String get routeLabel => 'Route';

  @override
  String get messageButton => 'Message';

  @override
  String passengerRequestCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passenger requests',
      one: '1 passenger request',
    );
    return '$_temp0';
  }

  @override
  String get callButton => 'Call';

  @override
  String get failedOpenChatError => 'Failed to open chat. Please try again.';

  @override
  String get driverPhoneUnavailableError =>
      'Driver phone number not available.';

  @override
  String get couldNotLaunchDialerError => 'Could not launch phone dialer.';

  @override
  String get seatsLabel => 'Seats';

  @override
  String get refNumberLabel => 'Ref #';

  @override
  String get tapToCopyInstruction => '(tap to copy)';

  @override
  String get totalLabel => 'Total';

  @override
  String get estimatedArrivalLabel => 'Est. arrival:';

  @override
  String get joinActiveRideButton => 'Join Active Ride';

  @override
  String get viewRideDetailsButton => 'View Ride Details';

  @override
  String get fileDisputeTitle => 'File a Dispute';

  @override
  String get rideIdLabel => 'Ride ID';

  @override
  String get disputeTypeLabel => 'Dispute Type';

  @override
  String get selectDisputeReason => 'Select the reason for your dispute';

  @override
  String get incorrectFareType => 'Incorrect Fare';

  @override
  String get incorrectFareDesc =>
      'The fare charged was different from the quoted amount';

  @override
  String get incompleteRideType => 'Incomplete Ride';

  @override
  String get incompleteRideDesc =>
      'The ride did not reach the intended destination';

  @override
  String get unauthorizedChargeType => 'Unauthorized Charge';

  @override
  String get unauthorizedChargeDesc =>
      'I was charged without authorization or for a cancelled ride';

  @override
  String get poorServiceType => 'Poor Service';

  @override
  String get poorServiceDesc => 'The ride quality was unacceptable';

  @override
  String get safetyConcernType => 'Safety Concern';

  @override
  String get safetyConcernDesc => 'I felt unsafe during the ride';

  @override
  String get otherDisputeType => 'Other';

  @override
  String get otherDisputeDesc => 'A different issue not listed above';

  @override
  String get detailsLabel => 'Details';

  @override
  String get describeIssueDetailPlaceholder =>
      'Describe your issue in detail...';

  @override
  String get disputeWarningNote =>
      'Disputes are reviewed within 24-48 hours. Submitting false disputes may result in account restrictions.';

  @override
  String get attachReceiptsPlaceholder => 'Attach receipts or screenshots';

  @override
  String get whatToExpectTitle => 'What to expect';

  @override
  String get reviewWithinHours => 'Review within 24-48 hours';

  @override
  String get emailNotificationExpectation =>
      'Email notification on status updates';

  @override
  String get fairResolutionExpectation => 'Fair resolution based on evidence';

  @override
  String get submitDisputeButton => 'Submit Dispute';

  @override
  String get disputeSubmittedTitle => 'Dispute Submitted';

  @override
  String get disputeSubmittedMessage =>
      'Our team will review your dispute within 24-48 hours. You\'ll receive a notification once it\'s resolved.';

  @override
  String get previousStepTooltip => 'Previous step';

  @override
  String get goBackTooltip => 'Go back';

  @override
  String get nameRequiredError => 'Name is required';

  @override
  String get nameMinLengthError => 'Name must be at least 2 characters';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get emailVerificationError =>
      'Something went wrong. Please try again.';

  @override
  String get useDifferentAccount => 'Use a different account';

  @override
  String get builtWithFlutter => 'Built with Flutter';

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String get signingInMessage => 'Signing in, please wait';

  @override
  String get loadingProfileMessage => 'Please wait, loading your profile...';

  @override
  String get riderOnboardingTitle => 'Rider onboarding';

  @override
  String get completeRiderProfile => 'Complete your rider profile';

  @override
  String get riderProfileDescription =>
      'Add your details so we can personalize rides and matching for you.';

  @override
  String get completeSetupButton => 'Complete setup';

  @override
  String get riderRoleDescription =>
      'Find and book rides to sporting events. Save money and reduce your carbon footprint.';

  @override
  String get riderFeatureSearch => 'Search available rides';

  @override
  String get riderFeatureBook => 'Book seats instantly';

  @override
  String get riderFeatureChat => 'Chat with drivers';

  @override
  String get riderFeatureTrack => 'Track your ride';

  @override
  String get driverRoleDescription =>
      'Offer rides and earn money while going to events. Help others get there safely.';

  @override
  String get driverFeatureCreate => 'Create ride offers';

  @override
  String get driverFeaturePrice => 'Set your own price';

  @override
  String get driverFeatureAccept => 'Accept ride requests';

  @override
  String get driverFeatureEarn => 'Earn with each trip';

  @override
  String get continueButton => 'Continue';

  @override
  String get yourDetailsStep => 'Your Details';

  @override
  String get securityStep => 'Security';

  @override
  String get yourRoleStep => 'Your Role';

  @override
  String get yourProfileStep => 'Your Profile';

  @override
  String stepOfCount(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get searchUsersTooltip => 'Search users';

  @override
  String get muteChat => 'Mute';

  @override
  String get unmuteChat => 'Unmute';

  @override
  String get deleteChat => 'Delete';

  @override
  String get paymentDetailsLabel => 'Details';

  @override
  String get ridePaymentLabel => 'Ride Payment';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutAppDescription =>
      'SportConnect is a social carpooling platform that connects sports enthusiasts. Share rides, reduce your carbon footprint, and build your sports community.';

  @override
  String get ecoStatLabel => 'Eco';

  @override
  String get liveStatLabel => 'Live';

  @override
  String get sportStatLabel => 'Sport';

  @override
  String get rideShareLabel => 'Ride-Share';

  @override
  String get trackingLabel => 'Tracking';

  @override
  String get communityLabel => 'Community';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get joinTheCommunity => 'Join the Community';

  @override
  String get websiteLabel => 'Website';

  @override
  String get emailLabel => 'Email';

  @override
  String get copyrightNotice =>
      '© 2025-2026 SportConnect. All rights reserved.';

  @override
  String get howCanWeHelp => 'How can we help?';

  @override
  String get responseTimeMessage => 'We typically respond within 24 hours.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get subjectHint => 'Brief description of your issue';

  @override
  String get messageFieldLabel => 'Message';

  @override
  String get messageFieldHint => 'Describe your issue in detail...';

  @override
  String get attachFilesHint => 'Attach screenshots or files (optional)';

  @override
  String get submitTicketButton => 'Submit Ticket';

  @override
  String get responseTimeInfo =>
      'Most inquiries are answered within 12-24 hours';

  @override
  String get ticketSubmittedTitle => 'Ticket Submitted!';

  @override
  String get ticketSubmittedMessage =>
      'We\'ve received your message and will get back to you within 24 hours. You will receive an email when your issue is resolved.';

  @override
  String get findPeopleTitle => 'Find People';

  @override
  String get searchByNameHint => 'Search by name';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get asDriverFilter => 'As Driver';

  @override
  String get asRiderFilter => 'As Rider';

  @override
  String get additionalCommentsLabel => 'Additional comments (optional)';

  @override
  String get specificFeedbackHelps => 'Specific feedback helps the community';

  @override
  String get thankYouForReview => 'Thank you for your review!';

  @override
  String get submitRatingButton => 'Submit Rating';

  @override
  String get skipForNowButton => 'Skip for now';

  @override
  String get navigateButton => 'Navigate';

  @override
  String get noActiveRideMessage => 'No active ride';

  @override
  String get ratePassengerTitle => 'Rate Passenger';

  @override
  String get howWasYourPassenger => 'How was your passenger?';

  @override
  String get cancelledLabel => 'Cancelled';

  @override
  String get completedLabel => 'Completed';

  @override
  String get scheduledLabel => 'Scheduled';

  @override
  String get activeLabel => 'Active';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get cancellationReasonTitle => 'Why are you cancelling?';

  @override
  String get cancellationReasonHint =>
      'Tell us more about why you\'re cancelling...';

  @override
  String get confirmCancellationButton => 'Confirm Cancellation';

  @override
  String get rideCompletedTitle => 'Ride Completed!';

  @override
  String get rideCompletedSubtitle => 'How was your experience?';

  @override
  String get rideNavigationTitle => 'Ride Navigation';

  @override
  String get startNavigationButton => 'Start Navigation';

  @override
  String get arriveAtPickupButton => 'Arrive at Pickup';

  @override
  String get startTripButton => 'Start Trip';

  @override
  String get endTripButton => 'End Trip';

  @override
  String get passengerPickupLabel => 'Passenger pickup';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get supportCategoryGeneral => 'General';

  @override
  String get supportCategoryAccountIssue => 'Account Issue';

  @override
  String get supportCategoryPaymentProblem => 'Payment Problem';

  @override
  String get supportCategoryRideIssue => 'Ride Issue';

  @override
  String get supportCategoryTechnicalBug => 'Technical Bug';

  @override
  String get supportCategorySafetyReport => 'Safety Report';

  @override
  String get supportCategoryFeatureRequest => 'Feature Request';

  @override
  String get driversLabel => 'Drivers';

  @override
  String get ridersLabel => 'Riders';

  @override
  String get sportsLabel => 'Sports';

  @override
  String get yourJourneyStartsHere => 'Your Journey Starts Here';

  @override
  String get searchRidesAndConnect =>
      'Search for rides and connect with verified drivers heading your way';

  @override
  String get searchForRides => 'Search for Rides';

  @override
  String get easyBooking => 'Easy Booking';

  @override
  String get bookInJustAFewTaps => 'Book in just a few taps';

  @override
  String get realTimeTracking => 'Real-time Tracking';

  @override
  String get trackYourRideLive => 'Track your ride live';

  @override
  String get startSharingTheRoad => 'Start Sharing the Road';

  @override
  String get offerFirstRideMessage =>
      'Offer your first ride and connect with riders heading your way';

  @override
  String get connectWithRiders => 'Connect';

  @override
  String get earnPerRide => 'Earn';

  @override
  String get flexibleSchedule => 'Flexible';

  @override
  String get offerYourFirstRide => 'Offer Your First Ride';

  @override
  String get noRidesYetTitle => 'No Rides Yet';

  @override
  String get noRidesYetSubtitle =>
      'Find a carpool to your next game, practice, or event. Share the ride, split the cost.';

  @override
  String get findACarpoolNow => 'Find a Carpool';

  @override
  String get allDriversVerifiedAndRated => 'All drivers are verified and rated';

  @override
  String get levelAndXp => 'Level & XP';

  @override
  String get viewAchievements => 'View achievements';

  @override
  String get maxLevel => 'Max Level Reached!';

  @override
  String get challengeCompleted => 'Completed!';

  @override
  String get challengeInProgress => 'In progress';

  @override
  String get challengeFirstRide => 'First Ride';

  @override
  String get challengeFirstRideDesc => 'Complete your first carpool ride';

  @override
  String get challengeRideRegular => 'Ride Regular';

  @override
  String get challengeRideRegularDesc => 'Complete 10 rides';

  @override
  String get challengeRoadTripper => 'Road Tripper';

  @override
  String get challengeRoadTripperDesc => 'Travel 50 km total';

  @override
  String get challengeDistanceMaster => 'Distance Master';

  @override
  String get challengeDistanceMasterDesc => 'Travel 100 km total';

  @override
  String get challengeStreakBuilder => 'Streak Builder';

  @override
  String get challengeStreakBuilderDesc => 'Maintain a 7-day ride streak';

  @override
  String get challengeCenturyRider => 'Century Rider';

  @override
  String get challengeCenturyRiderDesc => 'Complete 100 rides';

  @override
  String get chatMuted => 'Chat muted';

  @override
  String get chatUnmuted => 'Chat unmuted';

  @override
  String get deleteConversationTitle => 'Delete conversation?';

  @override
  String get deleteConversationMessage =>
      'This will remove the conversation from your list.';

  @override
  String get conversationRemoved => 'Conversation removed';

  @override
  String get timeNow => 'now';

  @override
  String get creatingChatLabel => 'Creating chat';

  @override
  String get failedToCreateChatTryAgain =>
      'Failed to create chat. Please try again.';

  @override
  String get reportUser => 'Report User';

  @override
  String get blockUser => 'Block User';

  @override
  String get blockUserDialogTitle => 'Block User';

  @override
  String blockUserDialogMessage(String name) {
    return 'Block $name? You will no longer receive messages from this user.';
  }

  @override
  String get blockUserDialogMessageGeneric =>
      'Are you sure you want to block this user? You will no longer see their content or receive messages from them.';

  @override
  String blockedUserSuccess(String name) {
    return '$name has been blocked.';
  }

  @override
  String get userBlocked => 'User has been blocked.';

  @override
  String get couldNotBlockUserTryAgain =>
      'Could not block user. Please try again.';

  @override
  String get unblockUser => 'Unblock user';

  @override
  String unblockUserDialogMessage(String name) {
    return 'Unblock $name?';
  }

  @override
  String get actionUnblock => 'Unblock';

  @override
  String get userUnblocked => 'User unblocked.';

  @override
  String get couldNotUnblockUserTryAgain =>
      'Could not unblock user. Please try again.';

  @override
  String get youBlockedThisUser => 'You blocked this user.';

  @override
  String get actionBlock => 'Block';

  @override
  String get downloadReceipt => 'Download Receipt';

  @override
  String get notificationsAlreadyEnabled =>
      'Notifications are already enabled.';

  @override
  String get notificationPermissionRequested =>
      'Notification permission requested.';

  @override
  String get pauseDriverAccountQuestion => 'Pause Driver Account?';

  @override
  String get pauseDriverAccountMessage =>
      'You will stop receiving ride requests until you resume. Your profile and reviews will remain visible.';

  @override
  String get driverAccountPaused => 'Driver account paused';

  @override
  String get pauseAccountAction => 'Pause Account';

  @override
  String get syncProfile => 'Sync Profile';

  @override
  String get eventUnableToLoadOriginal => 'Unable to load the original event.';

  @override
  String get eventUnableToUpdate => 'Unable to update event. Please try again.';

  @override
  String get eventSignInRequired => 'Please sign in to continue.';

  @override
  String get supportCategoryOther => 'Other';

  @override
  String get averageResponseTime => 'Average response time';

  @override
  String get backToSettings => 'Back to Settings';

  @override
  String get couldNotClearChatTryAgain =>
      'Could not clear chat. Please try again.';

  @override
  String get sendEmoji => 'Send Emoji';

  @override
  String get sendPhoto => 'Send Photo';

  @override
  String get moreOptions => 'More options';

  @override
  String get clearReply => 'Clear reply';

  @override
  String messageFromLongPressOptions(String name) {
    return 'Message from $name. Long press for options';
  }

  @override
  String get attachFile => 'Attach file';

  @override
  String get showKeyboard => 'Show keyboard';

  @override
  String get showEmojiPicker => 'Show emoji picker';

  @override
  String get sendMessage => 'Send message';

  @override
  String get rejected => 'Rejected';

  @override
  String pleaseEnterValue(String value) {
    return 'Please enter $value';
  }

  @override
  String get uploadVehiclePhotoPermission =>
      'Access to your photo library is needed to upload a photo of your vehicle.';

  @override
  String get driverVehicleStepSubtitle =>
      'Tell us about your car so riders know what to expect.';

  @override
  String get vehicleMakeHint => 'e.g., Toyota, Honda, BMW';

  @override
  String get pleaseEnterVehicleMake => 'Please enter vehicle make';

  @override
  String get vehicleModelHint => 'e.g., Corolla, Civic, 3 Series';

  @override
  String get pleaseEnterVehicleModel => 'Please enter vehicle model';

  @override
  String get vehicleYearHint => 'e.g., 2020';

  @override
  String get requiredField => 'Required';

  @override
  String get vehicleColorHint => 'e.g., White';

  @override
  String get licensePlateHint => 'e.g., ABC 123';

  @override
  String get licensePlateHelperText => '2-12 characters, letters & numbers';

  @override
  String get pleaseEnterLicensePlate => 'Please enter license plate';

  @override
  String get pleaseEnterNumberOfSeats => 'Please enter number of seats';

  @override
  String get mustBeWholeNumber => 'Must be a whole number';

  @override
  String get enter1To8Seats => 'Enter 1-8 seats';

  @override
  String get driverStripeStepSubtitle =>
      'Connect your bank account to receive payments from your rides.';

  @override
  String get stripePoweredByMillions =>
      'Powered by Stripe, trusted by millions';

  @override
  String get stripeFastTransfersDesc => 'Get paid within 2-3 business days';

  @override
  String get stripeEarningsDesc => 'View all your earnings in one place';

  @override
  String get connectWithStripe => 'Connect with Stripe';

  @override
  String get legalConsentPrefix => 'By continuing, you agree to our ';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get andConnector => ' and ';

  @override
  String get termsLinkSemantics => 'Terms of Service, link';

  @override
  String get privacyLinkSemantics => 'Privacy Policy, link';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get stats => 'Stats';

  @override
  String get searchHelpArticles => 'Search help articles...';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get closeRouteInfo => 'Close route info';

  @override
  String get requestDataExport => 'Request Data Export';

  @override
  String get withdrawConsent => 'Withdraw Consent';

  @override
  String get downloadMyData => 'Download My Data';

  @override
  String get downloadMyDataDescription =>
      'We will prepare a copy of your personal data including your profile, ride history, and reviews. You will receive an email with a download link within 48 hours.';

  @override
  String get dataProcessingNotice => 'Data Processing Notice';

  @override
  String get withdrawConsentDescription =>
      'You can withdraw your consent for data processing in the following ways:';

  @override
  String get dataExportRequestSubmitted => 'Data export request submitted.';

  @override
  String get deleteKeyword => 'DELETE';

  @override
  String get submitReviewButton => 'Submit Review';

  @override
  String get pleaseSelectRatingToSubmit => 'Please select a rating to submit';

  @override
  String get unknownDriver => 'Unknown Driver';

  @override
  String get errorLoadingDriver => 'Error loading driver';

  @override
  String get passengerNotFound => 'Passenger not found';

  @override
  String get errorLoadingPassenger => 'Error loading passenger';

  @override
  String get unknown => 'Unknown';

  @override
  String get noPhone => 'No phone';

  @override
  String get notAvailableShort => 'N/A';

  @override
  String get permissionLocationAccessTitle => 'Location Access';

  @override
  String get permissionLocationAccessMessage =>
      'SportConnect needs your location to show nearby rides, calculate distances, and provide accurate navigation during your trips.';

  @override
  String get permissionShareLocationTitle => 'Share Your Location';

  @override
  String get permissionShareLocationMessage =>
      'Your current location will be shared with this chat so other participants can see where you are. Your location is only shared when you choose to send it.';

  @override
  String get permissionRideNavigationTitle => 'Location Access Required';

  @override
  String get permissionRideNavigationMessage =>
      'SportConnect uses your location while you use the app to show live trip progress, detect pickup and drop-off arrival, and help coordinate rides. It is not used for background tracking.';

  @override
  String get permissionCameraPhotosTitle => 'Camera & Photos';

  @override
  String get permissionCameraPhotosMessage =>
      'Access to your camera and photo library is needed to attach images. Your photos are only uploaded when you explicitly choose to share them.';

  @override
  String get permissionStayUpdatedTitle => 'Stay Updated';

  @override
  String get permissionStayUpdatedMessage =>
      'Enable notifications to receive ride updates, messages from other riders, booking confirmations, and important safety alerts.';

  @override
  String get notNow => 'Not Now';

  @override
  String get actionContinue => 'Continue';

  @override
  String get rideOptions => 'Ride options';

  @override
  String get messagePassenger => 'Message passenger';

  @override
  String get passengerOptions => 'Passenger options';

  @override
  String get markNoShow => 'Mark no-show';

  @override
  String get messageDriver => 'Message driver';

  @override
  String get chatWithDriver => 'Chat with driver';

  @override
  String get chatWithPassenger => 'Chat with passenger';

  @override
  String get callDriver => 'Call driver';

  @override
  String get closePassengerDetails => 'Close passenger details';

  @override
  String get rideRequestDetails => 'Ride request details';

  @override
  String get directions => 'Directions';

  @override
  String driverArrivingIn(int minutes) {
    return 'Driver arriving in ~$minutes min';
  }

  @override
  String estimatedWait(int minutes) {
    return 'Est. wait: ~$minutes min';
  }

  @override
  String get customPickupPoint => 'Custom pickup point';

  @override
  String get dropPinForPickup => 'Drop a pin for pickup';

  @override
  String get clearPin => 'Clear pin';

  @override
  String get setPin => 'Set Pin';

  @override
  String markNoShowPrompt(String name) {
    return 'Mark $name as a no-show? This will be recorded and may affect their rating.';
  }

  @override
  String get switchVehicle => 'Switch vehicle';

  @override
  String get copyLink => 'Copy link';

  @override
  String get cloneThisRide => 'Clone This Ride';

  @override
  String get howWasYourRide => 'How was your ride?';

  @override
  String rateYourExperienceWith(String name) {
    return 'Rate your experience with $name';
  }

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get reportIncident => 'Report incident';

  @override
  String get incidentType => 'Type of incident';

  @override
  String get describeWhatHappened => 'Describe what happened...';

  @override
  String get submitReport => 'Submit Report';

  @override
  String amountPaid(String amount) {
    return 'Amount paid: $amount';
  }

  @override
  String get reasonForRefund => 'Reason for refund';

  @override
  String get additionalDetailsOptional => 'Additional details (optional)';

  @override
  String get submitRefundRequest => 'Submit Refund Request';

  @override
  String get rideSummary => 'Ride summary';

  @override
  String get expandedView => 'Expanded view';

  @override
  String get compactView => 'Compact view';

  @override
  String get pickOnMap => 'Pick on map';

  @override
  String get searchCountryOrCode => 'Search country or code...';

  @override
  String get severity => 'Severity';

  @override
  String get safetyCheckInConfirmed => 'Safety check-in confirmed!';

  @override
  String get markAsNoShowQuestion => 'Mark as No-Show?';

  @override
  String markNoShowDialogMessage(String passengerId) {
    return 'This will cancel $passengerId\'s booking and notify them. You will have 30 seconds to undo.';
  }

  @override
  String get passengerMarkedNoShow => 'Passenger marked as no-show';

  @override
  String get undo => 'UNDO';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get requestedStop => 'Requested stop';

  @override
  String get createReturnRideQuestion => 'Create Return Ride?';

  @override
  String createReturnRideMessage(String destination, String origin) {
    return 'Would you like to create a return ride from $destination back to $origin?';
  }

  @override
  String get noThanks => 'No, thanks';

  @override
  String get returnRideCreated => 'Return ride created!';

  @override
  String get createReturnRide => 'Create Return Ride';

  @override
  String get confirmDeparture => 'Confirm Departure';

  @override
  String get allPassengersPickedUpConfirm =>
      'All passengers picked up? You will begin driving to the destination.';

  @override
  String get departNow => 'Depart Now';

  @override
  String get passengerProfileNotFound => 'Passenger profile not found';

  @override
  String get failedToOpenChatTryAgain =>
      'Failed to open chat. Please try again.';

  @override
  String get emergencySos => 'Emergency SOS';

  @override
  String get sosShareConfirmationMessage =>
      'This will share your ride details and current location with your contacts. Continue?';

  @override
  String get shareSos => 'Share SOS';

  @override
  String get requestAStop => 'Request a Stop';

  @override
  String get requestStopDescription =>
      'Describe where you\'d like the driver to stop. The driver can accept or decline.';

  @override
  String get requestStopHint => 'e.g. Gas station, pharmacy...';

  @override
  String get stopRequestSentToDriver => 'Stop request sent to driver';

  @override
  String get requestStop => 'Request Stop';

  @override
  String get sos => 'SOS';

  @override
  String get bookingNotFoundTryAgain => 'Booking not found. Please try again.';

  @override
  String get noShowReported => 'No-show reported';

  @override
  String get incidentReportSubmitted => 'Incident report submitted';

  @override
  String get ratingSubmittedThankYou => 'Rating submitted - thank you!';

  @override
  String get ratePassenger => 'Rate Passenger';

  @override
  String get ratePassengerCommentHint =>
      'What made this passenger great (or not)?';

  @override
  String failedToSubmitValue(String value) {
    return 'Failed to submit: $value';
  }

  @override
  String sentMessage(String message) {
    return 'Sent: $message';
  }

  @override
  String get acceptStop => 'Accept Stop';

  @override
  String get dismiss => 'Dismiss';

  @override
  String failedToLoadBookingValue(String value) {
    return 'Failed to load booking: $value';
  }

  @override
  String get bookingNotFoundMayBeCancelled =>
      'Booking not found. It may have been cancelled.';

  @override
  String get rideHasBeenCancelled => 'This ride has been cancelled.';

  @override
  String bookingRefCopied(String code) {
    return 'Booking ref $code copied!';
  }

  @override
  String get bookingFailedTryAgain => 'Booking failed. Please try again.';

  @override
  String get addedToCalendar => 'Added to calendar';

  @override
  String get dismissSuccess => 'Dismiss success';

  @override
  String get dismissError => 'Dismiss error';

  @override
  String get bookingConfirmedTitle => 'Booking Confirmed!';

  @override
  String get great => 'Great!';

  @override
  String lastCheckedInMinutesAgo(int minutes) {
    return 'Last checked in $minutes min ago';
  }

  @override
  String get letContactsKnowSafe => 'Let your contacts know you\'re safe';

  @override
  String get imOk => 'I\'m OK';

  @override
  String get incidentTypeUnsafeDriving => 'Unsafe Driving';

  @override
  String get incidentTypeHarassment => 'Harassment';

  @override
  String get incidentTypeRouteDeviation => 'Route Deviation';

  @override
  String get incidentTypeVehicleIssue => 'Vehicle Issue';

  @override
  String get incidentTypeNoShow => 'No-Show';

  @override
  String get incidentTypeOther => 'Other';

  @override
  String get refundReasonDriverNoShow => 'Driver did not show up';

  @override
  String get refundReasonRideNotAsDescribed => 'Ride was not as described';

  @override
  String get refundReasonUnsafeExperience => 'Felt unsafe during ride';

  @override
  String get refundReasonOvercharged => 'Was overcharged';

  @override
  String get refundReasonCancelledByDriver => 'Driver cancelled last minute';

  @override
  String get refundReasonOther => 'Other reason';

  @override
  String get origin => 'Origin';

  @override
  String get estimatedArrival => 'Est. Arrival';

  @override
  String get partlyCloudy => 'Partly Cloudy';

  @override
  String get rideShareSubject => 'Carpool ride on SportConnect';

  @override
  String rideShareText(
    String from,
    String to,
    String departure,
    String price,
    int seats,
    String link,
  ) {
    return '🚗 Check out this ride on SportConnect!\n\n📍 $from → $to\n📅 $departure\n💰 $price € per seat\n🪑 $seats seats available\n\nJoin me for a comfortable ride! 🌱\n\n🔗 $link';
  }

  @override
  String get tripShareSubject => 'Trip on SportConnect';

  @override
  String tripShareMessage(
    String userName,
    String status,
    String origin,
    String destination,
    String rideId,
    String departure,
  ) {
    return '$userName is $status with SportConnect.\n\nFrom: $origin\nTo: $destination\nRide ID: $rideId\n\nDeparture: $departure';
  }

  @override
  String get tripStatusInProgress => 'currently on a ride';

  @override
  String get tripStatusScheduled => 'about to ride';

  @override
  String get rideCompatibility => 'Ride Compatibility';

  @override
  String get greatMatch => 'Great match';

  @override
  String get goodMatch => 'Good match';

  @override
  String get fairMatch => 'Fair match';

  @override
  String get nonSmoking => 'Non-smoking';

  @override
  String get directRoute => 'Direct route';

  @override
  String get spacious => 'Spacious';

  @override
  String get viewActiveRide => 'View Active Ride';

  @override
  String get setPickupLocation => 'Set pickup location';

  @override
  String get optionalSetYourPickupPoint => 'Optional - set your pickup point';

  @override
  String get eventLabel => 'Event';

  @override
  String get aPassenger => 'A passenger';

  @override
  String get rateAndReview => 'Rate & Review';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get bookThisRouteAgain => 'Book This Route Again';

  @override
  String get waitingForDriverApproval => 'Waiting for driver approval';

  @override
  String get eta => 'ETA';

  @override
  String get speed => 'Speed';

  @override
  String get addAsStop => 'Add as Stop';

  @override
  String get signInToSeeYourRides => 'Sign in to see your rides';

  @override
  String get logIn => 'Log In';

  @override
  String get accepted => 'Accepted';

  @override
  String get declined => 'Declined';

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get unableToLoadRidesTryAgain =>
      'Unable to load rides. Please try again.';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get tryAdjustingFiltersOrDifferentDate =>
      'Try adjusting your filters or search for a different date';

  @override
  String get bestMatchForYourSearch => 'Best match for your search';

  @override
  String get showCheapestRidesFirst => 'Show cheapest rides first';

  @override
  String get showRidesLeavingSoonest => 'Show rides leaving soonest';

  @override
  String get showBestRatedDriversFirst => 'Show best-rated drivers first';

  @override
  String get showFastestRoutesFirst => 'Show fastest routes first';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String eventShareText(
    String title,
    String eventType,
    String date,
    String address,
    String link,
  ) {
    return '$title — $eventType\n$date\n$address\n\nJoin me on SportConnect!\n$link';
  }

  @override
  String get receiptTitle => 'SportConnect - Trip Receipt';

  @override
  String get receiptBaseFare => 'Base Fare';

  @override
  String get receiptServiceFee => 'Service Fee';

  @override
  String get receiptRideId => 'Ride ID';

  @override
  String get something_went_wrong => 'Something went wrong';

  @override
  String get your_action_was_completed_successfully =>
      'Your action was completed successfully.';

  @override
  String get success => 'success';

  @override
  String get localhost => 'localhost';

  @override
  String get production_mode => 'PRODUCTION MODE';

  @override
  String get none => 'none';

  @override
  String get signedout => 'signed-out';

  @override
  String
  get pk_test_51t0hg4ryc7z72fdkkzbcqr4p1v0mi8nzgsxotoy7stj8a3qfqkdlbofdng5fggsinfcvilbokjbtupskomgywirk00mnaqcfsq =>
      'pk_test_51T0hg4RYC7Z72fDKkzbCQr4P1v0Mi8nzgSXoToY7Stj8A3QfqKdLBOFDNG5fggSinfCVILBOkjBTupskomgywiRk00MnaqCFSq';

  @override
  String get passengerreview => 'passengerReview';

  @override
  String get stripe_not_configured_update_stripeconfig_values =>
      'Stripe NOT configured - update StripeConfig values';

  @override
  String get eur => 'EUR';

  @override
  String get pk_test_your_publishable_key_here =>
      'pk_test_YOUR_PUBLISHABLE_KEY_HERE';

  @override
  String get fr => 'FR';

  @override
  String get tnfr => 'tn,fr';

  @override
  String get users => 'users';

  @override
  String get chats => 'Chats';

  @override
  String get notifications => 'Notifications';

  @override
  String get payments => 'Payments';

  @override
  String get reports => 'reports';

  @override
  String get bookings => 'bookings';

  @override
  String get support_tickets => 'support_tickets';

  @override
  String get driver_connected_accounts => 'driver_connected_accounts';

  @override
  String get driver_stats => 'driver_stats';

  @override
  String get blockedusers => 'blockedUsers';

  @override
  String get disputes => 'disputes';

  @override
  String get archived_transactions => 'archived_transactions';

  @override
  String get profile_images => 'profile_images';

  @override
  String get chat_images => 'chat_images';

  @override
  String get vehicle_images => 'vehicle_images';

  @override
  String get sportaxitripcom => 'sportaxitrip.com';

  @override
  String get sportconnect10_contactsportconnectapp =>
      'SportConnect/1.0 (contact@sportconnect.app)';

  @override
  String get find_and_book_rides_to_sporting_events =>
      'Find and book rides to sporting events';

  @override
  String get offer_rides_and_earn_money => 'Offer rides and earn money';

  @override
  String get your_application_is_under_review =>
      'Your application is under review';

  @override
  String get language_code => 'language_code';

  @override
  String get notifications_enabled => 'notifications_enabled';

  @override
  String get ride_reminders => 'ride_reminders';

  @override
  String get chat_notifications => 'chat_notifications';

  @override
  String get marketing_emails => 'marketing_emails';

  @override
  String get show_location => 'show_location';

  @override
  String get public_profile => 'public_profile';

  @override
  String get map_style => 'Map Style';

  @override
  String get notification_dialog_shown => 'notification_dialog_shown';

  @override
  String get analytics_enabled => 'analytics_enabled';

  @override
  String get premium_prompt_seen_ => 'premium_prompt_seen_';

  @override
  String get driver_show_on_map => 'driver_show_on_map';

  @override
  String get driver_allow_instant_booking => 'driver_allow_instant_booking';

  @override
  String get driver_max_distance => 'driver_max_distance';

  @override
  String get driver_navigation_app => 'driver_navigation_app';

  @override
  String get sc => 'SC';

  @override
  String get https => 'https';

  @override
  String get nominatimopenstreetmaporg => 'nominatim.openstreetmap.org';

  @override
  String get node => 'node[';

  @override
  String get sports_centre => 'sports_centre';

  @override
  String get stadium => 'stadium';

  @override
  String get pitch => 'pitch';

  @override
  String get university => 'university';

  @override
  String get college => 'college';

  @override
  String get parking => 'Parking';

  @override
  String get fuel => 'fuel';

  @override
  String get restaurant => 'restaurant';

  @override
  String get cafe => 'cafe';

  @override
  String get hospital => 'hospital';

  @override
  String get clinic => 'clinic';

  @override
  String get bus_stop => 'bus_stop';

  @override
  String get station => 'station';

  @override
  String get tram_stop => 'tram_stop';

  @override
  String get trip_receipt => 'TRIP RECEIPT';

  @override
  String get thank_you_for_using_sportconnect =>
      'Thank you for using SportConnect!';

  @override
  String get your_ecofriendly_carpooling_choice =>
      'Your eco-friendly carpooling choice';

  @override
  String get earnings_report => 'EARNINGS REPORT';

  @override
  String get trip_history => 'Trip History';

  @override
  String get sport_connect_messages => 'sport_connect_messages';

  @override
  String get new_chat_message_notifications => 'New chat message notifications';

  @override
  String get sport_connect_rides => 'sport_connect_rides';

  @override
  String get ride_booking_and_status_notifications =>
      'Ride booking and status notifications';

  @override
  String get sport_connect_general => 'sport_connect_general';

  @override
  String get general => 'General';

  @override
  String get general_app_notifications => 'General app notifications';

  @override
  String get arrive_at_destination => 'Arrive at destination';

  @override
  String get take_the_ramp => 'Take the ramp';

  @override
  String get take_the_exit => 'Take the exit';

  @override
  String get driving => 'driving';

  @override
  String get geojson => 'geojson';

  @override
  String get full => 'Full';

  @override
  String get ok => 'Ok';

  @override
  String get polyline => 'polyline';

  @override
  String get polyline6 => 'polyline6';

  @override
  String get start_on => 'Start on';

  @override
  String get inter => 'Inter';

  @override
  String get name_is_required => 'Name is required';

  @override
  String get name_must_be_at_least_2_characters =>
      'Name must be at least 2 characters';

  @override
  String get name_is_too_long => 'Name is too long';

  @override
  String get name_cannot_contain_numbers => 'Name cannot contain numbers';

  @override
  String get name_contains_invalid_characters =>
      'Name contains invalid characters';

  @override
  String get email_is_required => 'Email is required';

  @override
  String get please_enter_a_valid_email_address =>
      'Please enter a valid email address';

  @override
  String get phone_number_is_too_short => 'Phone number is too short';

  @override
  String get phone_number_is_too_long => 'Phone number is too long';

  @override
  String get phone_number_is_required => 'Phone number is required';

  @override
  String get password_is_required => 'Password is required';

  @override
  String get password_must_be_at_least_8_characters =>
      'Password must be at least 8 characters';

  @override
  String get include_at_least_one_uppercase_letter =>
      'Include at least one uppercase letter';

  @override
  String get include_at_least_one_lowercase_letter =>
      'Include at least one lowercase letter';

  @override
  String get include_at_least_one_number => 'Include at least one number';

  @override
  String get please_confirm_your_password => 'Please confirm your password';

  @override
  String get passwords_do_not_match => 'Passwords do not match';

  @override
  String get price_is_required => 'Price is required';

  @override
  String get please_enter_a_valid_price => 'Please enter a valid price';

  @override
  String get price_must_be_greater_than_0 => 'Price must be greater than 0';

  @override
  String get price_seems_too_high => 'Price seems too high';

  @override
  String get please_select_number_of_seats => 'Please select number of seats';

  @override
  String get date_is_required => 'Date is required';

  @override
  String get date_must_be_in_the_future => 'Date must be in the future';

  @override
  String get date_of_birth_is_required => 'Date of birth is required';

  @override
  String get license_plate_is_required => 'License plate is required';

  @override
  String get license_plate_is_too_short => 'License plate is too short';

  @override
  String get license_plate_is_too_long => 'License plate is too long';

  @override
  String get invalid_license_plate_format => 'Invalid license plate format';

  @override
  String get year_is_required => 'Year is required';

  @override
  String get please_enter_a_valid_year => 'Please enter a valid year';

  @override
  String get vehicle_is_too_old => 'Vehicle is too old';

  @override
  String get invalid_year => 'Invalid year';

  @override
  String get city_name_is_too_short => 'City name is too short';

  @override
  String get city_name_is_too_long => 'City name is too long';

  @override
  String get city_name_cannot_contain_numbers =>
      'City name cannot contain numbers';

  @override
  String get this_field => 'This field';

  @override
  String get please_sign_in_to_continue => 'Please sign in to continue.';

  @override
  String get this_payment_or_payout_could_not_be_found =>
      'This payment or payout could not be found.';

  @override
  String get this_request_was_already_processed =>
      'This request was already processed.';

  @override
  String get too_many_requests_please_wait_a_moment_and_try_again =>
      'Too many requests — please wait a moment and try again.';

  @override
  String get the_request_timed_out_please_check_your_connection_and_try_again =>
      'The request timed out. Please check your connection and try again.';

  @override
  String get service_temporarily_unavailable_please_try_again =>
      'Service temporarily unavailable. Please try again.';

  @override
  String get security_check_failed_please_refresh_and_try_again =>
      'Security check failed. Please refresh and try again.';

  @override
  String get you_don => 'You don';

  @override
  String
  get insufficient_balance_ride_earnings_may_still_be_settling_try_again_in_a_few_hours =>
      'Insufficient balance. Ride earnings may still be settling — try again in a few hours.';

  @override
  String get no_bank_account_linked_please_complete_your_stripe_setup_first =>
      'No bank account linked. Please complete your Stripe setup first.';

  @override
  String
  get payouts_not_yet_enabled_on_your_account_please_complete_verification =>
      'Payouts not yet enabled on your account. Please complete verification.';

  @override
  String get your_stripe_account_isn => 'Your Stripe account isn';

  @override
  String get tap => 'Tap ';

  @override
  String get your_card_was_declined_please_try_a_different_payment_method =>
      'Your card was declined. Please try a different payment method.';

  @override
  String get payment_declined_insufficient_funds_on_your_card =>
      'Payment declined — insufficient funds on your card.';

  @override
  String get your_card_has_expired_please_update_your_payment_method =>
      'Your card has expired. Please update your payment method.';

  @override
  String get incorrect_card_security_code_please_check_and_try_again =>
      'Incorrect card security code. Please check and try again.';

  @override
  String get this_payout_can_no_longer_be_cancelled_it =>
      'This payout can no longer be cancelled — it';

  @override
  String get payout_failed_please_check_your_bank_details_are_correct =>
      'Payout failed. Please check your bank details are correct.';

  @override
  String
  get refund_could_not_be_processed_please_contact_support_if_this_persists =>
      'Refund could not be processed. Please contact support if this persists.';

  @override
  String get this_booking_has_already_been_paid =>
      'This booking has already been paid.';

  @override
  String get this_ride_is_no_longer_available_for_booking =>
      'This ride is no longer available for booking.';

  @override
  String get no_active_booking_found_for_this_ride =>
      'No active booking found for this ride.';

  @override
  String get the_driver_hasn => 'The driver hasn';

  @override
  String get connection_error_please_check_your_internet_and_try_again =>
      'Connection error. Please check your internet and try again.';

  @override
  String get request_timed_out_please_try_again =>
      'Request timed out. Please try again.';

  @override
  String get something_went_wrong_please_try_again =>
      'Something went wrong. Please try again.';

  @override
  String get fastest_way_to_set_your_pickup_point =>
      'Fastest way to set your pickup point';

  @override
  String get expand_map_for_exact_pickup_point =>
      'Expand map for exact pickup point';

  @override
  String get tap_the_map_to_set_the_exact_point =>
      'Tap the map to set the exact point';

  @override
  String get finding_address => 'Finding address...';

  @override
  String get suggestions => 'SUGGESTIONS';

  @override
  String get selected_address => 'Selected address';

  @override
  String get use_this_address => 'Use this address';

  @override
  String get selected => 'Selected';

  @override
  String get search_unavailable => 'Search unavailable';

  @override
  String get no_address_found => 'No address found';

  @override
  String get try_another_street_or_choose_the_exact_point_on_map =>
      'Try another street or choose the exact point on map.';

  @override
  String get unable_to_search_addresses_try_again =>
      'Unable to search addresses. Try again.';

  @override
  String get unable_to_read_a_valid_current_location =>
      'Unable to read a valid current location.';

  @override
  String get your_current_location_appears_to_be_outside_france =>
      'Your current location appears to be outside France.';

  @override
  String get invalid_address_location_please_choose_another_result =>
      'Invalid address location. Please choose another result.';

  @override
  String get invalid_map_position_please_choose_another_point =>
      'Invalid map position. Please choose another point.';

  @override
  String get please_select_a_location_in_france =>
      'Please select a location in France.';

  @override
  String get selected_location => 'Selected location';

  @override
  String get please_select_an_address => 'Please select an address.';

  @override
  String get invalid_selected_location_please_choose_another_point =>
      'Invalid selected location. Please choose another point.';

  @override
  String get payment_receipt => 'Payment Receipt';

  @override
  String get thank_you_for_riding_with_sportconnect =>
      'Thank you for riding with SportConnect!';

  @override
  String get refund_amount => 'Refund amount';

  @override
  String get days => 'days';

  @override
  String get could_not_submit_refund_please_try_again =>
      'Could not submit refund. Please try again.';

  @override
  String get no_rides_found => 'No rides found';

  @override
  String get try_adjusting_your_filters_or_search_for_a_different_route =>
      'Try adjusting your filters or search for a different route';

  @override
  String get no_events_yet => 'No events yet';

  @override
  String get create_an_event_to_bring_your_group_together =>
      'Create an event to bring your group together';

  @override
  String get no_messages_yet => 'No messages yet';

  @override
  String get start_a_conversation_by_booking_a_ride_or_joining_an_event =>
      'Start a conversation by booking a ride or joining an event';

  @override
  String get all_caught_up => 'All caught up!';

  @override
  String get no_reviews_yet => 'No reviews yet';

  @override
  String get reviews_will_appear_after_completed_rides =>
      'Reviews will appear after completed rides';

  @override
  String get no_vehicles_added => 'No vehicles added';

  @override
  String get add_a_vehicle_to_start_offering_rides =>
      'Add a vehicle to start offering rides';

  @override
  String get no_bookings_yet => 'No bookings yet';

  @override
  String get your_ride_bookings_will_appear_here =>
      'Your ride bookings will appear here';

  @override
  String get no_results_found => 'No results found';

  @override
  String get try_different_search_terms_or_filters =>
      'Try different search terms or filters';

  @override
  String get please_try_again => 'Please try again';

  @override
  String get select_your_expertise_level => 'Select your expertise level';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get enter_a_valid_french_phone_number =>
      'Enter a valid French phone number.';

  @override
  String get after_33_enter_the_number_without_the_leading_0 =>
      'After +33, enter the number without the leading 0.';

  @override
  String get used_only_for_ride_coordination_and_safety =>
      'Used only for ride coordination and safety.';

  @override
  String get no_map_apps_are_available_on_this_device =>
      'No map apps are available on this device.';

  @override
  String get unable_to_open_maps_right_now => 'Unable to open maps right now.';

  @override
  String get select_location => 'Select Location';

  @override
  String get france => 'France';

  @override
  String get departure_reminder => 'Departure reminder';

  @override
  String get search_rides_people_places => 'Search rides, people, places...';

  @override
  String get explore_nearby_stops => 'Explore nearby stops';

  @override
  String get gas_stations => 'Gas Stations';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get sports => 'Sports';

  @override
  String get universities => 'Universities';

  @override
  String get hospitals => 'Hospitals';

  @override
  String get transport => 'Transport';

  @override
  String get cafs => 'Cafés';

  @override
  String get search => 'Search...';

  @override
  String get switch_vehicle => 'Switch Vehicle';

  @override
  String get ladies_only => 'Ladies Only';

  @override
  String get tap_to_apply => 'Tap to apply';

  @override
  String get ride_progress => 'Ride Progress';

  @override
  String get ride_confirmed => 'Ride confirmed';

  @override
  String get on_the_way_to_pickup => 'On the way to pickup';

  @override
  String get almost_at_pickup_point => 'Almost at pickup point';

  @override
  String get en_route_to_destination => 'En route to destination';

  @override
  String get booked => 'Booked';

  @override
  String get driver_left => 'Driver Left';

  @override
  String get arriving => 'Arriving';

  @override
  String get riding => 'Riding';

  @override
  String get arrived => 'Arrived';

  @override
  String get driver_history => 'Driver History';

  @override
  String get please_reauthenticate_before_deleting_your_account =>
      'Please re-authenticate before deleting your account';

  @override
  String get your_account_has_been_suspended_please_contact_support =>
      'Your account has been suspended. Please contact support.';

  @override
  String get signin_was_cancelled => 'Sign-in was cancelled.';

  @override
  String get no_user_found_with_this_email => 'No user found with this email';

  @override
  String get wrong_password => 'Wrong password';

  @override
  String get invalid_email_or_password => 'Invalid email or password';

  @override
  String get email_already_in_use => 'Email already in use';

  @override
  String get invalid_email_address => 'Invalid email address';

  @override
  String get password_is_too_weak => 'Password is too weak';

  @override
  String get too_many_attempts_please_try_again_later =>
      'Too many attempts. Please try again later';

  @override
  String get please_reauthenticate_to_continue =>
      'Please re-authenticate to continue';

  @override
  String get an_account_already_exists_with_a_different_signin_method =>
      'An account already exists with a different sign-in method. ';

  @override
  String get the_selected_google_account_does_not_match_your_account_email =>
      'The selected Google account does not match your account email. ';

  @override
  String get requiresrecentlogin => 'requires-recent-login';

  @override
  String get user => 'User';

  @override
  String get weakpassword => 'weak-password';

  @override
  String get you_must_accept_the_terms_to_continue =>
      'You must accept the terms to continue.';

  @override
  String get from_your_signin_account => 'From your sign-in account';

  @override
  String get help_riders_recognize_your_car_at_pickup =>
      'Help riders recognize your car at pickup.';

  @override
  String get other_color => 'Other color';

  @override
  String get i_agree_to_the => 'I agree to the ';

  @override
  String get terms_conditions => 'Terms & Conditions';

  @override
  String get recognition_details_appear_here =>
      'Recognition details appear here';

  @override
  String get what_car_should_riders_look_for =>
      'What car should riders look for?';

  @override
  String get keep_this_simple_make_and_model_are_enough_here =>
      'Keep this simple. Make and model are enough here.';

  @override
  String get help_passengers_find_you => 'Help passengers find you';

  @override
  String get color_and_plate_are_the_details_riders_use_at_pickup =>
      'Color and plate are the details riders use at pickup.';

  @override
  String get how_many_passengers_can_you_take =>
      'How many passengers can you take?';

  @override
  String get this_is_available_passenger_seats_not_total_car_seats =>
      'This is available passenger seats, not total car seats.';

  @override
  String get vehicle_details => 'Vehicle details';

  @override
  String get kept_quieter_because_they_are_less_important_at_pickup =>
      'Kept quieter because they are less important at pickup.';

  @override
  String get black => 'Black';

  @override
  String get white => 'White';

  @override
  String get grey => 'Grey';

  @override
  String get silver => 'Silver';

  @override
  String get blue => 'Blue';

  @override
  String get red => 'Red';

  @override
  String get green => 'Green';

  @override
  String get beige_brown => 'Beige / Brown';

  @override
  String get address => 'Address';

  @override
  String get save_driver_profile_and_continue =>
      'Save driver profile and continue';

  @override
  String get champagne_pearl_white_bordeaux =>
      'Champagne, pearl white, bordeaux...';

  @override
  String get invalid_value => 'Invalid value';

  @override
  String get address_is_required => 'Address is required';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get contactAndAddress => 'Contact & Address';

  @override
  String get drivingDetails => 'Driving Details';

  @override
  String get carIdentity => 'Car identity';

  @override
  String get recognition => 'Recognition';

  @override
  String get passengerSeats => 'Passenger seats';

  @override
  String get moreDetails => 'More details';

  @override
  String get whyConnectPayouts => 'Why connect payouts?';

  @override
  String get yourName => 'Your Name';

  @override
  String get registrationYear => 'Registration year';

  @override
  String get onlyUsedWhenNeededForPickupVerification =>
      'Only used when needed for pickup verification.';

  @override
  String get addColorAndPlateSoRidersCanFindYou =>
      'Add color and plate so riders can find you';

  @override
  String get chooseACommonColorOrUseOtherColor =>
      'Choose a common color or use Other color.';

  @override
  String selectedColor(String color) {
    return 'Selected color: $color';
  }

  @override
  String get customColorWillBeShownToRidersAsWritten =>
      'Custom color will be shown to riders as written.';

  @override
  String get chooseSeatsAvailableForPassengers =>
      'Choose seats available for passengers.';

  @override
  String get optionalDetailUsedForRideContext =>
      'Optional detail used for ride context.';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get maximumSeats => 'Maximum seats';

  @override
  String get colorDescriptionIsTooLong => 'Color description is too long';

  @override
  String get useAClearColorNameLikeGreyBlueOrPearlWhite =>
      'Use a clear color name, like grey, blue, or pearl white.';

  @override
  String suggestedPriceValue(String price) {
    return 'Suggested: €$price';
  }

  @override
  String get name => 'name';

  @override
  String get dob => 'dob';

  @override
  String get expertise => 'expertise';

  @override
  String get terms => 'terms';

  @override
  String get license_plate => 'license_plate';

  @override
  String get fuel_type => 'fuel_type';

  @override
  String get sign_up => 'Sign up';

  @override
  String get sportconnect_logo => 'SportConnect logo';

  @override
  String get signing_in_please_wait => 'Signing in, please wait';

  @override
  String get discard_changes => 'Discard changes?';

  @override
  String get your_profile_info_will_not_be_saved_if_you_go_back =>
      'Your profile info will not be saved if you go back.';

  @override
  String get keep_editing => 'Keep editing';

  @override
  String get complete_your_profile => 'Complete your profile';

  @override
  String get step_2_of_2 => 'Step 2 of 2';

  @override
  String get rider_onboarding_form => 'Rider onboarding form';

  @override
  String get complete_rider_onboarding => 'Complete rider onboarding';

  @override
  String get profile_not_loaded_yet_please_wait_a_moment =>
      '⚠️ Profile not loaded yet. Please wait a moment.';

  @override
  String get please_enter_a_valid_phone_number =>
      'Please enter a valid phone number.';

  @override
  String get please_enter_your_address => 'Please enter your address.';

  @override
  String get profile_complete_welcome_aboard =>
      '🎉 Profile complete! Welcome aboard.';

  @override
  String get your_saved_info_has_been_prefilled =>
      'Your saved info has been pre-filled.';

  @override
  String get failed_to_load_your_profile_some_fields_may_be_empty =>
      'Failed to load your profile. Some fields may be empty.';

  @override
  String get verification_requirements => 'Verification Requirements';

  @override
  String get almost_there => 'Almost there! 📍';

  @override
  String get skip_for_now => 'Skip for now';

  @override
  String get confirm_date => 'Confirm Date';

  @override
  String get account_setup => 'Account Setup';

  @override
  String get identity => 'Identity';

  @override
  String get profile => 'Profile';

  @override
  String get or_continue_with_email => 'Or continue with email';

  @override
  String get agree_to_terms_of_service_and_privacy_policy =>
      'Agree to Terms of Service and Privacy Policy';

  @override
  String get googlesignincanceled => 'google-sign-in-canceled';

  @override
  String get accountexistswithdifferentcredential =>
      'account-exists-with-different-credential';

  @override
  String get wrongpassword => 'wrong-password';

  @override
  String get every_day => 'Every day';

  @override
  String get every_week => 'Every week';

  @override
  String get every_2_weeks => 'Every 2 weeks';

  @override
  String get every_month => 'Every month';

  @override
  String get every_year => 'Every year';

  @override
  String get daily => 'DAILY';

  @override
  String get weekly => 'WEEKLY';

  @override
  String get weeklyinterval2 => 'WEEKLY;INTERVAL=2';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get martial_arts => 'Martial Arts';

  @override
  String get football => 'Football';

  @override
  String get basketball => 'Basketball';

  @override
  String get volleyball => 'Volleyball';

  @override
  String get tennis => 'Tennis';

  @override
  String get running => 'Running';

  @override
  String get gym => 'Gym';

  @override
  String get swimming => 'Swimming';

  @override
  String get cycling => 'Cycling';

  @override
  String get hiking => 'Hiking';

  @override
  String get yoga => 'Yoga';

  @override
  String get other => 'Other';

  @override
  String get no_ride_info_yet => 'No ride info yet';

  @override
  String get need_ride => 'need_ride';

  @override
  String get self_arranged => 'self_arranged';

  @override
  String get repeat => 'Repeat';

  @override
  String get no_recurrence_pattern_fits_this_startend_window =>
      'No recurrence pattern fits this start/end window. ';

  @override
  String get extend_end_time_or_set_a_later_repeat_end_date =>
      'Extend end time or set a later repeat end date.';

  @override
  String get failed_to_load_attendees => 'Failed to load attendees';

  @override
  String get no_attendees_yet => 'No attendees yet';

  @override
  String get failed_to_open_chat_please_try_again =>
      'Failed to open chat. Please try again.';

  @override
  String get view_all_attendees => 'View all attendees →';

  @override
  String get cancel_event => 'Cancel Event';

  @override
  String get keep_event => 'Keep Event';

  @override
  String get delete_event => 'Delete Event';

  @override
  String get are_you_sure_you_want_to_delete =>
      'Are you sure you want to delete ';

  @override
  String get recurring_event => '⚠️ Recurring Event';

  @override
  String get this_event => 'This event';

  @override
  String get all_events => 'All events';

  @override
  String get not_label => 'not';

  @override
  String get custom_label => 'custom';

  @override
  String get opening_google_calendar => 'Opening Google Calendar...';

  @override
  String opening_google_calendar_recurring(Object patternLabel) {
    return 'Opening Google Calendar (recurring: $patternLabel)...';
  }

  @override
  String
  get this_event_repeats_deleting_it_will_remove_all_occurrences_past_and_future =>
      'This event repeats. Deleting it will remove ALL occurrences (past and future).';

  @override
  String
  get to_delete_only_specific_occurrences_use_google_calendar_tap_the_event =>
      'To delete only specific occurrences, use Google Calendar: tap the event → ';

  @override
  String get cancel => 'cancel';

  @override
  String get delete => 'Delete';

  @override
  String get premium_event_chat => 'Premium event chat';

  @override
  String get subscribe_to_premium_to_join_attendee_group_chats_for_events =>
      'Subscribe to Premium to join attendee group chats for events.';

  @override
  String get upgrade_to_premium => 'Upgrade to Premium';

  @override
  String get reason_optional => 'Reason (optional)';

  @override
  String get event_group_chat_is_available_to_premium_subscribers_only =>
      'Event group chat is available to Premium subscribers only.';

  @override
  String
  get could_not_open_calendar_please_ensure_google_calendar_is_available =>
      'Could not open calendar. Please ensure Google Calendar is available.';

  @override
  String get events_near_me => 'Events near me';

  @override
  String get everywhere => 'Everywhere';

  @override
  String get retry_loading_events => 'Retry loading events';

  @override
  String get all_loaded_events_shown => 'All loaded events shown';

  @override
  String get load_more_events => 'Load more events';

  @override
  String get create_event => 'Create event';

  @override
  String get could_not_load_events => 'Could not load events';

  @override
  String get no_matching_loaded_events => 'No matching loaded events';

  @override
  String get search_loaded_events_by_title_place_organizer =>
      'Search loaded events by title, place, organizer';

  @override
  String get now => 'now';

  @override
  String get title_is_required => 'Title is required';

  @override
  String get title_must_be_at_least_3_characters =>
      'Title must be at least 3 characters';

  @override
  String get please_pick_a_location => 'Please pick a location.';

  @override
  String get start_time_must_be_in_the_future =>
      'Start time must be in the future.';

  @override
  String get end_time_must_be_after_start_time =>
      'End time must be after start time.';

  @override
  String get select_a_recurrence_pattern => 'Select a recurrence pattern.';

  @override
  String get repeat_end_date_must_be_on_or_after_the_start_date =>
      'Repeat end date must be on or after the start date.';

  @override
  String get please_wait_for_the_current_submission_to_finish =>
      'Please wait for the current submission to finish.';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get please_select_a_location => 'Please select a location.';

  @override
  String get start_time_is_required => 'Start time is required';

  @override
  String get event_is_still_loading => 'Event is still loading.';

  @override
  String get event_created_but_the_cover_image_could_not_be_uploaded =>
      'Event created, but the cover image could not be uploaded.';

  @override
  String get ride_in_progress => 'RIDE IN PROGRESS';

  @override
  String get next_ride => 'Next ride';

  @override
  String get review_and_respond_before_passengers_choose_another_ride =>
      'Review and respond before passengers choose another ride.';

  @override
  String get ready_for_your_next_trip => 'Ready for your next trip?';

  @override
  String get publish_a_ride_and_start_receiving_passenger_requests =>
      'Publish a ride and start receiving passenger requests.';

  @override
  String get mapControlLabel => 'Map control';

  @override
  String rideFilterSemantics(String filterLabel, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rides',
      one: '1 ride',
      zero: '0 rides',
    );
    return '$filterLabel filter, $_temp0';
  }

  @override
  String get last_updated_february_23_2026 => 'Last updated: February 23, 2026';

  @override
  String get en => 'en';

  @override
  String get utf8 => 'UTF-8';

  @override
  String get viewport => 'viewport';

  @override
  String get widthdevicewidth_initialscale10 =>
      'width=device-width, initial-scale=1.0';

  @override
  String get subtitle => 'subtitle';

  @override
  String get highlight => 'highlight';

  @override
  String get mailtolegalsportconnectapp => 'mailto:legal@sportconnect.app';

  @override
  String get mailtoprivacysportconnectapp => 'mailto:privacy@sportconnect.app';

  @override
  String get delete_conversation => 'Delete conversation';

  @override
  String get this_will_remove_the_conversation_from_your_chat_list =>
      'This will remove the conversation from your chat list. ';

  @override
  String get clear_chat_history => 'Clear chat history';

  @override
  String get this_will_clear_the_messages_from_this_chat_for_you_only =>
      'This will clear the messages from this chat for you only. ';

  @override
  String get clear_history => 'Clear history';

  @override
  String get message_options => 'Message options';

  @override
  String get attachments => 'Attachments';

  @override
  String get conversation_deleted => 'Conversation deleted';

  @override
  String get choose_what_you_want_to_share_in_this_chat =>
      'Choose what you want to share in this chat.';

  @override
  String get failedToSendMessage => 'Failed to send message';

  @override
  String get cameraAccessIsNeededToTakeAndSendPhotosInThisChat =>
      'Camera access is needed to take and send photos in this chat.';

  @override
  String get failedToSendImage => 'Failed to send image';

  @override
  String get permissionDeniedPleaseCheckYourConnectionAndTryAgain =>
      'Permission denied. Please check your connection and try again.';

  @override
  String get networkErrorPleaseCheckYourInternetConnection =>
      'Network error. Please check your internet connection.';

  @override
  String get clearChatHistoryMessage =>
      'This will clear the messages from this chat for you only. The conversation will stay in your chat list.';

  @override
  String get pleaseEnableLocationServices => 'Please enable location services';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get couldNotGetYourLocation => 'Could not get your location';

  @override
  String failedToGetLocationValue(Object value) {
    return 'Failed to get location: $value';
  }

  @override
  String get draft => 'Draft';

  @override
  String get preview_mode => 'Preview mode';

  @override
  String get chat_preview => 'Chat preview';

  @override
  String get person_add => 'person_add';

  @override
  String get check_circle => 'check_circle';

  @override
  String get event_busy => 'event_busy';

  @override
  String get schedule => 'schedule';

  @override
  String get directions_car => 'directions_car';

  @override
  String get flag => 'flag';

  @override
  String get block => 'block';

  @override
  String get chat_bubble => 'chat_bubble';

  @override
  String get person => 'person';

  @override
  String get arrow_upward => 'arrow_upward';

  @override
  String get emoji_events => 'emoji_events';

  @override
  String get local_fire_department => 'local_fire_department';

  @override
  String get star => 'star';

  @override
  String get warning => 'warning';

  @override
  String get campaign => 'campaign';

  @override
  String get gold => 'Gold';

  @override
  String get new_ride_request => 'New Ride Request';

  @override
  String get booking_accepted => 'Booking Accepted!';

  @override
  String get booking_declined => 'Booking Declined';

  @override
  String get ride_cancelled => 'Ride Cancelled';

  @override
  String get new_message => 'New Message';

  @override
  String get achievement_unlocked => 'Achievement Unlocked! 🏆';

  @override
  String get level_up => 'Level Up! 🎉';

  @override
  String get driver_has_arrived => 'Driver has arrived! 🚗';

  @override
  String get event_cancelled => 'Event Cancelled';

  @override
  String get mark_read => 'mark_read';

  @override
  String get find_yournride => 'Find Your\\nRide';

  @override
  String get match_with_runners => 'Match with Runners';

  @override
  String get offer_anseat => 'Offer a\\nSeat';

  @override
  String get drive_split_costs => 'Drive & Split Costs';

  @override
  String get plan_yournroute => 'Plan Your\\nRoute';

  @override
  String get smart_route_sync => 'Smart Route Sync';

  @override
  String get connectn_go => 'Connect\\n& Go';

  @override
  String get community_you_trust => 'Community You Trust';

  @override
  String get onboarding_complete => 'onboarding_complete';

  @override
  String get last_onboarding_version => 'last_onboarding_version';

  @override
  String get ride_to_paris_10k => 'Ride to Paris 10K';

  @override
  String get offer_your_ride => 'Offer your ride';

  @override
  String get paris_10k_2_seats_available => 'Paris 10K • 2 seats available';

  @override
  String get estimated_earning => 'ESTIMATED EARNING';

  @override
  String get fill_2_seats => 'Fill 2 seats';

  @override
  String get set_available_seats => 'Set available seats';

  @override
  String get flexible => 'Flexible';

  @override
  String get driver_tools => 'Driver tools';

  @override
  String get pickup_route => 'Pickup route';

  @override
  String get coordinate_pickup_before_the_event =>
      'Coordinate pickup before the event';

  @override
  String get trip_plan => 'Trip plan';

  @override
  String get sun_15_jun => 'Sun, 15 Jun';

  @override
  String get paris_10k_2_passengers => 'Paris 10K • 2 passengers';

  @override
  String get inapp_chat => 'In-app chat';

  @override
  String get confirm_bags_pickup_spot_and_arrival_time =>
      'Confirm bags, pickup spot, and arrival time.';

  @override
  String get runner_carpool_network => 'Runner carpool network';

  @override
  String get travel_with_people_going_to_the_same_event =>
      'Travel with people going to the same event.';

  @override
  String get sun_15_jun_2025 => 'Sun, 15 Jun 2025';

  @override
  String get pickup_near_paris_france => 'Pickup near Paris, France';

  @override
  String get passenger_contribution_from_8 => 'Passenger contribution from €8';

  @override
  String get find_a_ride_to_your_race => 'Find a ride to your race';

  @override
  String get offer_seats_and_earn => 'Offer seats and earn';

  @override
  String get plan_the_route_together => 'Plan the route together';

  @override
  String get connect_safely_and_go => 'Connect safely and go';

  @override
  String get paris => 'PARIS';

  @override
  String get driver_starts => 'Driver starts';

  @override
  String get route_opens_for_passengers => 'Route opens for passengers';

  @override
  String get pickup_confirmed => 'Pickup confirmed';

  @override
  String get shared_meeting_point => 'Shared meeting point';

  @override
  String get arrive_at_event => 'Arrive at event';

  @override
  String get paris_10k_race_village => 'Paris 10K race village';

  @override
  String get trusted_runners => 'Trusted runners';

  @override
  String get chat => 'Chat';

  @override
  String get before_pickup => 'Before pickup';

  @override
  String get live_route => 'Live route';

  @override
  String get trip_visibility => 'Trip visibility';

  @override
  String get safer_rides => 'Safer rides';

  @override
  String get event_travel => 'Event travel';

  @override
  String get from_8 => 'From €8';

  @override
  String get rides_available => 'RIDES AVAILABLE';

  @override
  String get fuel_offset => 'Fuel offset';

  @override
  String get earn => 'Earn';

  @override
  String get set_time => 'Set time';

  @override
  String get pickup_0640 => 'Pickup 06:40';

  @override
  String get previous_step => 'Previous step';

  @override
  String get month => 'month';

  @override
  String get cancel_anytime => 'Cancel anytime';

  @override
  String get save_about_16_compared_to_monthly =>
      'Save about 16% compared to monthly';

  @override
  String get actionrequiredrequestedcapabilities =>
      'actionRequiredRequestedCapabilities';

  @override
  String get listed => 'listed';

  @override
  String get platformpaused => 'platformPaused';

  @override
  String get rejectedfraud => 'rejectedFraud';

  @override
  String get rejectedincompleteverification => 'rejectedIncompleteVerification';

  @override
  String get rejectedlisted => 'rejectedListed';

  @override
  String get rejectedother => 'rejectedOther';

  @override
  String get rejectedplatformfraud => 'rejectedPlatformFraud';

  @override
  String get rejectedplatformother => 'rejectedPlatformOther';

  @override
  String get rejectedplatformtermsofservice => 'rejectedPlatformTermsOfService';

  @override
  String get rejectedtermsofservice => 'rejectedTermsOfService';

  @override
  String get requirementspastdue => 'requirementsPastDue';

  @override
  String get requirementspendingverification =>
      'requirementsPendingVerification';

  @override
  String get underreview => 'underReview';

  @override
  String get canceled => 'canceled';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get bankaccount => 'bankAccount';

  @override
  String get bank_account => 'bank_account';

  @override
  String get google_play_billing_is_not_available_on_this_app_instance =>
      'Google Play Billing is not available on this app instance. ';

  @override
  String get google_play_billing_is_unavailable_on_this_deviceaccount =>
      'Google Play Billing is unavailable on this device/account.';

  @override
  String
  get this_subscription_product_is_not_available_for_your_accountregion_yet =>
      'This subscription product is not available for your account/region yet.';

  @override
  String get purchase_cancelled_by_user => 'Purchase cancelled by user.';

  @override
  String get channelerror => 'channel-error';

  @override
  String
  get withdrawable_now_is_your_instantavailable_balance_you_can_transfer_this_to_your_bank_immediatelynn =>
      'Withdrawable Now is your instant-available balance — you can transfer this to your bank immediately.\\n\\n';

  @override
  String get got_it => 'Got it';

  @override
  String
  get withdrawable_now_is_your_instantavailable_balance_processing_funds_are_in_stripe =>
      'Withdrawable Now is your instant-available balance. Processing funds are in Stripe';

  @override
  String
  get your_stripe_account_id_is_missing_please_reconnect_your_payout_account =>
      'Your Stripe account ID is missing. Please reconnect your payout account.';

  @override
  String get writeln_writelnl10nexportearningssummary_writeln =>
      ')\r\n      ..writeln()\r\n      ..writeln(l10n.exportEarningsSummary)\r\n      ..writeln(\r\n        ';

  @override
  String get get_paid_fornevery_ride => 'Get paid for\\nevery ride';

  @override
  String get set_up_eur_payouts_in_minutes_andnreceive_earnings_automatically =>
      'Set up EUR payouts in minutes and\\nreceive earnings automatically.';

  @override
  String get eur_balance => 'EUR balance';

  @override
  String get ready_for_eur_payout => 'Ready for EUR payout';

  @override
  String get why_drivers_love_payouts_onnsportconnect =>
      'Why drivers love payouts on\\nSportConnect';

  @override
  String get before_you_continue => 'Before you continue';

  @override
  String get heres_what_youll_need_to_get_set_up =>
      'Here’s what you’ll need to get set up.';

  @override
  String get maybe_later => 'Maybe later';

  @override
  String get payouts_ready => 'Payouts ready!';

  @override
  String get your_account_is_connected_and_yourenall_set_to_receive_earnings =>
      'Your account is connected and you’re\\nall set to receive earnings.';

  @override
  String get powered_by => 'Powered by';

  @override
  String get stripe => 'stripe';

  @override
  String get s => 'S';

  @override
  String get takes_about_3_minutes => 'Takes about 3 minutes';

  @override
  String get your_security_is_our_priority => 'Your security is our priority';

  @override
  String
  get sportconnect_partners_with_stripe_to_securely_collect_and_protect_your_information_your_data_is_encrypted_and_never_shared_with_us =>
      'SportConnect partners with Stripe to securely collect and protect your information. Your data is encrypted and never shared with us.';

  @override
  String get payout_account => 'Payout account';

  @override
  String get bnp_paribas_4521 => 'BNP Paribas •••• 4521';

  @override
  String get next_payout => 'Next payout';

  @override
  String get wed_28_may => 'Wed, 28 May';

  @override
  String get payout_schedule => 'Payout schedule';

  @override
  String get weekly_to_your_french_iban => 'Weekly to your French IBAN';

  @override
  String get earnings_snapshot => 'Earnings snapshot';

  @override
  String get this_week => 'This week⌄';

  @override
  String get youre_doing_great => 'You’re doing great!';

  @override
  String get keep_driving_more_rides_more_earnings =>
      'Keep driving. More rides, more earnings.';

  @override
  String get connect_stripe_account => 'Connect Stripe account';

  @override
  String get continue_to_stripe => 'Continue to Stripe';

  @override
  String get back_to_dashboard => 'Back to dashboard';

  @override
  String get need_help_visit_our => 'Need help? Visit our ';

  @override
  String get support_center => 'Support Center';

  @override
  String get secure_by_stripe => 'Secure by Stripe';

  @override
  String get pci_dss_compliant => 'PCI DSS Compliant';

  @override
  String get fast_payouts => 'Fast payouts';

  @override
  String get secure => 'Secure';

  @override
  String get eugrade_safety => 'EU-grade safety';

  @override
  String get low_fees => 'Low fees';

  @override
  String get transparent_pricing => 'Transparent pricing';

  @override
  String get french_iban => 'French IBAN';

  @override
  String get to_receive_eur_payouts => 'To receive EUR payouts';

  @override
  String get identity_verification => 'Identity verification';

  @override
  String get carte_didentit_or_passport => 'Carte d’identité or passport';

  @override
  String get french_tax_details => 'French tax details';

  @override
  String get for_french_tax_records => 'For French tax records';

  @override
  String get payment_method_saved => 'Payment method saved';

  @override
  String get total_spent => 'Total Spent';

  @override
  String
  get instant_payouts_can_be_cancelled_while_still_pending_once_in_transit_your_bank_is_already_processing_the_transfer =>
      'Instant payouts can be cancelled while still pending. Once in transit, your bank is already processing the transfer.';

  @override
  String get payout_progress => 'Payout Progress';

  @override
  String get why_did_this_fail => 'Why did this fail?';

  @override
  String get payout_requested => 'Payout Requested';

  @override
  String get processing => 'Processing';

  @override
  String get in_transit_to_bank => 'In Transit to Bank';

  @override
  String get funds_arrived => 'Funds Arrived';

  @override
  String get method => 'Method';

  @override
  String get this_payout_cannot_be_cancelled_no_stripe_reference_found =>
      'This payout cannot be cancelled — no Stripe reference found.';

  @override
  String get choose_your_plan => 'Choose your plan';

  @override
  String get upgrade_your_sportconnect_account_in_seconds =>
      'Upgrade your SportConnect account in seconds.';

  @override
  String get loading_subscription_plans => 'Loading subscription plans...';

  @override
  String get retry_loading_plans => 'Retry loading plans';

  @override
  String get your_payment_details_are_encrypted_and_processed_securely =>
      'Your payment details are encrypted and processed securely.';

  @override
  String get subscribe_now => 'Subscribe Now';

  @override
  String get premium_checkout => 'Premium Checkout';

  @override
  String get premium_activated_successfully =>
      'Premium activated successfully.';

  @override
  String get upgrade_to_pro => 'Upgrade to Pro';

  @override
  String get premium_carpooling_madenfor_runners_like_you =>
      'Premium carpooling made\\nfor runners like you';

  @override
  String get everything_you_get => 'Everything you get';

  @override
  String get pricingUnavailableCheckYourConnection =>
      'Pricing unavailable — check your connection';

  @override
  String get pricingUnavailableTapToRetry =>
      'Pricing unavailable — tap to retry';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get billedMonthly => 'Billed monthly';

  @override
  String get trusted_by_12000_runners => 'Trusted by 12,000+ runners';

  @override
  String get start_free_trial => 'Start Free Trial';

  @override
  String get smart_ride_matching => 'Smart Ride Matching';

  @override
  String get unlimited_saved_routes => 'Unlimited Saved Routes';

  @override
  String get verified_community => 'Verified Community';

  @override
  String get crew_coordination => 'Crew Coordination';

  @override
  String get race_day_priority => 'Race Day Priority';

  @override
  String get priority_support => 'Priority Support';

  @override
  String get smart_match => 'Smart Match';

  @override
  String get unlimited_routes => 'Unlimited Routes';

  @override
  String get verified_riders => 'Verified Riders';

  @override
  String get crew_rides => 'Crew Rides';

  @override
  String get race_priority => 'Race Priority';

  @override
  String get annual => 'Annual';

  @override
  String get appStoreBilling => 'App Store billing';

  @override
  String get securePayment => 'Secure payment';

  @override
  String get joinRunnersWorldwide => 'Join runners worldwide';

  @override
  String get smartRideMatchingDescription =>
      'Auto-paired with runners heading to your race or training spot.';

  @override
  String get unlimitedSavedRoutesDescription =>
      'Save and share your favorite carpool routes with your crew.';

  @override
  String get verifiedCommunityDescription =>
      'Every rider is ID-verified. Ride safe with trusted runners.';

  @override
  String get crewCoordinationDescription =>
      'Organize group rides for your entire running club in one tap.';

  @override
  String get raceDayPriorityDescription =>
      'First pick on rides for marathon day and major events.';

  @override
  String get prioritySupportDescription =>
      'Skip the queue. Get help within minutes, not hours.';

  @override
  String get moneybacknguarantee => 'Money-back\\nguarantee';

  @override
  String get cancelnanytime => 'Cancel\\nanytime';

  @override
  String get securenpayment => 'Secure\\npayment';

  @override
  String get completed => 'Completed';

  @override
  String get thisweek => 'thisWeek';

  @override
  String get unable_to_complete_checkout_please_try_again =>
      'Unable to complete checkout. Please try again.';

  @override
  String get version_119 => 'Version 1.1.9';

  @override
  String get built_with_flutter => 'Built with Flutter';

  @override
  String get sportconnect_is_a_carpooling_and_rideshare_platform_designed =>
      'SportConnect is a carpooling and rideshare platform designed ';

  @override
  String get join_the_community => 'Join the Community';

  @override
  String get open_source_licenses => 'Open Source Licenses';

  @override
  String get total_xp => 'Total XP';

  @override
  String get streak => 'Streak';

  @override
  String get diamond => 'Diamond';

  @override
  String get platinum => 'Platinum';

  @override
  String get bronze => 'Bronze';

  @override
  String get background_check_passed => 'Background Check Passed';

  @override
  String
  get your_background_check_is_complete_and_you_are_verified_to_drive_with_sportconnect =>
      'Your background check is complete and you are verified to drive with SportConnect.';

  @override
  String get attach_image => 'Attach image';

  @override
  String get action_required => 'Action Required';

  @override
  String get driver_license => 'Driver License';

  @override
  String get vehicle_registration => 'Vehicle Registration';

  @override
  String get vehicle_insurance => 'Vehicle Insurance';

  @override
  String get upload_feature_coming_soon => 'Upload feature coming soon';

  @override
  String get phone_number => 'Phone Number';

  @override
  String get try_different_keywords_or_contact_support =>
      'Try different keywords or contact support';

  @override
  String get getting_started => 'Getting Started';

  @override
  String get rides_booking => 'Rides & Booking';

  @override
  String get safety_trust => 'Safety & Trust';

  @override
  String get account_profile => 'Account & Profile';

  @override
  String get help_center_getting_started_create_account_question =>
      'How do I create an account?';

  @override
  String get help_center_getting_started_create_account_answer =>
      'Download the app, tap \"Sign Up\", and follow the wizard. You can sign up with email, Google, or Apple ID.';

  @override
  String get help_center_getting_started_switch_role_question =>
      'How do I switch between rider and driver?';

  @override
  String get help_center_getting_started_switch_role_answer =>
      'Go to Profile > Settings > Switch Role. If you haven\'t registered as a driver yet, you\'ll need to complete the driver onboarding process.';

  @override
  String get help_center_getting_started_free_question =>
      'Is SportConnect free to use?';

  @override
  String get help_center_getting_started_free_answer =>
      'Creating an account is free. Riders pay per ride booked. Drivers earn money by offering rides minus a small service fee.';

  @override
  String get help_center_rides_booking_question => 'How do I book a ride?';

  @override
  String get help_center_rides_booking_answer =>
      'Search for rides from the Explore tab, select a ride that matches your route, review the details, and tap \"Book Ride\".';

  @override
  String get help_center_rides_cancel_question => 'Can I cancel a booked ride?';

  @override
  String get help_center_rides_cancel_answer =>
      'Yes, go to Activity > select the ride > Cancel. Please note that frequent cancellations may affect your rating.';

  @override
  String get help_center_rides_matching_question =>
      'How does ride matching work?';

  @override
  String get help_center_rides_matching_answer =>
      'Our algorithm matches riders with drivers based on route overlap, departure time, and user preferences. You can also request a ride and let drivers find you.';

  @override
  String get help_center_rides_late_question => 'What if my ride is late?';

  @override
  String get help_center_rides_late_answer =>
      'You\'ll receive real-time updates on your ride status. If the driver is significantly late, you can contact them directly through the in-app chat.';

  @override
  String get help_center_payments_question => 'How do payments work?';

  @override
  String get help_center_payments_answer =>
      'Payments are processed securely through Stripe. Riders pay when booking, and drivers receive earnings after ride completion.';

  @override
  String get help_center_payouts_question => 'When do drivers get paid?';

  @override
  String get help_center_payouts_answer =>
      'Drivers receive payouts weekly to their linked Stripe account. You can track your earnings in the Earnings tab.';

  @override
  String get help_center_fees_question => 'What are the service fees?';

  @override
  String get help_center_fees_answer =>
      'SportConnect charges a small service fee (typically 10%) to cover platform costs, payment processing, and insurance.';

  @override
  String get help_center_safety_question => 'How is my safety ensured?';

  @override
  String get help_center_safety_answer =>
      'All drivers undergo verification. Rides include live GPS tracking, in-app chat, and all trips are logged for safety.';

  @override
  String get help_center_safety_report_question =>
      'How do I report a safety issue?';

  @override
  String get help_center_safety_report_answer =>
      'Go to Settings > Report a Problem during or after a ride. Safety reports are prioritized and reviewed within 24 hours.';

  @override
  String get help_center_safety_share_question =>
      'Can I share my ride with someone?';

  @override
  String get help_center_safety_share_answer =>
      'Yes, during an active ride you can share your live trip details with trusted contacts.';

  @override
  String get help_center_account_verify_question =>
      'How do I verify my account?';

  @override
  String get help_center_account_verify_answer =>
      'Go to Settings > Verify Account. You can verify your email, phone number, and provide government ID for full verification.';

  @override
  String get help_center_account_delete_question =>
      'How do I delete my account?';

  @override
  String get help_center_account_delete_answer =>
      'Go to Settings > Account Actions > Delete Account. This action is permanent and cannot be undone.';

  @override
  String get help_center_account_email_question =>
      'Can I change my email address?';

  @override
  String get help_center_account_email_answer =>
      'Currently, you can update your display name and profile info. For email changes, please contact support.';

  @override
  String get my_vehicles => 'My Vehicles';

  @override
  String get manage_your_vehicles => 'Manage your vehicles';

  @override
  String get my_events => 'My Events';

  @override
  String get created_joined_events => 'Created & joined events';

  @override
  String get achievements => 'Achievements';

  @override
  String get view_your_badges_rewards => 'View your badges & rewards';

  @override
  String get view_your_notifications => 'View your notifications';

  @override
  String get settings => 'Settings';

  @override
  String get app_preferences_privacy => 'App preferences & privacy';

  @override
  String get report => 'report';

  @override
  String get attach_evidence => 'Attach evidence';

  @override
  String get manage_booking_pickup_radius_payout_and_map_visibility =>
      'Manage booking, pickup radius, payout, and map visibility';

  @override
  String get choose_map_appearance => 'Choose map appearance';

  @override
  String
  get by_using_sportconnect_you_consent_to_the_data_processing_described_above_and_in_our_privacy_policy =>
      'By using SportConnect, you consent to the data processing described above and in our Privacy Policy.';

  @override
  String get sportconnect_premium => 'SportConnect Premium';

  @override
  String get unlock_smart_matching_priority_rides_more =>
      'Unlock smart matching, priority rides & more';

  @override
  String get notification_permission => 'Notification Permission';

  @override
  String get reallow_push_notifications_for_this_device =>
      'Re-allow push notifications for this device';

  @override
  String get analytics_crash_reports => 'Analytics & Crash Reports';

  @override
  String get allow_anonymous_usage_data_and_crash_reports =>
      'Allow anonymous usage data and crash reports';

  @override
  String get data_processing_notice => 'Data Processing Notice';

  @override
  String get how_we_collect_use_and_protect_your_data =>
      'How we collect, use, and protect your data';

  @override
  String get withdraw_consent => 'Withdraw Consent';

  @override
  String get manage_or_withdraw_your_data_consent =>
      'Manage or withdraw your data consent';

  @override
  String get download_my_data => 'Download My Data';

  @override
  String get export_a_copy_of_your_personal_data =>
      'Export a copy of your personal data';

  @override
  String get view_your_past_rides_and_charges =>
      'View your past rides and charges';

  @override
  String get update_your_account_password => 'Update your account password';

  @override
  String get get_help_from_our_team => 'Get help from our team';

  @override
  String get manage_subscription => 'Manage Subscription';

  @override
  String get cancel_or_change_your_plan_in_the_store =>
      'Cancel or change your plan in the store';

  @override
  String get restore_purchases => 'Restore Purchases';

  @override
  String get reapply_your_active_subscription =>
      'Re-apply your active subscription';

  @override
  String get booking => 'Booking';

  @override
  String get radius => 'Radius';

  @override
  String get could_not_open_subscription_management =>
      'Could not open subscription management.';

  @override
  String get available_forms => 'Available Forms';

  @override
  String get downloading_document => 'Downloading document...';

  @override
  String get available => 'Available';

  @override
  String get notAvailableYet => 'Not available yet';

  @override
  String get thisPlanIsNotAvailableFromTheStoreYet =>
      'This plan is not available from the store yet.';

  @override
  String get protect_your_account => 'Protect your account';

  @override
  String
  get twofactor_authentication_adds_an_extra_layer_of_security_to_your_account_to_log_in_you =>
      'Two-factor authentication adds an extra layer of security to your account. To log in, you';

  @override
  String get sms_verification => 'SMS Verification';

  @override
  String get receive_codes_via_text_message => 'Receive codes via text message';

  @override
  String get medium => 'medium';

  @override
  String get please_describe_the_issue => 'Please describe the issue';

  @override
  String get inapp => 'In-App';

  @override
  String get driver_review => 'Driver Review';

  @override
  String get passenger_review => 'Passenger Review';

  @override
  String get just_now => 'Just now';

  @override
  String get as_driver => 'As Driver';

  @override
  String get as_rider => 'As Rider';

  @override
  String get report_review => 'Report Review';

  @override
  String get na => 'N/A';

  @override
  String get departure_time => 'departure_time';

  @override
  String get scheduled => 'scheduled';

  @override
  String get refunded => 'refunded';

  @override
  String get partiallyrefunded => 'partiallyRefunded';

  @override
  String get instant => 'instant';

  @override
  String get marked_as_noshow => 'Marked as No-Show';

  @override
  String get ride_delayed => 'Ride Delayed';

  @override
  String get view => 'View';

  @override
  String get no_pending_requests => 'No pending requests';

  @override
  String get done => 'Done';

  @override
  String get destination_is_locked_because_an_event_is_selected =>
      'Destination is locked because an event is selected.';

  @override
  String get how_was_your_passenger => 'How was your passenger?';

  @override
  String get your_honest_feedback_helps_build_a_safer_more_reliable_community =>
      'Your honest feedback helps build a safer, more reliable community.';

  @override
  String get no_accepted_passengers_to_rate_for_this_ride =>
      'No accepted passengers to rate for this ride.';

  @override
  String get select_passenger_to_rate => 'Select passenger to rate';

  @override
  String get comment_optional => 'Comment (optional)';

  @override
  String get passenger => 'Passenger';

  @override
  String get message_passenger => 'Message passenger';

  @override
  String get in_progress => 'In Progress';

  @override
  String get loading_route => 'Loading route...';

  @override
  String get waiting_for_driver => 'Waiting for driver';

  @override
  String get location_access_denied_tap_to_open_settings_and_reenable =>
      'Location access denied. Tap to open Settings and re-enable.';

  @override
  String get driver_location_unavailable_for_5_min =>
      'Driver location unavailable for 5+ min';

  @override
  String get poor_connection_updates_may_be_delayed =>
      'Poor connection — updates may be delayed';

  @override
  String get your_pickup_code => 'Your Pickup Code';

  @override
  String get show_this_to_your_driver => 'Show this to your driver';

  @override
  String get show_my_pickup_code => 'Show my pickup code';

  @override
  String get your_pickup_confirmation_code => 'Your pickup confirmation code';

  @override
  String get trip_is_taking_longer_than_expected_is_everything_okay =>
      'Trip is taking longer than expected — is everything okay?';

  @override
  String get complete_payment_to_confirm_your_seat =>
      'Complete payment to confirm your seat';

  @override
  String get paid => 'PAID';

  @override
  String get passed => 'Passed';

  @override
  String get night_ride_stay_alert_and_share_your_trip_with_someone_you_trust =>
      'Night ride — stay alert and share your trip with someone you trust';

  @override
  String get route_deviation_detected => 'Route Deviation Detected';

  @override
  String get trip_progress => 'Trip Progress';

  @override
  String get driver_at_pickup => 'Driver at Pickup';

  @override
  String get price_summary => 'Price summary';

  @override
  String get cancellation_policy => 'Cancellation policy';

  @override
  String get you_can_cancel_before_the_driver_accepts_your_request =>
      'You can cancel before the driver accepts your request.';

  @override
  String get totaln => 'Total\\n';

  @override
  String get complete_booking => 'Complete booking';

  @override
  String get review_your_ride_before_sending_the_request =>
      'Review your ride before sending the request';

  @override
  String get choose_how_many_seats_you_need => 'Choose how many seats you need';

  @override
  String get booking_request => 'Booking request';

  @override
  String get the_driver_will_approve_your_request =>
      'The driver will approve your request';

  @override
  String get protected_booking => 'Protected booking';

  @override
  String get your_request_is_safely_recorded_in_sportconnect =>
      'Your request is safely recorded in SportConnect';

  @override
  String get review => 'Review';

  @override
  String get pickup_point => 'Pickup point';

  @override
  String get dropoff_point => 'Drop-off point';

  @override
  String get seat_price => 'Seat price';

  @override
  String get seats_selected => 'Seats selected';

  @override
  String get service_fee => 'Service fee';

  @override
  String get booking_confirmed => 'Booking Confirmed';

  @override
  String get price => 'Price ↓';

  @override
  String get are_you_sure_you_want_to_cancel_this_ride =>
      'Are you sure you want to cancel this ride?';

  @override
  String get frequent_cancellations_may_affect_your_account_rating =>
      'Frequent cancellations may affect your account rating.';

  @override
  String get please_let_us_know_why_you => 'Please let us know why you';

  @override
  String get select_a_reason => 'Select a reason';

  @override
  String get additional_comments_optional => 'Additional comments (optional)';

  @override
  String get unable_to_load_ride_completion_details =>
      'Unable to load ride completion details.';

  @override
  String get trip_completed => 'Trip Completed!';

  @override
  String get thanks_for_riding_with_sportconnect =>
      'Thanks for riding with SportConnect';

  @override
  String get trip_summary => 'Trip Summary';

  @override
  String get fare_breakdown => 'Fare Breakdown';

  @override
  String get submitting_ride_please_wait => 'Submitting ride, please wait...';

  @override
  String get please_set_origin_and_destination_in_step_1 =>
      'Please set origin and destination in Step 1';

  @override
  String get origin_and_destination_cannot_be_the_same_location =>
      'Origin and destination cannot be the same location';

  @override
  String get please_set_a_departure_date_and_time_in_step_1 =>
      'Please set a departure date and time in Step 1';

  @override
  String get departure_time_must_be_in_the_future_go_back_to_step_1 =>
      'Departure time must be in the future — go back to Step 1';

  @override
  String get departure_must_be_at_least_15_minutes_from_now =>
      'Departure must be at least 15 minutes from now';

  @override
  String get please_select_a_vehicle_in_step_2 =>
      'Please select a vehicle in Step 2';

  @override
  String get number_of_seats_must_be_between_1_and_8_go_back_to_step_2 =>
      'Number of seats must be between 1 and 8 — go back to Step 2';

  @override
  String get please_select_at_least_one_recurring_day =>
      'Please select at least one recurring day';

  @override
  String get please_set_a_recurring_end_date =>
      'Please set a recurring end date';

  @override
  String get please_enter_both_locations => 'Please enter both locations';

  @override
  String get pickup_and_destination_cannot_be_the_same_location =>
      'Pickup and destination cannot be the same location';

  @override
  String get cannot_search_for_past_dates => 'Cannot search for past dates';

  @override
  String get seats_must_be_between_1_and_4 => 'Seats must be between 1 and 4';

  @override
  String get cancelled_by_user => 'Cancelled by user';

  @override
  String get gasoline => 'Gasoline';

  @override
  String get diesel => 'Diesel';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get plugin_hybrid => 'Plug-in Hybrid';

  @override
  String get hydrogen => 'Hydrogen';

  @override
  String get car => 'Car';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get van => 'Van';

  @override
  String get truck => 'Truck';

  @override
  String get bicycle => 'Bicycle';

  @override
  String get your_fleet => 'Your Fleet';

  @override
  String get register_a_new_car_for_carpool_rides =>
      'Register a new car for carpool rides';

  @override
  String get in_use => 'In Use';

  @override
  String get riders_see_this_photo_before_booking =>
      'Riders see this photo before booking';

  @override
  String get inlineEventChooseEvent => 'Choose an event';

  @override
  String get inlineEventLinkOptional => 'Link to a sport event (optional)';

  @override
  String get inlineEventClearSelected => 'Clear selected event';

  @override
  String get inlineEventSearchHint =>
      'Search loaded events by title, place, organizer';

  @override
  String get inlineEventClearSearch => 'Clear search';

  @override
  String get inlineEventAll => 'All';

  @override
  String get inlineEventCouldNotLoad => 'Could not load events';

  @override
  String get inlineEventNoMatches => 'No matching loaded events';

  @override
  String get inlineEventLoadMoreOrSearch =>
      'Load more events or change the search.';

  @override
  String get inlineEventTryAnotherFilter => 'Try another search or filter.';

  @override
  String get inlineEventLoadMore => 'Load more';

  @override
  String get inlineEventRetryLoading => 'Retry loading events';

  @override
  String get inlineEventAllLoadedShown => 'All loaded events shown';

  @override
  String get inlineEventLoadMoreEvents => 'Load more events';

  @override
  String inlineEventShownLoaded(int shown, int loaded) {
    return '$shown shown - $loaded loaded';
  }

  @override
  String get inlineEventNow => 'Now';

  @override
  String get chatDeleteConversationTitle => 'Delete conversation?';

  @override
  String get chatClearHistoryTitle => 'Clear chat history?';

  @override
  String get eventCancelTitle => 'Cancel Event';

  @override
  String get eventCancelReasonOptional => 'Reason (optional)';

  @override
  String get eventKeepEvent => 'Keep Event';

  @override
  String get eventDeleteTitle => 'Delete Event';

  @override
  String eventDeleteConfirm(String eventTitle) {
    return 'Are you sure you want to delete \"$eventTitle\"?';
  }

  @override
  String get eventAttendees => 'Attendees';

  @override
  String eventAttendeesCount(int count) {
    return 'Attendees ($count)';
  }

  @override
  String get eventNoAttendeesYet => 'No attendees yet';

  @override
  String get eventAttendeesFailedOpenChat =>
      'Failed to open chat. Please try again.';

  @override
  String get eventAttendeesFailedLoad => 'Failed to load attendees';

  @override
  String get myLocation => 'My Location';

  @override
  String get changeSignInAccount => 'Change sign-in account';

  @override
  String get changeGoogleAccount => 'Change Google account';

  @override
  String get changeAppleAccount => 'Change Apple account';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get clearAddress => 'Clear address';

  @override
  String get clearPhoneNumber => 'Clear phone number';

  @override
  String get openInMaps => 'Open in maps';

  @override
  String get appTitle => 'SportConnect';

  @override
  String get onboardingRunningEvents => 'Running events';

  @override
  String get onboardingDriveEarn => 'Drive & earn';

  @override
  String get onboardingPickupPlanning => 'Pickup planning';

  @override
  String get onboardingTrustedRides => 'Trusted rides';

  @override
  String get onboardingFindRideTitle => 'Find a ride to your race';

  @override
  String get onboardingOfferSeatsTitle => 'Offer seats and earn';

  @override
  String get onboardingPlanRouteTitle => 'Plan the route together';

  @override
  String get onboardingConnectGoTitle => 'Connect safely and go';

  @override
  String get onboardingFindRideDescription =>
      'Join runners heading to the same event and arrive without the stress.';

  @override
  String get onboardingOfferSeatsDescription =>
      'Driving to a race? Share your empty seats and earn from the trip.';

  @override
  String get onboardingPlanRouteDescription =>
      'Set pickup points, confirm timing, and follow a clear route to the event.';

  @override
  String get onboardingConnectGoDescription =>
      'Chat with verified runners, confirm the ride, and travel with confidence.';

  @override
  String get onboardingFindYourRideTitle => 'Find Your\\nRide';

  @override
  String get onboardingMatchWithRunners => 'Match with Runners';

  @override
  String get onboardingFindYourRideDescription =>
      'Instantly match with runners heading the same direction. Share a car, save money, and arrive at the start-line together.';

  @override
  String get onboardingSmartMatching => 'Smart Matching';

  @override
  String get onboardingNearbyRunners => 'Nearby Runners';

  @override
  String get onboardingPaceFilters => 'Pace Filters';

  @override
  String get onboardingOfferASeatTitle => 'Offer a\\nSeat';

  @override
  String get onboardingDriveSplitCosts => 'Drive & Split Costs';

  @override
  String get onboardingOfferASeatDescription =>
      'Got a car? Offer spare seats to fellow runners. Cover fuel costs and build bonds with your local running community.';

  @override
  String get onboardingCostSplitting => 'Cost Splitting';

  @override
  String get onboardingSeatControl => 'Seat Control';

  @override
  String get onboardingDriverRating => 'Driver Rating';

  @override
  String get onboardingPlanYourRouteTitle => 'Plan Your\\nRoute';

  @override
  String get onboardingSmartRouteSync => 'Smart Route Sync';

  @override
  String get onboardingPlanYourRouteDescription =>
      'Set your pickup point, race venue, or training ground. SportConnect syncs detours automatically to keep everyone on schedule.';

  @override
  String get onboardingLiveRouting => 'Live Routing';

  @override
  String get onboardingDetourSync => 'Detour Sync';

  @override
  String get onboardingEventZones => 'Event Zones';

  @override
  String get onboardingConnectGoModelTitle => 'Connect\\n& Go';

  @override
  String get onboardingCommunityYouTrust => 'Community You Trust';

  @override
  String get onboardingConnectGoModelDescription =>
      'Verified runner profiles, in-app chat, and real-time tracking keep every carpool safe, social, and on time.';

  @override
  String get onboardingVerifiedProfiles => 'Verified Profiles';

  @override
  String get onboardingInAppChat => 'In-App Chat';

  @override
  String get onboardingLiveTracking => 'Live Tracking';

  @override
  String failedToSaveProgress(Object error) {
    return 'Failed to save progress: $error';
  }

  @override
  String get searchRides => 'Search Rides';

  @override
  String get emptyNoRidesSubtitle =>
      'Try adjusting your filters or search for a different route';

  @override
  String get emptyNoEventsSubtitle =>
      'Create an event to bring your group together';

  @override
  String get emptyNoMessagesSubtitle =>
      'Start a conversation by booking a ride or joining an event';

  @override
  String get emptyNoNotificationsSubtitle =>
      'You\'ll see new notifications here';

  @override
  String get emptyNoReviewsSubtitle =>
      'Reviews will appear after completed rides';

  @override
  String get emptyNoVehiclesSubtitle => 'Add a vehicle to start offering rides';

  @override
  String get emptyNoBookingsSubtitle => 'Your ride bookings will appear here';

  @override
  String get emptyNoResultsSubtitle => 'Try different search terms or filters';

  @override
  String get reachedYourDestination => 'You\'ve reached your destination';

  @override
  String notificationRideBookingRequestBody(
    String fromUserName,
    String rideName,
  ) {
    return '$fromUserName wants to join your ride \"$rideName\"';
  }

  @override
  String notificationRideBookingAcceptedBody(
    String driverName,
    String rideName,
  ) {
    return '$driverName accepted your request for \"$rideName\"';
  }

  @override
  String notificationRideBookingDeclinedWithReasonBody(
    String driverName,
    String rideName,
    String reason,
  ) {
    return '$driverName declined your request for \"$rideName\": $reason';
  }

  @override
  String notificationRideBookingDeclinedBody(
    String driverName,
    String rideName,
  ) {
    return '$driverName declined your request for \"$rideName\"';
  }

  @override
  String notificationRideCancelledWithReasonBody(
    String driverName,
    String rideName,
    String reason,
  ) {
    return '$driverName cancelled the ride \"$rideName\": $reason';
  }

  @override
  String notificationRideCancelledBody(String driverName, String rideName) {
    return '$driverName cancelled the ride \"$rideName\"';
  }

  @override
  String notificationNewMessageBody(
    String fromUserName,
    String messagePreview,
  ) {
    return '$fromUserName: $messagePreview';
  }

  @override
  String notificationAchievementBody(
    String achievementName,
    String achievementDescription,
  ) {
    return 'You earned \"$achievementName\" - $achievementDescription';
  }

  @override
  String notificationLevelUpBody(int newLevel) {
    return 'Congratulations! You reached Level $newLevel. Keep riding!';
  }

  @override
  String notificationDriverArrivedBody(String driverName, String rideName) {
    return '$driverName has arrived at your pickup for $rideName. Head out now!';
  }

  @override
  String notificationDriverArrivingDestinationBody(
    String driverName,
    String rideName,
  ) {
    return '$driverName is arriving at the destination for $rideName.';
  }

  @override
  String notificationEventCancelledWithReasonBody(
    String organizerName,
    String eventTitle,
    String reason,
  ) {
    return '$organizerName cancelled \"$eventTitle\": $reason';
  }

  @override
  String notificationEventCancelledBody(
    String organizerName,
    String eventTitle,
  ) {
    return '$organizerName cancelled \"$eventTitle\"';
  }

  @override
  String get notificationRideReferenceType => 'ride';

  @override
  String get notificationChatReferenceType => 'chat';

  @override
  String get notificationEventReferenceType => 'event';

  @override
  String get sharedLocation => 'Shared location';

  @override
  String get rideAttachment => 'Ride attachment';

  @override
  String get systemMessage => 'System message';

  @override
  String get imageMessage => 'Image';

  @override
  String get manual => 'Manual';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get waze => 'Waze';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get locationData => 'Location Data';

  @override
  String get paymentData => 'Payment Data';

  @override
  String get usageData => 'Usage Data';

  @override
  String get yourRights => 'Your Rights';

  @override
  String get sportconnectDescription =>
      'SportConnect is a carpooling and rideshare platform designed for sports enthusiasts. Share rides to games, tournaments, and training sessions while saving money, reducing emissions, and connecting with fellow athletes.';

  @override
  String get nearMe => 'Near me';

  @override
  String withinValueKm(Object value) {
    return 'Within $value km';
  }

  @override
  String get purchasesRestoredSuccessfully =>
      'Purchases restored successfully.';

  @override
  String get couldNotRestorePurchases => 'Could not restore purchases.';

  @override
  String get personalInformationDescription =>
      'We collect your name, email, phone number, and profile photo to create and manage your account.';

  @override
  String get locationDataDescription =>
      'We process your location to match rides, calculate routes, and show nearby destinations.';

  @override
  String get paymentDataDescription =>
      'Payment information is processed securely by Stripe. We do not store your full card details.';

  @override
  String get usageDataDescription =>
      'We collect crash reports and usage analytics. This data is anonymized.';

  @override
  String get yourRightsDescription =>
      'You can access, export, correct, or delete your data at any time.';

  @override
  String get business_days_1_to_2 => 'Business Days 1 To 2';

  @override
  String get two_days_left => 'Two Days Left';

  @override
  String get helpCenterGettingStartedCreateAccountQuestion =>
      'Help Center Getting Started Create Account Question';

  @override
  String get helpCenterGettingStartedCreateAccountAnswer =>
      'Help Center Getting Started Create Account Answer';

  @override
  String get helpCenterGettingStartedSwitchRoleQuestion =>
      'Help Center Getting Started Switch Role Question';

  @override
  String get helpCenterGettingStartedSwitchRoleAnswer =>
      'Help Center Getting Started Switch Role Answer';

  @override
  String get helpCenterGettingStartedFreeQuestion =>
      'Help Center Getting Started Free Question';

  @override
  String get helpCenterGettingStartedFreeAnswer =>
      'Help Center Getting Started Free Answer';

  @override
  String get helpCenterRidesBookingQuestion =>
      'Help Center Rides Booking Question';

  @override
  String get helpCenterRidesBookingAnswer => 'Help Center Rides Booking Answer';

  @override
  String get helpCenterRidesCancelAnswer => 'Help Center Rides Cancel Answer';

  @override
  String get helpCenterRidesMatchingQuestion =>
      'Help Center Rides Matching Question';

  @override
  String get helpCenterRidesMatchingAnswer =>
      'Help Center Rides Matching Answer';

  @override
  String get helpCenterRidesLateQuestion => 'Help Center Rides Late Question';

  @override
  String get helpCenterRidesLateAnswer => 'Help Center Rides Late Answer';

  @override
  String get helpCenterPaymentsQuestion => 'Help Center Payments Question';

  @override
  String get helpCenterPaymentsAnswer => 'Help Center Payments Answer';

  @override
  String get helpCenterPayoutsQuestion => 'Help Center Payouts Question';

  @override
  String get helpCenterPayoutsAnswer => 'Help Center Payouts Answer';

  @override
  String get helpCenterFeesQuestion => 'Help Center Fees Question';

  @override
  String get helpCenterFeesAnswer => 'Help Center Fees Answer';

  @override
  String get helpCenterSafetyQuestion => 'Help Center Safety Question';

  @override
  String get helpCenterSafetyAnswer => 'Help Center Safety Answer';

  @override
  String get helpCenterSafetyReportQuestion =>
      'Help Center Safety Report Question';

  @override
  String get helpCenterSafetyReportAnswer => 'Help Center Safety Report Answer';

  @override
  String get helpCenterSafetyShareQuestion =>
      'Help Center Safety Share Question';

  @override
  String get helpCenterSafetyShareAnswer => 'Help Center Safety Share Answer';

  @override
  String get helpCenterAccountVerifyQuestion =>
      'Help Center Account Verify Question';

  @override
  String get helpCenterAccountVerifyAnswer =>
      'Help Center Account Verify Answer';

  @override
  String get helpCenterAccountDeleteQuestion =>
      'Help Center Account Delete Question';

  @override
  String get helpCenterAccountDeleteAnswer =>
      'Help Center Account Delete Answer';

  @override
  String get helpCenterAccountEmailQuestion =>
      'Help Center Account Email Question';

  @override
  String get helpCenterAccountEmailAnswer => 'Help Center Account Email Answer';

  @override
  String get articles => 'Articles';

  @override
  String get tryDifferentKeywordsOrContactSupport =>
      'Try Different Keywords Or Contact Support';

  @override
  String get helpCenterRidesCancelQuestion =>
      'Help Center Rides Cancel Question';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminAccessRequired => 'Admin access required';

  @override
  String adminAccessCheckFailed(String error) {
    return 'Access check failed: $error';
  }

  @override
  String get noRefundRequests => 'No refund requests';

  @override
  String get noDisputes => 'No disputes';

  @override
  String get noSupportTickets => 'No support tickets';

  @override
  String get refundsTab => 'Refunds';

  @override
  String get disputesTab => 'Disputes';

  @override
  String get supportTab => 'Support';

  @override
  String get stripeEurBalance => 'EUR balance';

  @override
  String get badgeFirstRide => 'First Ride';

  @override
  String get badgeFirstRideDesc => 'Complete your first ride';

  @override
  String get badgeRoadWarrior => 'Road Warrior';

  @override
  String get badgeRoadWarriorDesc => 'Complete 10 rides';

  @override
  String get badgeEcoHero => 'Eco Hero';

  @override
  String get badgeEcoHeroDesc => 'Save 50 kg of CO₂';

  @override
  String get badgeSocialButterfly => 'Social Butterfly';

  @override
  String get badgeSocialButterflyDesc => 'Connect with 10 riders';

  @override
  String get badgeRoadTripper => 'Road Tripper';

  @override
  String get badgeRoadTripperDesc => 'Travel 50 km total';

  @override
  String get badgeSpeedDemon => 'Speed Demon';

  @override
  String get badgeSpeedDemonDesc => 'Maintain a 7-day streak';

  @override
  String adminCouldNotLoadIssues(String error) {
    return 'Could not load issues: $error';
  }

  @override
  String get adminDashboardSettingsSubtitle =>
      'Review refunds, disputes, and support tickets';

  @override
  String get adminApproveRefund => 'Approve refund';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminRefund => 'Refund';

  @override
  String get adminResolve => 'Resolve';

  @override
  String get actionUpdated => 'Updated';

  @override
  String get yearlyMonthlyEstimate => '≈ €4.17/mo';

  @override
  String get premiumSubscribeHeroSubtitle =>
      'Everything you need to ride smarter, together.';

  @override
  String get alreadyPremiumTitle => 'You\'re already a member';

  @override
  String get alreadyPremiumSubtitle =>
      'Your SportConnect Premium subscription is active. Enjoy all premium features.';

  @override
  String get backToApp => 'Back to App';

  @override
  String get chatChipImAtPickup => 'I\'m at pickup';

  @override
  String get chatChipRunningLate => 'Running late';

  @override
  String get pleaseTryAgainLater => 'Please try again later.';

  @override
  String get routeDistanceFallback => 'Route distance';

  @override
  String estimatedMinutes(int minutes) {
    return '$minutes min estimated';
  }

  @override
  String seatsLeftCount(int count) {
    return '$count seats left';
  }

  @override
  String get bookingInProgress => 'Booking...';

  @override
  String get sendRequest => 'Send request';

  @override
  String rideSharedDistanceSummary(String distance) {
    return '$distance km shared together';
  }

  @override
  String rideCarpooledWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Carpooled with $count people',
      one: 'Carpooled with 1 person',
    );
    return '$_temp0';
  }

  @override
  String get avgSpeedLabel => 'Avg Speed';

  @override
  String avgSpeedKmhValue(String value) {
    return '$value km/h';
  }

  @override
  String baseFareSeatCount(int count) {
    return 'Base Fare ($count seats)';
  }

  @override
  String baseFareSeatsByPrice(int count, String price) {
    return 'Base Fare ($count seats × $price)';
  }

  @override
  String serviceFeeWithRate(String rate) {
    return 'Service Fee ($rate)';
  }

  @override
  String rideCompletionDriverRating(String value) {
    return '$value rating';
  }

  @override
  String get billingPeriodMonthShort => '/mo';

  @override
  String get billingPeriodYearShort => '/yr';

  @override
  String get fallbackMonthlyPrice => '€4.99';

  @override
  String get fallbackYearlyPrice => '€49.99';

  @override
  String yearlyMonthlyAtPrice(String price) {
    return '≈ $price/mo';
  }

  @override
  String get premiumRenewsUntilCancelled =>
      'Subscription renews automatically until cancelled. Cancel anytime in App Store Settings.';

  @override
  String premiumRenewsEachPeriodAtPrice(String period, String price) {
    return 'Automatically renews each $period at $price until cancelled. Cancel anytime in App Store Settings.';
  }

  @override
  String get cancellationReasonBannerMessage =>
      'Please let us know why you\'re cancelling so we can improve our service.';

  @override
  String get cancelReasonChangeOfPlansTitle => 'Change of plans';

  @override
  String get cancelReasonChangeOfPlansDescription =>
      'My schedule changed and I can no longer make this ride.';

  @override
  String get cancelReasonFoundAnotherRideTitle => 'Found another ride';

  @override
  String get cancelReasonFoundAnotherRideDescription =>
      'I found a more convenient ride option.';

  @override
  String get cancelReasonPriceTooHighTitle => 'Price too high';

  @override
  String get cancelReasonPriceTooHighDescription =>
      'The ride cost is more than I expected.';

  @override
  String get cancelReasonSafetyConcernTitle => 'Safety concern';

  @override
  String get cancelReasonSafetyConcernDescription =>
      'I have concerns about the safety of this ride.';

  @override
  String get cancelReasonDriverNotRespondingTitle => 'Driver not responding';

  @override
  String get cancelReasonDriverNotRespondingDescription =>
      'The driver is not responding to messages.';

  @override
  String get cancelReasonIncorrectDetailsTitle => 'Incorrect details';

  @override
  String get cancelReasonIncorrectDetailsDescription =>
      'The ride details are incorrect or have changed.';

  @override
  String get cancelReasonEmergencyTitle => 'Emergency';

  @override
  String get cancelReasonEmergencyDescription =>
      'I have an unexpected emergency.';

  @override
  String get cancelReasonOtherTitle => 'Other';

  @override
  String get cancelReasonOtherDescription => 'Another reason not listed above.';

  @override
  String get cancelReasonVehicleIssueTitle => 'Vehicle issue';

  @override
  String get cancelReasonVehicleIssueDescription =>
      'My vehicle has a mechanical problem or is unavailable.';

  @override
  String get cancelReasonPassengerNotAtPickupTitle => 'Passenger not at pickup';

  @override
  String get cancelReasonPassengerNotAtPickupDescription =>
      'The passenger was not at the agreed pickup location.';

  @override
  String get cancelReasonPassengerNotRespondingTitle =>
      'Passenger not responding';

  @override
  String get cancelReasonPassengerNotRespondingDescription =>
      'The passenger is not responding to messages.';

  @override
  String get cancelReasonRouteIssueTitle => 'Route issue';

  @override
  String get cancelReasonRouteIssueDescription =>
      'There is a road closure or route problem.';

  @override
  String pleaseFixFields(String fields) {
    return 'Please fix: $fields';
  }

  @override
  String get nameTooLongError => 'Name is too long';

  @override
  String get ridingDetails => 'Riding Details';

  @override
  String get riderOnboardingFormLabel => 'Rider onboarding form';

  @override
  String get payoutStepInitiated => 'Initiated';

  @override
  String get payoutStepCouldNotComplete => 'Could not complete';

  @override
  String get payoutStepPreparingTransfer => 'Stripe is preparing your transfer';

  @override
  String payoutStepExpected(String date) {
    return 'Expected $date';
  }

  @override
  String get payoutStepOnItsWayToYourBank => 'On its way to your bank';

  @override
  String get payoutStepWaitingForProcessing =>
      'Waiting for processing to complete';

  @override
  String get payoutStepDepositedToYourAccount => 'Deposited to your account';

  @override
  String get payoutMethodInstantDescription => 'Instant (usually minutes)';

  @override
  String get payoutMethodStandardDescription => 'Standard (1–3 business days)';

  @override
  String get payoutDestinationLabel => 'Destination';

  @override
  String onboardingStepCount(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingCreateAccountPrompt =>
      'Create your free account to find rides to your next sporting event.';

  @override
  String get onboardingRunningEventLabel => 'RUNNING EVENT';

  @override
  String get onboardingRideBadgeOpen => 'OPEN';

  @override
  String get onboardingRideBadgeSet => 'SET';

  @override
  String get onboardingSharedLabel => 'Shared';

  @override
  String get onboardingDriverRouteLabel => 'Driver route';

  @override
  String get onboardingSharedArrivalLabel => 'Shared arrival';

  @override
  String get onboardingEventLabel => 'Event';

  @override
  String get identityAndRoleStep => 'Identity & Role';

  @override
  String get dayLabel => 'Day';

  @override
  String get monthLabel => 'Month';

  @override
  String get passwordMinLengthError => 'Password must be at least 8 characters';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get supportSubjectRequired => 'Please enter a subject';

  @override
  String get supportSubjectMinLength => 'Subject must be at least 3 characters';

  @override
  String get supportMessageRequired => 'Please describe your issue';

  @override
  String get supportMessageMinLength => 'Please provide at least 10 characters';

  @override
  String get thisWeekend => 'This Weekend';

  @override
  String get highestPrice => 'Highest price';

  @override
  String get badgePerfectScore => 'Perfect Score';

  @override
  String get badgePerfectScoreDesc => 'Maintain a 5-star rating';

  @override
  String get badgeRoadMaster => 'Road Master';

  @override
  String get badgeRoadMasterDesc => 'Complete 100 rides';

  @override
  String get badgeNightOwl => 'Night Owl';

  @override
  String get badgeNightOwlDesc => 'Complete 20 night rides';

  @override
  String get badgeEarlyBird => 'Early Bird';

  @override
  String get badgeEarlyBirdDesc => 'Complete 20 morning rides';

  @override
  String get badgeMarathonDriver => 'Marathon Driver';

  @override
  String get badgeMarathonDriverDesc => 'Travel 1000 km total';

  @override
  String get badgeVerifiedPro => 'Verified Pro';

  @override
  String get badgeVerifiedProDesc => 'Get identity verified';

  @override
  String get challengeDailyCommuter => 'Daily Commuter';

  @override
  String get challengeDailyCommuterDesc => 'Complete 1 ride today';

  @override
  String get challengeWeekWarrior => 'Week Warrior';

  @override
  String get challengeWeekWarriorDesc => 'Complete 5 rides this week';

  @override
  String get challengeStreakKeeper => 'Streak Keeper';

  @override
  String get challengeStreakKeeperDesc => 'Maintain a 3-day streak';

  @override
  String get challengeExplorer => 'Explorer';

  @override
  String get challengeExplorerDesc => 'Try 3 new routes this month';

  @override
  String get challengeSocialRider => 'Social Rider';

  @override
  String get challengeSocialRiderDesc => 'Rate 5 drivers this week';

  @override
  String get challengeEcoWarrior => 'Eco Warrior';

  @override
  String get challengeEcoWarriorDesc => 'Share 3 rides today';

  @override
  String challengeResetsInHours(String value) {
    return 'Resets in ${value}h';
  }

  @override
  String challengeResetsInDays(String value) {
    return 'Resets in ${value}d';
  }

  @override
  String get challengeKeepGoing => 'Keep going!';

  @override
  String get phoneNumberHint => 'Enter your phone number';

  @override
  String get phoneNumberSupportNoLeadingZero =>
      'After +33, enter the number without the leading 0.';

  @override
  String phoneNumberDigitsCount(int current, int total) {
    return '$current of $total digits after +33';
  }

  @override
  String get phoneNumberSupportPrivacy =>
      'Used only for ride coordination and safety.';

  @override
  String get profilePhotoCameraPermission =>
      'Camera access is needed to take a new profile photo.';

  @override
  String get profilePhotoLibraryPermission =>
      'Access to your photo library is needed to update your profile picture.';

  @override
  String get preferNotToSay => 'Prefer not to say';

  @override
  String get addressSelected => 'Address selected';

  @override
  String get noPointSelected => 'No point selected';

  @override
  String get tapMapToChoosePoint => 'Tap the map to choose a point';

  @override
  String get locationPreviewReady => 'Location preview is ready below';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get paymentBreakdown => 'Payment Breakdown';

  @override
  String get baseFare => 'Base Fare';

  @override
  String get processingFee => 'Processing Fee';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get refundReason => 'Refund Reason';

  @override
  String distanceKmValue(String value) {
    return '$value km';
  }

  @override
  String get withdrawableBalanceInfo =>
      'Withdrawable Now is the part of your Stripe instant-available balance backed by completed rides.\n\nPaid rides that are not completed yet stay blocked for withdrawal.\n\nProcessing is money that has reached Stripe but is not yet eligible for instant withdrawal.';

  @override
  String get withdrawableNowLabel => 'Withdrawable now';

  @override
  String get completedRideEarningsLabel => 'Completed ride earnings';

  @override
  String get payoutsAlreadyRequestedLabel => 'Payouts already requested';

  @override
  String get paidRidesAwaitingCompletionLabel =>
      'Paid rides awaiting completion';

  @override
  String get stripeInstantAvailableLabel => 'Stripe instant available';

  @override
  String get stripeBalanceTotalLabel => 'Stripe balance total';

  @override
  String get tripEarningsRecordedLabel => 'Trip earnings recorded';

  @override
  String get withdrawableNowFootnote =>
      'Withdrawable Now only includes completed rides. Paid rides still in progress unlock after the driver completes the ride.';

  @override
  String rideCompletionPendingAmount(String amount) {
    return ' €$amount is waiting for ride completion.';
  }

  @override
  String processingBalancePendingAmount(String amount) {
    return ' €$amount is still processing.';
  }

  @override
  String get noCompletedRideBalanceAvailableYet =>
      'No completed ride balance available yet.';

  @override
  String get receiptNumberLabel => 'Receipt #';

  @override
  String get routeDeviationDetected => 'Route Deviation Detected';

  @override
  String driverOffRouteEta(Object distance, int minutes) {
    return 'Driver is $distance off route — new ETA ~$minutes min';
  }

  @override
  String driverOffPlannedRoute(Object distance) {
    return 'Driver is $distance off the planned route';
  }

  @override
  String relativeMinutesShort(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min',
      one: '$minutes min',
    );
    return '$_temp0';
  }

  @override
  String relativeHoursShort(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '${hours}h',
      one: '${hours}h',
    );
    return '$_temp0';
  }

  @override
  String relativeDaysShort(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '${days}d',
      one: '${days}d',
    );
    return '$_temp0';
  }

  @override
  String get refundReviewLabel => 'Refund review';

  @override
  String get refundIfEligibleLineOne => 'If';

  @override
  String get refundIfEligibleLineTwo => 'eligible';

  @override
  String get endsLabel => 'Ends';

  @override
  String get setEndDate => 'Set end date';
}
