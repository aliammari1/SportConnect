import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get navRides;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications for important updates'**
  String get settingsPushNotificationsDesc;

  /// No description provided for @settingsRideReminders.
  ///
  /// In en, this message translates to:
  /// **'Ride Reminders'**
  String get settingsRideReminders;

  /// No description provided for @settingsRideRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get reminded about upcoming rides'**
  String get settingsRideRemindersDesc;

  /// No description provided for @settingsChatMessages.
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get settingsChatMessages;

  /// No description provided for @settingsChatMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for new messages'**
  String get settingsChatMessagesDesc;

  /// No description provided for @settingsMarketingTips.
  ///
  /// In en, this message translates to:
  /// **'Marketing & Tips'**
  String get settingsMarketingTips;

  /// No description provided for @settingsMarketingTipsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive tips and promotional offers'**
  String get settingsMarketingTipsDesc;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get settingsDarkModeDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsDistanceUnit.
  ///
  /// In en, this message translates to:
  /// **'Distance Unit'**
  String get settingsDistanceUnit;

  /// No description provided for @settingsDistanceUnitDesc.
  ///
  /// In en, this message translates to:
  /// **'Preferred distance measurement'**
  String get settingsDistanceUnitDesc;

  /// No description provided for @settingsPrivacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Safety'**
  String get settingsPrivacySafety;

  /// No description provided for @settingsPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public Profile'**
  String get settingsPublicProfile;

  /// No description provided for @settingsPublicProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow others to see your profile'**
  String get settingsPublicProfileDesc;

  /// No description provided for @settingsShowLocation.
  ///
  /// In en, this message translates to:
  /// **'Show Location'**
  String get settingsShowLocation;

  /// No description provided for @settingsShowLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your live location during rides'**
  String get settingsShowLocationDesc;

  /// No description provided for @settingsAutoAcceptRides.
  ///
  /// In en, this message translates to:
  /// **'Auto-Accept Rides'**
  String get settingsAutoAcceptRides;

  /// No description provided for @settingsAutoAcceptRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically accept ride requests'**
  String get settingsAutoAcceptRidesDesc;

  /// No description provided for @settingsBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get settingsBlockedUsers;

  /// No description provided for @settingsBlockedUsersDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage blocked users'**
  String get settingsBlockedUsersDesc;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsEditProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your profile information'**
  String get settingsEditProfileDesc;

  /// No description provided for @settingsPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get settingsPaymentMethods;

  /// No description provided for @settingsPaymentMethodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your payment options'**
  String get settingsPaymentMethodsDesc;

  /// No description provided for @managePaymentMethodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add, remove, or update saved payment methods for faster checkout.'**
  String get managePaymentMethodsDesc;

  /// No description provided for @selectedPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Selected Payment Method'**
  String get selectedPaymentMethod;

  /// No description provided for @changePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Change Payment Method'**
  String get changePaymentMethod;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @settingsVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get settingsVerifyAccount;

  /// No description provided for @settingsVerifyAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete identity verification'**
  String get settingsVerifyAccountDesc;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get settingsSupport;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsHelpCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get settingsHelpCenterDesc;

  /// No description provided for @settingsReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get settingsReportProblem;

  /// No description provided for @settingsReportProblemDesc.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or issues'**
  String get settingsReportProblemDesc;

  /// No description provided for @settingsTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTermsConditions;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get settingsAboutDesc;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingsLogoutDesc;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get settingsDeleteAccountDesc;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input. Please check your entry.'**
  String get errorInvalidInput;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get errorPermissionDenied;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnexpected;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Text from Text in app_router.dart
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Text from Text in app_router.dart
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Text from Text in feature_discovery_service.dart
  ///
  /// In en, this message translates to:
  /// **'Step {value1} of {value2}'**
  String stepValueOfValue(Object value1, Object value2);

  /// Text from Text in feature_discovery_service.dart
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get skipTour;

  /// Text from _buildMenuButton.label in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// Text from _buildMenuButton.label in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme Playground'**
  String get themePlayground;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get colorScheme;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Surface Blend: {value}%'**
  String surfaceBlendValue(Object value);

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Use Material 3'**
  String get useMaterial3;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Component Preview'**
  String get componentPreview;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get elevated;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get filled;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Outlined'**
  String get outlined;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// Text from InputDecoration.labelText in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Text Field'**
  String get textField;

  /// Text from InputDecoration.hintText in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Enter text...'**
  String get enterText;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Card Title'**
  String get cardTitle;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Card subtitle with description'**
  String get cardSubtitleWithDescription;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Chip 1'**
  String get chip1;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get colorPalette;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'primary'**
  String get primary;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get error;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Copy Theme Code'**
  String get copyThemeCode;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Apply Theme'**
  String get applyTheme;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme code copied to logs!'**
  String get themeCodeCopiedToLogs;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme \"{value}\" applied!'**
  String themeValueApplied(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'LVL {value}'**
  String lvlValue(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} / {value2} XP'**
  String valueValueXp(Object value1, Object value2);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String value(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String value2(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'#{value}'**
  String value3(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} XP'**
  String valueXp(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}/{value2}'**
  String valueValue(Object value1, Object value2);

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'standard'**
  String get standard;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard2;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'terrain'**
  String get terrain;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get terrain2;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get dark;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get light;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'humanitarian'**
  String get humanitarian;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Humanitarian'**
  String get humanitarian2;

  /// Text from InputDecoration.hintText in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Search address, city, or place...'**
  String get searchAddressCityOrPlace;

  /// Text from Text in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCities;

  /// Text from Text in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// Text from Text in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Nearby Places'**
  String get nearbyPlaces;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Find useful spots along your route'**
  String get findUsefulSpotsAlongYour;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Search Radius'**
  String get searchRadius;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Select a category to search'**
  String get selectACategoryToSearch;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Tap on any category above to find nearby places'**
  String get tapOnAnyCategoryAbove;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Try increasing the search radius'**
  String get tryIncreasingTheSearchRadius;

  /// Text from Text in premium_avatar.dart
  ///
  /// In en, this message translates to:
  /// **'Lv.{value}'**
  String lvValue(Object value);

  /// Text from Text in premium_avatar.dart
  ///
  /// In en, this message translates to:
  /// **'+{value}'**
  String value4(Object value);

  /// Text from Text in premium_navigation.dart
  ///
  /// In en, this message translates to:
  /// **'99+'**
  String get text99;

  /// Text from Text in premium_navigation.dart
  ///
  /// In en, this message translates to:
  /// **'9+'**
  String get text9;

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} rides • {value2}'**
  String valueRidesValue(Object value1, Object value2);

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value} €'**
  String value5(Object value);

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value} seats left'**
  String valueSeatsLeft(Object value);

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'Fully booked'**
  String get fullyBooked;

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value} seats'**
  String valueSeats(Object value);

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error saving vehicle: {value}'**
  String errorSavingVehicleValue(Object value);

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Setup'**
  String get driverSetup;

  /// Text from _buildStepIndicator in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Text from _buildStepIndicator in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get payouts;

  /// Text from _buildStepHeader.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Your Vehicle'**
  String get addYourVehicle;

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// Text from _buildStepHeader.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Setup Payouts'**
  String get setupPayouts;

  /// Text from _buildBenefitItem.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Secure Payments'**
  String get securePayments;

  /// Text from _buildBenefitItem.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Fast Transfers'**
  String get fastTransfers;

  /// Text from _buildBenefitItem.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Easy Tracking'**
  String get easyTracking;

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Skip for now, I\'ll set this up later'**
  String get skipForNowILl;

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You can still offer rides without setting up payouts, but you won\'t be able to receive payments until you complete this step.'**
  String get youCanStillOfferRides;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'SportConnect'**
  String get sportconnect;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your running journey'**
  String get signInToContinueYour;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get donTHaveAnAccount;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get enterYourEmailAddressAnd;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get passwordResetEmailSentCheck;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service'**
  String get pleaseAgreeToTheTerms;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Join our community of eco-friendly riders'**
  String get joinOurCommunityOfEco;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Welcome Bonus'**
  String get welcomeBonus;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get 100 XP when you complete your profile!'**
  String get get100XpWhenYou;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I want to:'**
  String get iWantTo;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find rides'**
  String get findRides;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer rides'**
  String get offerRides;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please select a role to continue'**
  String get pleaseSelectARoleTo;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {value}'**
  String errorValue(Object value);

  /// Text from _buildRoleCard.title in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I\'m a Rider'**
  String get iMARider;

  /// Text from _buildRoleCard.title in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I\'m a Driver'**
  String get iMADriver;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How will you use SportConnect?'**
  String get howWillYouUseSportconnect;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Choose your role to get started.\nThis will customize your experience.'**
  String get chooseYourRoleToGet;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🎉'**
  String get text2;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Join 10,000+ eco-riders'**
  String get join10000EcoRiders;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get 100 XP welcome bonus!'**
  String get get100XpWelcomeBonus;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get orSignUpWith;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Strong Password Tips'**
  String get strongPasswordTips;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Use 8+ characters with letters, numbers & symbols'**
  String get use8CharactersWithLetters;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Interests (Optional)'**
  String get yourInterestsOptional;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select sports you\'re interested in'**
  String get selectSportsYouReInterested;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a Profile Photo'**
  String get addAProfilePhoto;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This helps others recognize you'**
  String get thisHelpsOthersRecognizeYou;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ready to Join!'**
  String get readyToJoin;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Email: {value}'**
  String emailValue(Object value);

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Role: {value}'**
  String roleValue(Object value);

  /// Text from Text in splash_screen.dart
  ///
  /// In en, this message translates to:
  /// **'CARPOOLING FOR RUNNERS'**
  String get carpoolingForRunners;

  /// Text from Text in splash_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share rides. Run together.\nGo further.'**
  String get shareRidesRunTogetherGo;

  /// Text from Text in splash_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer Ride'**
  String get offerRide;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accepting ride requests'**
  String get acceptingRideRequests;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tap to go online and start earning'**
  String get tapToGoOnlineAnd;

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load status'**
  String get failedToLoadStatus;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaySEarnings;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'€{value}'**
  String value6(Object value);

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} rides'**
  String valueRides(Object value);

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load earnings'**
  String get failedToLoadEarnings;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Requests'**
  String get rideRequests;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Text from _buildEmptyState.title in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests'**
  String get failedToLoadRequests;

  /// Empty state title for accepted requests tab
  ///
  /// In en, this message translates to:
  /// **'No accepted requests yet'**
  String get noAcceptedRequestsYet;

  /// Empty state subtitle for accepted requests tab
  ///
  /// In en, this message translates to:
  /// **'Accepted ride requests will appear here'**
  String get acceptedRequestsWillAppearHere;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Upcoming Rides'**
  String get upcomingRides;

  /// Text from _buildEmptyState.title in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No upcoming rides'**
  String get noUpcomingRides;

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load rides'**
  String get failedToLoadRides;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get kNew;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} seat{value2}'**
  String valueSeatValue(Object value1, Object value2);

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} → {value2}'**
  String valueValue2(Object value1, Object value2);

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'earned'**
  String get earned;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get loadingRoute;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String valueKm(Object value);

  /// Text from _buildStatItem in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get rides;

  /// Text from _buildStatItem in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'seats'**
  String get seats;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// Text from _buildMapControl.tooltip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Hotspots'**
  String get hotspots;

  /// Text from _buildMapControl.tooltip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Nearby Rides'**
  String get nearbyRides;

  /// Text from _buildMapControl.tooltip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Follow Location'**
  String get followLocation;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String valueMin(Object value);

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Map Style'**
  String get mapStyle;

  /// Text from _buildStyleOption in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark2;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find a Ride'**
  String get findARide;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Text from InputDecoration.hintText in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'From where?'**
  String get fromWhere;

  /// Text from InputDecoration.hintText in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'To where?'**
  String get toWhere;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} available'**
  String valueAvailable(Object value);

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No rides available nearby'**
  String get noRidesAvailableNearby;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try expanding your search radius'**
  String get tryExpandingYourSearchRadius;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get pickupPoint;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Text from _buildSearchChip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get eco;

  /// Text from _buildSearchChip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocation;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Book This Ride'**
  String get bookThisRide;

  /// Text from _buildStatItem in quick_stats_card.dart
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ride;

  /// Text from _buildStatItem in quick_stats_card.dart
  ///
  /// In en, this message translates to:
  /// **'seat'**
  String get seat;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sending image...'**
  String get sendingImage;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to send image: {value}'**
  String failedToSendImageValue(Object value);

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to start call: {value}'**
  String failedToStartCallValue(Object value);

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search in Chat'**
  String get searchInChat;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mute Notifications'**
  String get muteNotifications;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notifications muted for this chat'**
  String get notificationsMutedForThisChat;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all messages? This action cannot be undone.'**
  String get areYouSureYouWant;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Chat cleared'**
  String get chatCleared;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get clear;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation'**
  String get sendAMessageToStart;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'typing'**
  String get typing;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Replying to {value}'**
  String replyingToValue(Object value);

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tap to open map'**
  String get tapToOpenMap;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get thisMessageWasDeleted;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get messageCopied;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// Text from InputDecoration.hintText in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationShared;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied to clipboard'**
  String get coordinatesCopiedToClipboard;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not open maps: {value}'**
  String couldNotOpenMapsValue(Object value);

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please login to view chats'**
  String get pleaseLoginToViewChats;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Text from _buildEmptyState.title in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// Text from _buildEmptyState.title in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No group chats'**
  String get noGroupChats;

  /// Text from _buildEmptyState.title in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No ride chats'**
  String get noRideChats;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get callHistory;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No call history'**
  String get noCallHistory;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCall;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **' • '**
  String get text3;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// Text from InputDecoration.hintText in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search users by name...'**
  String get searchUsersByName;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search for a user to start chatting'**
  String get searchForAUserTo;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get typeAtLeast2Characters;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{value}\"'**
  String noUsersFoundForValue(Object value);

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications?'**
  String get areYouSureYouWant2;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to clear notifications'**
  String get failedToClearNotifications;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view notifications'**
  String get pleaseSignInToView;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} new'**
  String valueNew(Object value);

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll2;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get youReAllCaughtUp;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not open chat: {value}'**
  String couldNotOpenChatValue(Object value);

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You\'re Ready to Run'**
  String get youReReadyToRun;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Create an account to start tracking your runs and connect with other runners.'**
  String get createAnAccountToStart;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get kContinue;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This week: {value} €'**
  String thisWeekValue(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earnings Overview'**
  String get earningsOverview;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Text from _buildEarningsBreakdownItem in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rides Earnings'**
  String get ridesEarnings;

  /// Text from _buildEarningsBreakdownItem in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tips & Bonuses'**
  String get tipsBonuses;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Environmental Impact'**
  String get environmentalImpact;

  /// Label for total distance driven stat
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} kg CO₂ saved'**
  String valueKgCoSaved(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Stripe Connected'**
  String get stripeConnected;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Set Up Payouts'**
  String get setUpPayouts;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Receive payments from riders'**
  String get receivePaymentsFromRiders;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete Verification'**
  String get completeVerification;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account'**
  String get connectYourBankAccount;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm Payout'**
  String get confirmPayout;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Withdraw {value} € to your connected bank account?'**
  String withdrawValueToYourConnected(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payout of {value} € initiated!'**
  String payoutOfValueInitiated(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payout failed. Please try again.'**
  String get payoutFailedPleaseTryAgain;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get failedToLoadTransactions;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}{value2} €'**
  String valueValue3(Object value1, Object value2);

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get Paid for Your Rides'**
  String get getPaidForYourRides;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account to receive payments directly from riders. Powered by Stripe for secure transactions.'**
  String get connectYourBankAccountTo;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Instant Payouts'**
  String get instantPayouts;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Secure & Protected'**
  String get secureProtected;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear Tracking'**
  String get clearTracking;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Low Fees'**
  String get lowFees;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You\'ll be redirected to Stripe to complete setup'**
  String get youLlBeRedirectedTo;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe'**
  String get connectStripe;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Stripe account connected successfully!'**
  String get stripeAccountConnectedSuccessfully;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading page: {value}'**
  String errorLoadingPageValue(Object value);

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view payment history'**
  String get pleaseSignInToView2;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Transactions'**
  String get yourTransactions;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPaymentsFound;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your payment history will appear here'**
  String get yourPaymentHistoryWillAppear;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Payment'**
  String get ridePayment;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get unknownDate;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} {value2}'**
  String valueValue4(Object value1, Object value2);

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats2;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'•••• {value}'**
  String value7(Object value);

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request Refund'**
  String get requestRefund;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading achievements'**
  String get errorLoadingAchievements;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Level {value1} - {value2}'**
  String levelValueValue(Object value1, Object value2);

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} XP'**
  String valueXp2(Object value);

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} XP to Level {value2}'**
  String valueXpToLevelValue(Object value1, Object value2);

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🏆'**
  String get text4;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🎯'**
  String get text5;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🚗'**
  String get text6;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🌍'**
  String get text7;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'kg CO₂'**
  String get kgCo;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'✓ Unlocked'**
  String get unlocked;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🔒 Locked'**
  String get locked;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}% Complete'**
  String valueComplete(Object value);

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🥈'**
  String get text8;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mike C.'**
  String get mikeC;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'11.2K'**
  String get text112k;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🥇'**
  String get text10;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sarah J.'**
  String get sarahJ;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'12.4K'**
  String get text124k;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🥉'**
  String get text11;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Emily D.'**
  String get emilyD;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'9.8K'**
  String get text98k;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Level {value}'**
  String levelValue(Object value);

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified Driver'**
  String get verifiedDriver;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get text12;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'0.0'**
  String get text00;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total Trips'**
  String get totalTrips;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} this month'**
  String valueThisMonth(Object value);

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} € this month'**
  String valueThisMonth2(Object value);

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'CO₂ Saved'**
  String get coSaved;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String valueKg(Object value);

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Since joining'**
  String get sinceJoining;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get avgRating;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Last 100 trips'**
  String get last100Trips;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'0 €'**
  String get text0;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get text0Kg;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rating Breakdown'**
  String get ratingBreakdown;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trips this week'**
  String get tripsThisWeek;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} trips'**
  String valueTrips(Object value);

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Settings'**
  String get driverSettings;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Preferences'**
  String get ridePreferences;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Auto-Accept Requests'**
  String get autoAcceptRequests;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Automatically accept ride requests that match your criteria'**
  String get automaticallyAcceptRideRequestsThat;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Instant Booking'**
  String get allowInstantBooking;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Let passengers book without waiting for approval'**
  String get letPassengersBookWithoutWaiting;

  /// Text from _buildSliderTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Maximum Pickup Distance'**
  String get maximumPickupDistance;

  /// Text from _buildSliderTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Only receive requests within this distance'**
  String get onlyReceiveRequestsWithinThis;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Settings'**
  String get paymentSettings;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Cash Payments'**
  String get acceptCashPayments;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to pay with cash'**
  String get allowPassengersToPayWith;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Card Payments'**
  String get acceptCardPayments;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to pay with card in-app'**
  String get allowPassengersToPayWith2;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payout Method'**
  String get payoutMethod;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Bank Account ending in 4532'**
  String get bankAccountEndingIn4532;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tax Documents'**
  String get taxDocuments;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View and download tax forms'**
  String get viewAndDownloadTaxForms;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Navigation & Map'**
  String get navigationMap;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Show on Driver Map'**
  String get showOnDriverMap;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to see your location'**
  String get allowPassengersToSeeYour;

  /// Text from _buildDropdownTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Preferred Navigation App'**
  String get preferredNavigationApp;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Play sounds for new requests and messages'**
  String get playSoundsForNewRequests;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vibrate for important alerts'**
  String get vibrateForImportantAlerts;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Customize what notifications you receive'**
  String get customizeWhatNotificationsYouReceive;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get nightMode;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reduce eye strain in low light'**
  String get reduceEyeStrainInLow;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountSecurity;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Documents'**
  String get driverDocuments;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'License, insurance, and registration'**
  String get licenseInsuranceAndRegistration;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Background Check'**
  String get backgroundCheck;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View your verification status'**
  String get viewYourVerificationStatus;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateYourAccountPassword;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add extra security to your account'**
  String get addExtraSecurityToYour;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Help Center'**
  String get driverHelpCenter;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'FAQs and troubleshooting guides'**
  String get faqsAndTroubleshootingGuides;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Chat with our support team'**
  String get chatWithOurSupportTeam;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Report a Safety Issue'**
  String get reportASafetyIssue;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Report incidents or concerns'**
  String get reportIncidentsOrConcerns;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Switch to Rider Mode'**
  String get switchToRiderMode;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Use the app as a passenger'**
  String get useTheAppAsA;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Log out of your account'**
  String get logOutOfYourAccount;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pause Driver Account'**
  String get pauseDriverAccount;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Temporarily stop receiving requests'**
  String get temporarilyStopReceivingRequests;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Delete Driver Account'**
  String get deleteDriverAccount;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your driver profile'**
  String get permanentlyRemoveYourDriverProfile;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'SportConnect Driver'**
  String get sportconnectDriver;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Version 2.1.0'**
  String get version210;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get areYouSureYouWant3;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your driver data, earnings history, and ratings will be permanently deleted.'**
  String get thisActionCannotBeUndone;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please sign in to manage vehicles'**
  String get pleaseSignInToManage;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get myVehicles;

  /// No description provided for @manageYourVehicles.
  ///
  /// In en, this message translates to:
  /// **'Manage your vehicles'**
  String get manageYourVehicles;

  /// No description provided for @createdAndJoinedEvents.
  ///
  /// In en, this message translates to:
  /// **'Created & joined events'**
  String get createdAndJoinedEvents;

  /// No description provided for @viewYourBadgesAndRewards.
  ///
  /// In en, this message translates to:
  /// **'View your badges & rewards'**
  String get viewYourBadgesAndRewards;

  /// No description provided for @appPreferencesAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'App preferences & privacy'**
  String get appPreferencesAndPrivacy;

  /// No description provided for @permissionPhotoLibraryMessage.
  ///
  /// In en, this message translates to:
  /// **'Access to your photo library is needed to send images in this chat. Your photos are only shared when you choose to send them.'**
  String get permissionPhotoLibraryMessage;

  /// No description provided for @yourFleet.
  ///
  /// In en, this message translates to:
  /// **'Your Fleet'**
  String get yourFleet;

  /// No description provided for @noActiveVehicle.
  ///
  /// In en, this message translates to:
  /// **'No active vehicle'**
  String get noActiveVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Vehicles Added'**
  String get noVehiclesAdded;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to start\noffering rides'**
  String get addYourFirstVehicleTo;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle set as active'**
  String get vehicleSetAsActive;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {value}?'**
  String areYouSureYouWant4(Object value);

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle deleted'**
  String get vehicleDeleted;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Set Active'**
  String get setActive;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlate;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Passenger Capacity'**
  String get passengerCapacity;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} passengers'**
  String valuePassengers(Object value);

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total Rides'**
  String get totalRides;

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} ⭐'**
  String value8(Object value);

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Demographics'**
  String get demographics;

  /// Text from _buildActionTile.label in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Label for the optional gender field in the rider/driver onboarding forms
  ///
  /// In en, this message translates to:
  /// **'Gender (Optional)'**
  String get genderOptional;

  /// Text from _buildActionTile.label in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sports Interests'**
  String get sportsInterests;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get add;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No interests selected'**
  String get noInterestsSelected;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select Sports Interests'**
  String get selectSportsInterests;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes.'**
  String get youHaveUnsavedChanges;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get pleaseCheckYourConnectionAnd;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Member since {value}'**
  String memberSinceValue(Object value);

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New member'**
  String get newMember;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified Info'**
  String get verifiedInfo;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Statistics'**
  String get rideStatistics;

  /// Text from _buildStatCard.label in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Text from _buildStatCard.label in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned2;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Profile Not Found'**
  String get profileNotFound;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your profile data could not be loaded.\nThis may happen if you\'re a new user.'**
  String get yourProfileDataCouldNot;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign out & try again'**
  String get signOutTryAgain;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find People'**
  String get findPeople;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// Text from InputDecoration.hintText in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find Fellow Riders'**
  String get findFellowRiders;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search for users by their name\nto connect and share rides'**
  String get searchForUsersByTheir;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound2;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No users found matching \"{value}\"'**
  String noUsersFoundMatchingValue(Object value);

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryADifferentSearchTerm;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Text from _buildNavigationTile.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'vehicles'**
  String get vehicles;

  /// Text from _buildSectionHeader in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'SportConnect v0.0.11'**
  String get sportconnectV100;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Blocked Users'**
  String get noBlockedUsers;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Users you block will appear here'**
  String get usersYouBlockWillAppear;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment integration will be available soon'**
  String get paymentIntegrationWillBeAvailable;

  /// Text from InputDecoration.labelText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Text from InputDecoration.labelText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Text from InputDecoration.labelText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rides & Carpooling'**
  String get ridesCarpooling;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Safety & Trust'**
  String get safetyTrust;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountSettings;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Opening: {value}'**
  String openingValue(Object value);

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help! Choose how you\'d like to reach us.'**
  String get weReHereToHelp;

  /// Text from _buildContactOption.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get couldNotOpenEmailApp;

  /// Text from _buildContactOption.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Live chat will be available soon!'**
  String get liveChatWillBeAvailable;

  /// Text from _buildContactOption.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describeTheProblem;

  /// Text from InputDecoration.hintText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please describe what happened...'**
  String get pleaseDescribeWhatHappened;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your report has been submitted.'**
  String get thankYouYourReportHas;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of SportConnect?'**
  String get areYouSureYouWant5;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data, including:'**
  String get thisActionCannotBeUndone2;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride history and bookings'**
  String get rideHistoryAndBookings;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Profile and achievements'**
  String get profileAndAchievements;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Messages and connections'**
  String get messagesAndConnections;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment information'**
  String get paymentInformation;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to confirm:'**
  String get typeDeleteToConfirm;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {value}'**
  String failedToDeleteAccountValue(Object value);

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Ride'**
  String get addRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading vehicles'**
  String get errorLoadingVehicles;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Garage'**
  String get myGarage;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} Vehicles'**
  String valueVehicles(Object value);

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get setDefault;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Text from _buildMiniInfo in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plate;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Garage is Empty'**
  String get garageIsEmpty;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle to start your journey. Connect with others and share rides.'**
  String get addAVehicleToStart;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Quick Tip'**
  String get quickTip;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Swipe right on a vehicle card to set it as default. Swipe left to remove it.'**
  String get swipeRightOnAVehicle;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Delete Ride?'**
  String get deleteRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {value}? This cannot be undone.'**
  String areYouSureYouWant6(Object value);

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Keep It'**
  String get keepIt;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle removed from garage'**
  String get vehicleRemovedFromGarage;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit Ride'**
  String get editRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New Ride'**
  String get newRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats Capacity'**
  String get seatsCapacity;

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}\'s Reviews'**
  String valueSReviews(Object value);

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// Error text when reviews fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedToLoadReviews;

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} reviews'**
  String valueReviews(Object value);

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Leave a Review'**
  String get leaveAReview;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'What stood out?'**
  String get whatStoodOut;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get additionalCommentsOptional;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Driver'**
  String get yourDriver;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Passenger'**
  String get yourPassenger;

  /// Text from InputDecoration.hintText in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get shareYourExperience;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankYouForYourReview;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}{value2}'**
  String valueValue5(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading ride'**
  String get errorLoadingRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Tooltip for showing the password in a text field
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get tooltipShowPassword;

  /// Tooltip for hiding the password in a text field
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get tooltipHidePassword;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Active Ride'**
  String get activeRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No active ride'**
  String get noActiveRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Start a ride to see navigation'**
  String get startARideToSee;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Heading to pickup'**
  String get headingToPickup;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Heading to destination'**
  String get headingToDestination;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'ETA: {value1} min • {value2} km remaining'**
  String etaValueMinValueKm(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Arriving at {value}'**
  String arrivingAtValue(Object value);

  /// Text from _buildTripStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Text from _buildTripStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Text from _buildTripStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get text5Min;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} more'**
  String valueMore(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} passenger{value2}'**
  String valuePassengerValue(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'• {value1} seat{value2} booked'**
  String valueSeatValueBooked(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} seat{value2} booked'**
  String valueSeatValueBooked2(Object value1, Object value2);

  /// Text from _buildPassengerStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// Text from _buildPassengerStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'€/seat'**
  String get seat2;

  /// Text from _buildPassengerStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// Text from _buildLocationRow in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// Text from _buildLocationRow in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoff;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} passenger{value2} booked for this ride'**
  String valuePassengerValueBookedFor(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride?'**
  String get cancelRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? This may affect your driver rating.'**
  String get areYouSureYouWant7;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Continue Ride'**
  String get continueRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide2;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Manage your rides & earnings'**
  String get manageYourRidesEarnings;

  /// Text from _buildTabWithBadge in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// Text from _buildEarningStat.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests2;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'NEW REQUEST'**
  String get newRequest;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tap to respond'**
  String get tapToRespond;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+€{value}'**
  String value9(Object value);

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'earnings'**
  String get earnings2;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} • {value2}'**
  String valueValue6(Object value1, Object value2);

  /// Text from _buildErrorState in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load user'**
  String get failedToLoadUser;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Active Rides'**
  String get noActiveRides;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'RIDE IN PROGRESS'**
  String get rideInProgress;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}/{value2} passengers'**
  String valueValuePassengers(Object value1, Object value2);

  /// Text from _buildActionChip.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// Text from _buildActionChip.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Scheduled Rides'**
  String get noScheduledRides;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'€{value}/seat'**
  String valueSeat(Object value);

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Completed Rides'**
  String get noCompletedRides;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} • {value2} passengers'**
  String valueValuePassengers2(Object value1, Object value2);

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading your rides...'**
  String get loadingYourRides;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign In Required'**
  String get signInRequired;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking accepted!'**
  String get bookingAccepted;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking declined'**
  String get bookingDeclined;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride completed! Well done 🎉'**
  String get rideCompletedWellDone;

  /// Text from _buildSettingsOption.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Manage Vehicles'**
  String get manageVehicles;

  /// Text from _buildSettingsOption.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earnings History'**
  String get earningsHistory;

  /// Text from _buildSettingsOption.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer a Ride'**
  String get offerARide;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Account Required'**
  String get driverAccountRequired;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You need to register as a driver and add a vehicle to offer rides.'**
  String get youNeedToRegisterAs;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share your journey, earn money'**
  String get shareYourJourneyEarnMoney;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Route'**
  String get yourRoute;

  /// Text from _buildLocationTile.label in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get startingPoint;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recurring Ride'**
  String get recurringRide;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer this ride regularly'**
  String get offerThisRideRegularly;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle to start offering rides'**
  String get addAVehicleToStart2;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add2;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeats;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Max {value} passengers'**
  String maxValuePassengers(Object value);

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select a vehicle first'**
  String get selectAVehicleFirst;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price per Seat'**
  String get pricePerSeat;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price Negotiable'**
  String get priceNegotiable;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Online Payment'**
  String get acceptOnlinePayment;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Receive payments via Stripe'**
  String get receivePaymentsViaStripe;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Luggage'**
  String get allowLuggage;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Pets'**
  String get allowPets;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Smoking'**
  String get allowSmoking;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Women Only'**
  String get womenOnly;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Max Detour'**
  String get maxDetour;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How far you\'ll go to pick up passengers'**
  String get howFarYouLlGo;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride created successfully!'**
  String get rideCreatedSuccessfully;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New ride requests will appear here'**
  String get newRideRequestsWillAppear;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Declined Requests'**
  String get noDeclinedRequests;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You haven\'t declined any requests yet'**
  String get youHavenTDeclinedAny;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Request?'**
  String get acceptRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You are about to accept {value1}\'s ride request for {value2} at {value3}.'**
  String youAreAboutToAccept(Object value1, Object value2, Object value3);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request accepted! {value} has been notified.'**
  String requestAcceptedValueHasBeen(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to accept request'**
  String get failedToAcceptRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to decline request'**
  String get failedToDeclineRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Requested {value}'**
  String requestedValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'• {value1} seat{value2}'**
  String valueSeatValue2(Object value1, Object value2);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} seat{value2} requested'**
  String valueSeatValueRequested(Object value1, Object value2);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest2;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accepted {value}'**
  String acceptedValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} at {value2}'**
  String valueAtValue(Object value1, Object value2);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Declined {value}'**
  String declinedValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reason: {value}'**
  String reasonValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline Request'**
  String get declineRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please let {value} know why you can\'t accept this ride.'**
  String pleaseLetValueKnowWhy(Object value);

  /// Text from InputDecoration.hintText in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please specify...'**
  String get pleaseSpecify;

  /// Text from _buildErrorState in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride not found'**
  String get rideNotFound;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Ride'**
  String get yourRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load ride'**
  String get couldnTLoadRide;

  /// Text from _buildStatItem.label in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats filled'**
  String get seatsFilled;

  /// Text from _buildStatItem.label in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Per seat'**
  String get perSeat;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'~{value}'**
  String value10(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} total seats'**
  String valueTotalSeats(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New booking requests will appear here'**
  String get newBookingRequestsWillAppear;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No passengers yet'**
  String get noPassengersYet;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept booking requests to add passengers'**
  String get acceptBookingRequestsToAdd;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share Ride'**
  String get shareRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Duplicate Ride'**
  String get duplicateRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Call Passenger'**
  String get callPassenger;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove Passenger'**
  String get removePassenger;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed for {value}'**
  String bookingConfirmedForValue(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline Booking'**
  String get declineBooking;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline booking request from {value}?'**
  String declineBookingRequestFromValue(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove {value} from this ride?'**
  String removeValueFromThisRide(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get startRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mark this ride as started? Passengers will be notified.'**
  String get markThisRideAsStarted;

  /// Title for the pickup confirmation dialog on the active ride screen
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get confirmPickup;

  /// Button text in pickup confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Passengers Picked Up — Start Trip'**
  String get passengersPickedUpStartTrip;

  /// Content text in pickup confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm all passengers have been picked up and you are ready to start the trip.'**
  String get confirmAllPassengersPickedUp;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete Ride'**
  String get completeRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mark this ride as completed? You can then rate your passengers.'**
  String get markThisRideAsCompleted;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? All passengers will be notified and refunded.'**
  String get areYouSureYouWant8;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Keep Ride'**
  String get keepRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load ride'**
  String get failedToLoadRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This ride may have been completed or cancelled'**
  String get thisRideMayHaveBeen;

  /// Text from _buildStatusStep in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Confirmed'**
  String get rideConfirmed;

  /// Text from _buildStatusStep in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get driverOnTheWay;

  /// Text from _buildStatusStep in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get rideCompleted;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'• {value} rides'**
  String valueRides2(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get routeDetails;

  /// Text from _buildInfoItem in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'per seat'**
  String get perSeat2;

  /// Text from _buildInfoItem in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'seats left'**
  String get seatsLeft;

  /// Text from _buildInfoItem in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Passengers ({value})'**
  String passengersValue(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNumberNotAvailable;

  /// Shown when phone dialer is unavailable
  ///
  /// In en, this message translates to:
  /// **'Cannot make phone calls on this device'**
  String get cannotMakePhoneCalls;

  /// Shown when phone dialer launch fails
  ///
  /// In en, this message translates to:
  /// **'Failed to launch phone dialer'**
  String get failedToLaunchDialer;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? Cancellation policies may apply.'**
  String get areYouSureYouWant9;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled successfully'**
  String get rideCancelledSuccessfully;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel ride: {value}'**
  String failedToCancelRideValue(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rate your ride'**
  String get rateYourRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rating feature coming soon! Thank you for using SportConnect.'**
  String get ratingFeatureComingSoonThank;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Track & manage your rides'**
  String get trackManageYourRides;

  /// Text from _buildTab in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Text from _buildTab in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Text from _buildEmptyState.title in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Active Trips'**
  String get noActiveTrips;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'TRIP IN PROGRESS'**
  String get tripInProgress;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'4.9'**
  String get text49;

  /// Text from _buildEmptyState.title in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Trips'**
  String get noUpcomingTrips;

  /// Text from _buildEmptyState.title in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Trip History'**
  String get noTripHistory;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebook;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find Ride'**
  String get findRide;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading your trips...'**
  String get loadingYourTrips;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip?'**
  String get cancelTrip;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your trip to {value}?'**
  String areYouSureYouWant10(Object value);

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get tripCancelled;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Opening chat...'**
  String get openingChat;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat: {value}'**
  String failedToOpenChatValue(Object value);

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Starting call...'**
  String get startingCall;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find the perfect ride for your journey'**
  String get findThePerfectRideFor;

  /// Text from _buildLocationRow.label in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Where from?'**
  String get whereFrom;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get when;

  /// Text from _buildDateChip in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Text from _buildDateChip in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Text from _buildDateChip in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure time'**
  String get departureTime2;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How many seats do you need?'**
  String get howManySeatsDoYou;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Available Rides'**
  String get availableRides;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get noRidesFound;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria\nor check back later'**
  String get tryAdjustingYourSearchCriteria;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Finding rides...'**
  String get findingRides;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'recommended'**
  String get recommended;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earliest departure'**
  String get earliestDeparture;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get lowestPrice;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get highestRated;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get searchFailedPleaseTryAgain;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} • '**
  String value11(Object value);

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} left'**
  String valueLeft(Object value);

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'~{value} min'**
  String valueMin2(Object value);

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} kg CO₂ saved per person'**
  String valueKgCoSavedPer(Object value);

  /// Text from _buildDetailChip in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// Text from _buildDetailChip in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Online Pay'**
  String get onlinePay;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats:'**
  String get seats3;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Text from _buildSummaryRow in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price per seat'**
  String get pricePerSeat2;

  /// Text from _buildSummaryRow in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Text from InputDecoration.hintText in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a note to the driver (optional)'**
  String get addANoteToThe;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking request sent!'**
  String get bookingRequestSent;

  /// Text from _buildInfoChip.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats left'**
  String get seatsLeft2;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// Text from _buildDetailRow.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure2;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// Text from _buildAmenityItem.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// Text from _buildAmenityItem.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smoking;

  /// Text from _buildAmenityItem.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get luggage;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Passengers ({value})'**
  String yourPassengersValue(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}/{value2} seats'**
  String valueValueSeats(Object value1, Object value2);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No passengers accepted yet'**
  String get noPassengersAcceptedYet;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No passengers booked yet'**
  String get noPassengersBookedYet;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} has booked this ride'**
  String valueHasBookedThisRide(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} passengers have booked'**
  String valuePassengersHaveBooked(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pending Requests ({value})'**
  String pendingRequestsValue(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request accepted! 🎉'**
  String get requestAccepted;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats Booked'**
  String get seatsBooked;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit ride feature coming soon!'**
  String get editRideFeatureComingSoon;

  /// Text from _buildPriceRow in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Number of seats'**
  String get numberOfSeats;

  /// Text from _buildPriceRow in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'× {value}'**
  String value12(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Secure payment with Stripe'**
  String get securePaymentWithStripe;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please log in to book a ride'**
  String get pleaseLogInToBook;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment succeeded but booking failed. Please contact support.'**
  String get paymentSucceededButBookingFailed;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {value}'**
  String paymentFailedValue(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This driver accepts cash payment only.'**
  String get thisDriverAcceptsCashPayment;

  /// Text from _buildPaymentOption.title in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pay with Cash'**
  String get payWithCash;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to book ride. Please try again.'**
  String get failedToBookRidePlease;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You paid {value1} {value2}'**
  String youPaidValueValue(Object value1, Object value2);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your ride has been booked.'**
  String get yourRideHasBeenBooked;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You earned 25 XP!'**
  String get youEarned25Xp;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Back to Search'**
  String get backToSearch;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your ride has been booked. Pay the driver in cash.'**
  String get yourRideHasBeenBooked2;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please enter both locations'**
  String get pleaseEnterBothLocations;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please select locations from the picker'**
  String get pleaseSelectLocationsFromThe;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Max {value} €'**
  String maxValue(Object value);

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Female only'**
  String get femaleOnly;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Instant book'**
  String get instantBook;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pet friendly'**
  String get petFriendly;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}+ rating'**
  String valueRating(Object value);

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Active Filters'**
  String get activeFilters;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} rides available'**
  String valueRidesAvailable(Object value);

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Filters{value}'**
  String filtersValue(Object value);

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Text from _buildFilterSectionTitle in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'5 €'**
  String get text52;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'100 €'**
  String get text100;

  /// Text from _buildFilterSectionTitle in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get minimumRating;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'any'**
  String get any;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}+'**
  String value13(Object value);

  /// Text from _buildToggleChip.label in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified driver'**
  String get verifiedDriver2;

  /// Text from _buildToggleChip.label in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Music allowed'**
  String get musicAllowed;

  /// Filter label for excluding rides that allow smoking
  ///
  /// In en, this message translates to:
  /// **'No Smoking'**
  String get noSmoking;

  /// Text from _buildFilterSectionTitle in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// Text from _buildVehicleOption in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// Text from _buildVehicleOption in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'comfort'**
  String get comfort;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Lowest Price'**
  String get lowestPrice2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earliest Departure'**
  String get earliestDeparture2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get highestRated2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Shortest Duration'**
  String get shortestDuration;

  /// User-friendly error message for failed sign-in attempts
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get signInFailedPleaseTry;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Hint text for password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Divider text between social login and email login
  ///
  /// In en, this message translates to:
  /// **'or sign in with email'**
  String get orSignInWithEmail;

  /// Divider text before social sign-in options
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Label for Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Label for Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Label for retry button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Stat label for average earnings per ride
  ///
  /// In en, this message translates to:
  /// **'Avg per Ride'**
  String get avgPerRide;

  /// Stat label for total drive time
  ///
  /// In en, this message translates to:
  /// **'Drive Time'**
  String get driveTime;

  /// Greeting used before noon
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Greeting used between noon and evening
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Greeting used in the evening
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Error message when notifications fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// Hint text shown below error message
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
  String get checkYourConnectionAndTry;

  /// Error message when navigating to a chat fails
  ///
  /// In en, this message translates to:
  /// **'Could not open chat'**
  String get couldNotOpenChat;

  /// Hint text for chat search field
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// Hint text for chat inbox search field
  ///
  /// In en, this message translates to:
  /// **'Search chats or people'**
  String get searchChatsOrPeople;

  /// Section title for people found while searching chats
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleResults;

  /// Tab label for direct/private chats
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// Tab label for Event chats
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get groups;

  /// Tab label for all notifications
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Empty state subtitle for direct chats
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your ride partners'**
  String get startAConversationWith;

  /// Empty state subtitle for group chats
  ///
  /// In en, this message translates to:
  /// **'Join or create a group to start chatting'**
  String get joinOrCreateAGroup;

  /// Empty state subtitle for ride chats
  ///
  /// In en, this message translates to:
  /// **'Join a ride to chat with fellow travelers'**
  String get joinARideToChat;

  /// Quick action button label to create a new ride
  ///
  /// In en, this message translates to:
  /// **'Create Ride'**
  String get driverCreateRide;

  /// Label for weekly earnings metric
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get driverThisWeek;

  /// Label for monthly earnings metric
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get driverThisMonth;

  /// Label for CO2 saved stat card
  ///
  /// In en, this message translates to:
  /// **'CO₂ Saved'**
  String get driverCo2Saved;

  /// Label for hours online stat card
  ///
  /// In en, this message translates to:
  /// **'Hours Online'**
  String get driverHoursOnline;

  /// Title for location permission banner
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequired;

  /// Subtitle for location permission banner
  ///
  /// In en, this message translates to:
  /// **'Enable location for a better driving experience'**
  String get enableLocationForBetterExperience;

  /// Button text to open app settings for location permission
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Button text to enable location permission
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Subtitle for empty upcoming rides state
  ///
  /// In en, this message translates to:
  /// **'Create a ride to start earning'**
  String get createARideToStartEarning;

  /// No description provided for @wizardStepWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get wizardStepWelcome;

  /// No description provided for @wizardStepWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get wizardStepWelcomeSubtitle;

  /// No description provided for @wizardStepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get wizardStepSecurity;

  /// No description provided for @wizardStepSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get wizardStepSecuritySubtitle;

  /// No description provided for @wizardStepRole.
  ///
  /// In en, this message translates to:
  /// **'Your Role'**
  String get wizardStepRole;

  /// No description provided for @wizardStepRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use SportConnect?'**
  String get wizardStepRoleSubtitle;

  /// No description provided for @wizardStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get wizardStepProfile;

  /// No description provided for @wizardStepProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make it personal'**
  String get wizardStepProfileSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get authPhoneOptional;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number'**
  String get authPhoneHint;

  /// No description provided for @authDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get authDateOfBirth;

  /// No description provided for @authDobPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to select (must be 18+)'**
  String get authDobPrompt;

  /// No description provided for @authDobMinAge.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to use SportConnect.'**
  String get authDobMinAge;

  /// No description provided for @authDobPicker.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get authDobPicker;

  /// No description provided for @authCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get authCreatePassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get authPasswordHint;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authAboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You (Optional)'**
  String get authAboutYou;

  /// No description provided for @authAboutYouHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself...'**
  String get authAboutYouHint;

  /// No description provided for @wizardFindRides.
  ///
  /// In en, this message translates to:
  /// **'Find Rides'**
  String get wizardFindRides;

  /// No description provided for @wizardFindRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Search for rides to sporting events, practices, and games'**
  String get wizardFindRidesDesc;

  /// No description provided for @wizardOfferRides.
  ///
  /// In en, this message translates to:
  /// **'Offer Rides'**
  String get wizardOfferRides;

  /// No description provided for @wizardOfferRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your car and earn money while helping others'**
  String get wizardOfferRidesDesc;

  /// No description provided for @wizardContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wizardContinue;

  /// No description provided for @authAgreeTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service'**
  String get authAgreeTermsError;

  /// No description provided for @authDobError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your date of birth.'**
  String get authDobError;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get otpTitle;

  /// No description provided for @otpEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get otpEnterPhone;

  /// No description provided for @otpPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get otpPhoneHint;

  /// No description provided for @otpSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get otpSendCode;

  /// No description provided for @otpVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpVerifyTitle;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get otpEnterCode;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get otpResendCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get otpInvalidCode;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Please request a new one.'**
  String get otpExpired;

  /// No description provided for @otpPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get otpPhoneRequired;

  /// No description provided for @otpInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get otpInvalidPhone;

  /// No description provided for @otpSending.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code...'**
  String get otpSending;

  /// No description provided for @otpVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get otpVerifying;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCodeLabel;

  /// No description provided for @otpPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone Verified!'**
  String get otpPhoneVerified;

  /// No description provided for @otpPhoneVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your phone number has been verified successfully.'**
  String get otpPhoneVerifiedDesc;

  /// No description provided for @otpContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get otpContinue;

  /// No description provided for @otpChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get otpChangePhone;

  /// No description provided for @otpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get otpTryAgain;

  /// No description provided for @otpBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get otpBackToLogin;

  /// No description provided for @reauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get reauthTitle;

  /// No description provided for @reauthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your security, please confirm your identity before continuing with this action.'**
  String get reauthSubtitle;

  /// No description provided for @reauthPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get reauthPassword;

  /// No description provided for @reauthPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get reauthPasswordHint;

  /// No description provided for @reauthPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get reauthPasswordRequired;

  /// No description provided for @reauthConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get reauthConfirm;

  /// No description provided for @reauthWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Verify with Google'**
  String get reauthWithGoogle;

  /// No description provided for @reauthCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reauthCancel;

  /// No description provided for @reauthWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get reauthWrongPassword;

  /// No description provided for @reauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get reauthFailed;

  /// No description provided for @reauthGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google re-authentication failed.'**
  String get reauthGoogleFailed;

  /// No description provided for @emailVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get emailVerifyTitle;

  /// No description provided for @emailVerifyHeading.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get emailVerifyHeading;

  /// No description provided for @emailVerifySentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to:'**
  String get emailVerifySentTo;

  /// No description provided for @emailVerifyWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification...'**
  String get emailVerifyWaiting;

  /// No description provided for @emailVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get emailVerifyResend;

  /// No description provided for @emailVerifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String emailVerifyResendIn(int seconds);

  /// No description provided for @emailVerifyCheckButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get emailVerifyCheckButton;

  /// No description provided for @emailVerifySent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get emailVerifySent;

  /// No description provided for @emailVerifySendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email. Please try again.'**
  String get emailVerifySendFailed;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email Verified!'**
  String get emailVerified;

  /// No description provided for @emailVerifiedRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Your email has been verified. Redirecting...'**
  String get emailVerifiedRedirecting;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordHeading.
  ///
  /// In en, this message translates to:
  /// **'Update Your Password'**
  String get changePasswordHeading;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password with at least 8 characters, including uppercase, lowercase, and numbers.'**
  String get changePasswordDesc;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordUpdate;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Updated!'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully. Use your new password next time you sign in.'**
  String get changePasswordSuccessDesc;

  /// No description provided for @changePasswordDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get changePasswordDone;

  /// No description provided for @changePasswordWeakError.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please choose a stronger password.'**
  String get changePasswordWeakError;

  /// No description provided for @changePasswordGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Please try again.'**
  String get changePasswordGenericError;

  /// No description provided for @forgotPasswordCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get forgotPasswordCheckEmail;

  /// No description provided for @forgotPasswordResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get forgotPasswordResendEmail;

  /// No description provided for @forgotPasswordResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String forgotPasswordResendIn(int seconds);

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email right now. Please try again.'**
  String get forgotPasswordSendError;

  /// No description provided for @roleSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get roleSelectionError;

  /// No description provided for @accountExistsError.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method. Try signing in with email/password or the original provider.'**
  String get accountExistsError;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts. Please try again later.'**
  String get loginErrorTooManyRequests;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @signUpFailedPleaseTry.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get signUpFailedPleaseTry;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get periodThisWeek;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get periodThisMonth;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get periodAllTime;

  /// No description provided for @statRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get statRides;

  /// No description provided for @statEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get statEarnings;

  /// No description provided for @statOnlineHours.
  ///
  /// In en, this message translates to:
  /// **'Online Hours'**
  String get statOnlineHours;

  /// No description provided for @statAvgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get statAvgRating;

  /// No description provided for @connectStripeAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe Account'**
  String get connectStripeAccount;

  /// No description provided for @benefitInstantPayoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get your money in minutes, not days'**
  String get benefitInstantPayoutsDesc;

  /// No description provided for @benefitSecureDesc.
  ///
  /// In en, this message translates to:
  /// **'Bank-level security with Stripe'**
  String get benefitSecureDesc;

  /// No description provided for @benefitTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'See every ride payment in detail'**
  String get benefitTrackingDesc;

  /// No description provided for @benefitLowFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep 85% of every ride payment'**
  String get benefitLowFeesDesc;

  /// No description provided for @pleaseSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get pleaseSignInToContinue;

  /// No description provided for @poweredByStripe.
  ///
  /// In en, this message translates to:
  /// **'Powered by Stripe • Secure and encrypted'**
  String get poweredByStripe;

  /// No description provided for @cancelSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Setup?'**
  String get cancelSetupTitle;

  /// No description provided for @cancelSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? You won\'t be able to receive payouts until you complete this setup.'**
  String get cancelSetupMessage;

  /// No description provided for @continueSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue Setup'**
  String get continueSetup;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get filterRefunded;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterFailed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get statusRefunded;

  /// No description provided for @statusPartiallyRefunded.
  ///
  /// In en, this message translates to:
  /// **'Partially Refunded'**
  String get statusPartiallyRefunded;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @refundRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Refund request submitted successfully'**
  String get refundRequestSubmitted;

  /// No description provided for @refundRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund request failed. Please try again.'**
  String get refundRequestFailed;

  /// No description provided for @payoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Payout Details'**
  String get payoutDetails;

  /// No description provided for @payoutNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payout not found'**
  String get payoutNotFound;

  /// No description provided for @totalPayout.
  ///
  /// In en, this message translates to:
  /// **'Total Payout'**
  String get totalPayout;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @grossEarnings.
  ///
  /// In en, this message translates to:
  /// **'Gross Earnings'**
  String get grossEarnings;

  /// No description provided for @netPayout.
  ///
  /// In en, this message translates to:
  /// **'Net Payout'**
  String get netPayout;

  /// No description provided for @payoutCreated.
  ///
  /// In en, this message translates to:
  /// **'Payout Created'**
  String get payoutCreated;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @payoutAmount.
  ///
  /// In en, this message translates to:
  /// **'Payout Amount'**
  String get payoutAmount;

  /// No description provided for @instantPayout.
  ///
  /// In en, this message translates to:
  /// **'Instant Payout'**
  String get instantPayout;

  /// No description provided for @payoutDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get payoutDetailsSection;

  /// No description provided for @expectedArrival.
  ///
  /// In en, this message translates to:
  /// **'Expected Arrival'**
  String get expectedArrival;

  /// No description provided for @arrivedAt.
  ///
  /// In en, this message translates to:
  /// **'Arrived At'**
  String get arrivedAt;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @accountEnding.
  ///
  /// In en, this message translates to:
  /// **'Account Ending'**
  String get accountEnding;

  /// No description provided for @failureReason.
  ///
  /// In en, this message translates to:
  /// **'Failure Reason'**
  String get failureReason;

  /// No description provided for @cancelPayout.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payout'**
  String get cancelPayout;

  /// No description provided for @cancelPayoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this payout? This action cannot be undone.'**
  String get cancelPayoutConfirm;

  /// No description provided for @payoutCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payout cancelled successfully'**
  String get payoutCancelled;

  /// No description provided for @payoutCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel payout. Please try again.'**
  String get payoutCancelFailed;

  /// No description provided for @payoutPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payout is being processed and will be sent shortly.'**
  String get payoutPendingDesc;

  /// No description provided for @payoutInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get payoutInTransit;

  /// No description provided for @payoutInTransitDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payout has been sent and is on its way to your bank.'**
  String get payoutInTransitDesc;

  /// No description provided for @payoutPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payoutPaid;

  /// No description provided for @payoutPaidDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payout has arrived in your bank account.'**
  String get payoutPaidDesc;

  /// No description provided for @payoutFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'This payout failed. Check the failure reason below.'**
  String get payoutFailedDesc;

  /// No description provided for @payoutCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'This payout was cancelled.'**
  String get payoutCancelledDesc;

  /// No description provided for @stripeVerifyingAccount.
  ///
  /// In en, this message translates to:
  /// **'Verifying your account...'**
  String get stripeVerifyingAccount;

  /// No description provided for @stripeAccountCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create Stripe account. Please try again.'**
  String get stripeAccountCreationFailed;

  /// No description provided for @stripeSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start Stripe setup right now. Please try again.'**
  String get stripeSetupFailed;

  /// No description provided for @stripePageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load page. Please try again.'**
  String get stripePageLoadFailed;

  /// No description provided for @stripeLoadingConnect.
  ///
  /// In en, this message translates to:
  /// **'Loading Stripe Connect...'**
  String get stripeLoadingConnect;

  /// No description provided for @stripeAdditionalInfoNeeded.
  ///
  /// In en, this message translates to:
  /// **'Additional information needed. Please complete all fields.'**
  String get stripeAdditionalInfoNeeded;

  /// No description provided for @stripeVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify account right now. Please try again.'**
  String get stripeVerifyFailed;

  /// No description provided for @unableToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data. Pull to refresh.'**
  String get unableToLoadData;

  /// No description provided for @exportEarningsReport.
  ///
  /// In en, this message translates to:
  /// **'Earnings Report'**
  String get exportEarningsReport;

  /// No description provided for @exportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get exportGenerated;

  /// No description provided for @exportEarningsSummary.
  ///
  /// In en, this message translates to:
  /// **'EARNINGS SUMMARY'**
  String get exportEarningsSummary;

  /// No description provided for @exportRideStatistics.
  ///
  /// In en, this message translates to:
  /// **'RIDE STATISTICS'**
  String get exportRideStatistics;

  /// No description provided for @exportRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'RECENT TRANSACTIONS'**
  String get exportRecentTransactions;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get driverProfileTitle;

  /// No description provided for @driverProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself so riders can get to know you.'**
  String get driverProfileSubtitle;

  /// No description provided for @driverCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get driverCityLabel;

  /// No description provided for @driverCityHint.
  ///
  /// In en, this message translates to:
  /// **'Where are you based?'**
  String get driverCityHint;

  /// No description provided for @driverCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your city'**
  String get driverCityRequired;

  /// No description provided for @expertiseLevel.
  ///
  /// In en, this message translates to:
  /// **'Expertise Level'**
  String get expertiseLevel;

  /// No description provided for @expertiseLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your expertise level.'**
  String get expertiseLevelRequired;

  /// No description provided for @driverInterestsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one interest.'**
  String get driverInterestsRequired;

  /// No description provided for @driverTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get driverTermsLabel;

  /// No description provided for @driverTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept Terms and Privacy to continue.'**
  String get driverTermsRequired;

  /// No description provided for @driverSaveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get driverSaveAndContinue;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get ratingExcellent;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get ratingAverage;

  /// No description provided for @ratingBelowAverage.
  ///
  /// In en, this message translates to:
  /// **'Below Average'**
  String get ratingBelowAverage;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @findRidesNearYou.
  ///
  /// In en, this message translates to:
  /// **'Find Rides Near You'**
  String get findRidesNearYou;

  /// Label for the map toggle card on the rider home feed
  ///
  /// In en, this message translates to:
  /// **'Explore on Map'**
  String get exploreOnMap;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @pickupAndDropoff.
  ///
  /// In en, this message translates to:
  /// **'Pickup & Drop-off'**
  String get pickupAndDropoff;

  /// No description provided for @enterPickupAndDestination.
  ///
  /// In en, this message translates to:
  /// **'Enter your pickup and destination locations'**
  String get enterPickupAndDestination;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @chooseWhenYouWantToTravel.
  ///
  /// In en, this message translates to:
  /// **'Choose when you want to travel'**
  String get chooseWhenYouWantToTravel;

  /// No description provided for @findAndBook.
  ///
  /// In en, this message translates to:
  /// **'Find & Book'**
  String get findAndBook;

  /// No description provided for @browseAvailableRidesAndBook.
  ///
  /// In en, this message translates to:
  /// **'Browse available rides and book instantly'**
  String get browseAvailableRidesAndBook;

  /// No description provided for @verifiedDrivers.
  ///
  /// In en, this message translates to:
  /// **'Verified Drivers'**
  String get verifiedDrivers;

  /// No description provided for @allDriversAreVerified.
  ///
  /// In en, this message translates to:
  /// **'All drivers are verified for your safety and comfort'**
  String get allDriversAreVerified;

  /// No description provided for @locationGateDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable location to discover rides near you, get accurate pickup times, and navigate safely.'**
  String get locationGateDescription;

  /// No description provided for @locationBenefitFind.
  ///
  /// In en, this message translates to:
  /// **'Find rides near your location'**
  String get locationBenefitFind;

  /// No description provided for @locationBenefitNavigate.
  ///
  /// In en, this message translates to:
  /// **'Get turn-by-turn navigation'**
  String get locationBenefitNavigate;

  /// No description provided for @locationBenefitSafety.
  ///
  /// In en, this message translates to:
  /// **'Enhanced safety features'**
  String get locationBenefitSafety;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @browseWithoutLocation.
  ///
  /// In en, this message translates to:
  /// **'Browse without location'**
  String get browseWithoutLocation;

  /// No description provided for @findingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get findingYourLocation;

  /// No description provided for @thisWillOnlyTakeAMoment.
  ///
  /// In en, this message translates to:
  /// **'This will only take a moment'**
  String get thisWillOnlyTakeAMoment;

  /// No description provided for @locationNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Location Not Enabled'**
  String get locationNotEnabled;

  /// No description provided for @locationNotEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Location access is off. You can still browse rides by city.'**
  String get locationNotEnabledDescription;

  /// No description provided for @browseByCity.
  ///
  /// In en, this message translates to:
  /// **'Browse by City'**
  String get browseByCity;

  /// No description provided for @locationPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Blocked'**
  String get locationPermissionBlocked;

  /// No description provided for @locationPermissionBlockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Location access is off in device settings. Features that need your current location are unavailable until changed in Settings.'**
  String get locationPermissionBlockedDescription;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location Services Off'**
  String get locationServicesOff;

  /// No description provided for @locationServicesOffDescription.
  ///
  /// In en, this message translates to:
  /// **'Your device\'s location services are turned off. Features that need your current location are unavailable until changed in Settings.'**
  String get locationServicesOffDescription;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Location Settings'**
  String get openLocationSettings;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'events'**
  String get events;

  /// No description provided for @satellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get satellite;

  /// No description provided for @maxSeatsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 seats per booking'**
  String get maxSeatsReached;

  /// No description provided for @tryADifferentDate.
  ///
  /// In en, this message translates to:
  /// **'Try a different date'**
  String get tryADifferentDate;

  /// No description provided for @tapToOpenNavigation.
  ///
  /// In en, this message translates to:
  /// **'Tap to open navigation'**
  String get tapToOpenNavigation;

  /// No description provided for @completePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePayment;

  /// No description provided for @bookingAcceptedPaymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Your booking is accepted. Payment required.'**
  String get bookingAcceptedPaymentRequired;

  /// No description provided for @tapToViewCountdown.
  ///
  /// In en, this message translates to:
  /// **'Tap to view countdown'**
  String get tapToViewCountdown;

  /// No description provided for @departingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Departing tomorrow'**
  String get departingTomorrow;

  /// No description provided for @departingValue.
  ///
  /// In en, this message translates to:
  /// **'Departing {value}'**
  String departingValue(String value);

  /// No description provided for @awaitingDriverCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Awaiting driver} other{Awaiting driver • {count} pending}}'**
  String awaitingDriverCount(int count);

  /// No description provided for @departingTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Departing today at {h}:{m}'**
  String departingTodayAt(String h, String m);

  /// No description provided for @departingInDays.
  ///
  /// In en, this message translates to:
  /// **'Departing in {days} days'**
  String departingInDays(int days);

  /// No description provided for @createEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEventTitle;

  /// No description provided for @editEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEventTitle;

  /// No description provided for @myEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEventsTitle;

  /// No description provided for @discoverEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Events'**
  String get discoverEventsTitle;

  /// No description provided for @eventSportType.
  ///
  /// In en, this message translates to:
  /// **'Sport Type'**
  String get eventSportType;

  /// No description provided for @eventTitleField.
  ///
  /// In en, this message translates to:
  /// **'Event Title *'**
  String get eventTitleField;

  /// No description provided for @eventTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get eventTitleRequired;

  /// No description provided for @eventTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters'**
  String get eventTitleMinLength;

  /// No description provided for @eventVenueName.
  ///
  /// In en, this message translates to:
  /// **'Venue Name (optional)'**
  String get eventVenueName;

  /// No description provided for @eventDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get eventDescriptionField;

  /// No description provided for @eventCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover Image (optional)'**
  String get eventCoverImage;

  /// No description provided for @eventTapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a cover photo'**
  String get eventTapToAddPhoto;

  /// No description provided for @eventLocationField.
  ///
  /// In en, this message translates to:
  /// **'Location *'**
  String get eventLocationField;

  /// No description provided for @eventTapToPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick a location on the map'**
  String get eventTapToPickLocation;

  /// No description provided for @eventWhenField.
  ///
  /// In en, this message translates to:
  /// **'When *'**
  String get eventWhenField;

  /// No description provided for @eventStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get eventStartDate;

  /// No description provided for @eventStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get eventStartTime;

  /// No description provided for @eventEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get eventEndDate;

  /// No description provided for @eventEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get eventEndTime;

  /// No description provided for @eventOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get eventOptional;

  /// No description provided for @eventEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get eventEndLabel;

  /// No description provided for @eventAddEndTime.
  ///
  /// In en, this message translates to:
  /// **'+ Add end time'**
  String get eventAddEndTime;

  /// No description provided for @eventMaxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Max Participants'**
  String get eventMaxParticipants;

  /// No description provided for @eventUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get eventUnlimited;

  /// No description provided for @eventParkingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Parking instructions (optional)'**
  String get eventParkingInstructions;

  /// No description provided for @eventRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring Event'**
  String get eventRecurring;

  /// No description provided for @eventRecurringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Repeats on selected days each week'**
  String get eventRecurringSubtitle;

  /// No description provided for @eventRepeatsUntil.
  ///
  /// In en, this message translates to:
  /// **'Repeats until {date}'**
  String eventRepeatsUntil(String date);

  /// No description provided for @eventRepeatEndDate.
  ///
  /// In en, this message translates to:
  /// **'Repeat end date (optional)'**
  String get eventRepeatEndDate;

  /// No description provided for @eventUploadingCover.
  ///
  /// In en, this message translates to:
  /// **'Uploading cover…'**
  String get eventUploadingCover;

  /// No description provided for @eventCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get eventCreating;

  /// No description provided for @eventCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get eventCreateButton;

  /// No description provided for @eventSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get eventSaveChanges;

  /// No description provided for @eventStartTimeFuture.
  ///
  /// In en, this message translates to:
  /// **'Start time must be in the future.'**
  String get eventStartTimeFuture;

  /// No description provided for @eventEndTimeAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get eventEndTimeAfterStart;

  /// No description provided for @eventLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Location'**
  String get eventLocationTitle;

  /// No description provided for @eventDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event?'**
  String get eventDeleteConfirmTitle;

  /// No description provided for @eventDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All participants will be removed.'**
  String get eventDeleteWarning;

  /// No description provided for @eventAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get eventAbout;

  /// No description provided for @eventParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get eventParticipants;

  /// No description provided for @eventLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave Event'**
  String get eventLeave;

  /// No description provided for @eventFull.
  ///
  /// In en, this message translates to:
  /// **'Event Full'**
  String get eventFull;

  /// No description provided for @eventJoin.
  ///
  /// In en, this message translates to:
  /// **'Join Event'**
  String get eventJoin;

  /// No description provided for @eventEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get eventEdit;

  /// No description provided for @eventDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get eventDelete;

  /// No description provided for @eventNoRidesOffered.
  ///
  /// In en, this message translates to:
  /// **'No rides offered yet'**
  String get eventNoRidesOffered;

  /// No description provided for @eventCouldNotLoadRides.
  ///
  /// In en, this message translates to:
  /// **'Could not load rides'**
  String get eventCouldNotLoadRides;

  /// No description provided for @eventHowGettingThere.
  ///
  /// In en, this message translates to:
  /// **'How are you getting there?'**
  String get eventHowGettingThere;

  /// No description provided for @eventImDriving.
  ///
  /// In en, this message translates to:
  /// **'I\'m Driving'**
  String get eventImDriving;

  /// No description provided for @eventNeedRide.
  ///
  /// In en, this message translates to:
  /// **'Need Ride'**
  String get eventNeedRide;

  /// No description provided for @eventSelfArranged.
  ///
  /// In en, this message translates to:
  /// **'Self-Arranged'**
  String get eventSelfArranged;

  /// No description provided for @eventYouAreOrganizer.
  ///
  /// In en, this message translates to:
  /// **'You are the organizer'**
  String get eventYouAreOrganizer;

  /// No description provided for @eventYouOrganized.
  ///
  /// In en, this message translates to:
  /// **'You organized this event'**
  String get eventYouOrganized;

  /// No description provided for @eventYoureGoing.
  ///
  /// In en, this message translates to:
  /// **'You\'re going'**
  String get eventYoureGoing;

  /// No description provided for @eventYouAttended.
  ///
  /// In en, this message translates to:
  /// **'You attended'**
  String get eventYouAttended;

  /// No description provided for @eventNotJoinedYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined yet'**
  String get eventNotJoinedYet;

  /// No description provided for @eventHasEnded.
  ///
  /// In en, this message translates to:
  /// **'This event has ended'**
  String get eventHasEnded;

  /// No description provided for @eventRidesToEvent.
  ///
  /// In en, this message translates to:
  /// **'Rides to This Event'**
  String get eventRidesToEvent;

  /// No description provided for @eventRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Event'**
  String get eventRecurringTitle;

  /// No description provided for @eventEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get eventEvery;

  /// No description provided for @eventUntilDate.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String eventUntilDate(String date);

  /// No description provided for @eventCostSplitEnabled.
  ///
  /// In en, this message translates to:
  /// **'Cost Split Enabled'**
  String get eventCostSplitEnabled;

  /// No description provided for @eventMeetupPoint.
  ///
  /// In en, this message translates to:
  /// **'Post-Event Meetup Point'**
  String get eventMeetupPoint;

  /// No description provided for @eventNoMeetupPoint.
  ///
  /// In en, this message translates to:
  /// **'No meetup point set yet'**
  String get eventNoMeetupPoint;

  /// No description provided for @eventSetMeetupPoint.
  ///
  /// In en, this message translates to:
  /// **'Set Meetup Point'**
  String get eventSetMeetupPoint;

  /// No description provided for @eventGroupChat.
  ///
  /// In en, this message translates to:
  /// **'Event Group Chat'**
  String get eventGroupChat;

  /// No description provided for @eventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found.'**
  String get eventNotFound;

  /// No description provided for @eventOrganizedThis.
  ///
  /// In en, this message translates to:
  /// **'You organized this event'**
  String get eventOrganizedThis;

  /// No description provided for @eventParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'Participants ({count})'**
  String eventParticipantsCount(int count);

  /// No description provided for @eventSeatsLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String eventSeatsLeftCount(int count);

  /// No description provided for @eventCountdownDaysHours.
  ///
  /// In en, this message translates to:
  /// **'In {days}d {hours}h'**
  String eventCountdownDaysHours(int days, int hours);

  /// No description provided for @eventCountdownHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {hours}h {minutes}m'**
  String eventCountdownHoursMinutes(int hours, int minutes);

  /// No description provided for @eventCountdownMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {minutes}m'**
  String eventCountdownMinutes(int minutes);

  /// No description provided for @eventNeedRideHome.
  ///
  /// In en, this message translates to:
  /// **'Need Ride Home'**
  String get eventNeedRideHome;

  /// No description provided for @eventFindRides.
  ///
  /// In en, this message translates to:
  /// **'Find Rides to Event'**
  String get eventFindRides;

  /// No description provided for @eventOfferRide.
  ///
  /// In en, this message translates to:
  /// **'Offer Ride to Event'**
  String get eventOfferRide;

  /// No description provided for @eventOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get eventOrganizer;

  /// No description provided for @myEventsCreatedTab.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get myEventsCreatedTab;

  /// No description provided for @myEventsJoinedTab.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get myEventsJoinedTab;

  /// No description provided for @signInFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in first.'**
  String get signInFirstMessage;

  /// No description provided for @unableToLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Unable to load events.'**
  String get unableToLoadEvents;

  /// No description provided for @noCreatedEvents.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any events yet.'**
  String get noCreatedEvents;

  /// No description provided for @noJoinedEvents.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined any events yet.'**
  String get noJoinedEvents;

  /// No description provided for @browseEventsButton.
  ///
  /// In en, this message translates to:
  /// **'Browse Events'**
  String get browseEventsButton;

  /// No description provided for @eventPastStatus.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get eventPastStatus;

  /// No description provided for @eventFullStatus.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get eventFullStatus;

  /// No description provided for @searchEventsHint.
  ///
  /// In en, this message translates to:
  /// **'Search events…'**
  String get searchEventsHint;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFound;

  /// No description provided for @noEventsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No upcoming {category} events.'**
  String noEventsInCategory(String category);

  /// No description provided for @beFirstToCreate.
  ///
  /// In en, this message translates to:
  /// **'Be the first to create one!'**
  String get beFirstToCreate;

  /// No description provided for @eventJoinArrow.
  ///
  /// In en, this message translates to:
  /// **'Join →'**
  String get eventJoinArrow;

  /// No description provided for @eventByOrganizer.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String eventByOrganizer(String name);

  /// No description provided for @createLabel.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createLabel;

  /// No description provided for @selectLocationError.
  ///
  /// In en, this message translates to:
  /// **'Please select a location.'**
  String get selectLocationError;

  /// No description provided for @pastStartTimeError.
  ///
  /// In en, this message translates to:
  /// **'Start time must be in the future.'**
  String get pastStartTimeError;

  /// No description provided for @endBeforeStartError.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get endBeforeStartError;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @legalVersionBadge.
  ///
  /// In en, this message translates to:
  /// **'Feb 2026'**
  String get legalVersionBadge;

  /// No description provided for @loadingTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Loading Terms of Service…'**
  String get loadingTermsOfService;

  /// No description provided for @loadingPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Loading Privacy Policy…'**
  String get loadingPrivacyPolicy;

  /// No description provided for @reportIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssueTitle;

  /// No description provided for @attachEvidence.
  ///
  /// In en, this message translates to:
  /// **'Attach evidence'**
  String get attachEvidence;

  /// No description provided for @whatHappenedQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappenedQuestion;

  /// No description provided for @howSevereQuestion.
  ///
  /// In en, this message translates to:
  /// **'How severe is this issue?'**
  String get howSevereQuestion;

  /// No description provided for @describeIssueLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get describeIssueLabel;

  /// No description provided for @describeIssuePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least 50 characters...'**
  String get describeIssuePlaceholder;

  /// No description provided for @evidenceOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence (optional)'**
  String get evidenceOptionalLabel;

  /// No description provided for @attachScreenshotsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to attach screenshots or evidence'**
  String get attachScreenshotsPlaceholder;

  /// No description provided for @filesAttachedCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} files attached'**
  String filesAttachedCount(int count, int max);

  /// No description provided for @supportsImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Supports images (max 10MB each)'**
  String get supportsImagesHint;

  /// No description provided for @submitReportButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReportButton;

  /// No description provided for @reportSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get reportSubmittedTitle;

  /// No description provided for @reportSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for reporting this issue. Our safety team will review it and take appropriate action within 24-48 hours. You will receive an email when your issue is resolved.'**
  String get reportSubmittedMessage;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @rideInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride: {id}'**
  String rideInfoLabel(String id);

  /// No description provided for @reportSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get reportSafety;

  /// No description provided for @reportSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Safety concerns or dangerous behavior'**
  String get reportSafetyDesc;

  /// No description provided for @reportPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get reportPayment;

  /// No description provided for @reportPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Billing or payment issues'**
  String get reportPaymentDesc;

  /// No description provided for @reportBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get reportBehavior;

  /// No description provided for @reportBehaviorDesc.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate or rude behavior'**
  String get reportBehaviorDesc;

  /// No description provided for @reportTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get reportTechnical;

  /// No description provided for @reportTechnicalDesc.
  ///
  /// In en, this message translates to:
  /// **'App bugs or technical issues'**
  String get reportTechnicalDesc;

  /// No description provided for @reportDiscrimination.
  ///
  /// In en, this message translates to:
  /// **'Discrimination'**
  String get reportDiscrimination;

  /// No description provided for @reportDiscriminationDesc.
  ///
  /// In en, this message translates to:
  /// **'Discriminatory treatment or harassment'**
  String get reportDiscriminationDesc;

  /// No description provided for @reportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportOther;

  /// No description provided for @reportOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Issues not listed above'**
  String get reportOtherDesc;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// No description provided for @driverMyRidesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get driverMyRidesTitle;

  /// No description provided for @viewRequestsTooltip.
  ///
  /// In en, this message translates to:
  /// **'View requests'**
  String get viewRequestsTooltip;

  /// No description provided for @pendingRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequestsTitle;

  /// No description provided for @noPendingRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequestsTitle;

  /// No description provided for @noPendingRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'New booking requests will appear here.'**
  String get noPendingRequestsMessage;

  /// No description provided for @upcomingRidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Rides'**
  String get upcomingRidesTitle;

  /// No description provided for @noUpcomingRidesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Rides'**
  String get noUpcomingRidesTitle;

  /// No description provided for @useButtonToOfferRide.
  ///
  /// In en, this message translates to:
  /// **'Use the button below to offer a new ride.'**
  String get useButtonToOfferRide;

  /// No description provided for @couldNotLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests. Pull to refresh.'**
  String get couldNotLoadRequests;

  /// No description provided for @couldNotLoadRides.
  ///
  /// In en, this message translates to:
  /// **'Could not load rides. Pull to refresh.'**
  String get couldNotLoadRides;

  /// No description provided for @declineRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline Request?'**
  String get declineRequestTitle;

  /// No description provided for @declineRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'This will decline the booking request. The passenger will be notified.'**
  String get declineRequestMessage;

  /// No description provided for @keepButton.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keepButton;

  /// No description provided for @declineButton.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineButton;

  /// No description provided for @acceptRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Request?'**
  String get acceptRequestTitle;

  /// No description provided for @acceptRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Accept this booking from {name}?'**
  String acceptRequestMessage(String name);

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @cancelRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRideTitle;

  /// No description provided for @cancelRideConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? This action cannot be undone.'**
  String get cancelRideConfirmMessage;

  /// No description provided for @keepRideButton.
  ///
  /// In en, this message translates to:
  /// **'Keep Ride'**
  String get keepRideButton;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupLabel;

  /// No description provided for @dropoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoffLabel;

  /// No description provided for @seatsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} seat(s)'**
  String seatsCount(int count);

  /// No description provided for @offerARideTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer a Ride'**
  String get offerARideTitle;

  /// No description provided for @editRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Ride'**
  String get editRideTitle;

  /// No description provided for @routeStep.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeStep;

  /// No description provided for @detailsStep.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsStep;

  /// No description provided for @preferencesStep.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesStep;

  /// No description provided for @driverProfileRequired.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile Required'**
  String get driverProfileRequired;

  /// No description provided for @completeDriverProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your driver profile to offer rides.'**
  String get completeDriverProfileMessage;

  /// No description provided for @becomeDriverButton.
  ///
  /// In en, this message translates to:
  /// **'Become a Driver'**
  String get becomeDriverButton;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @selectPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Select pickup location'**
  String get selectPickupLocation;

  /// No description provided for @selectDropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Select dropoff location'**
  String get selectDropoffLocation;

  /// No description provided for @swapLocationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Swap locations'**
  String get swapLocationsTooltip;

  /// No description provided for @departureTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTimeLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @selectDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDatePlaceholder;

  /// No description provided for @selectTimePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTimePlaceholder;

  /// No description provided for @intermediateStopsLabel.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Stops'**
  String get intermediateStopsLabel;

  /// No description provided for @addStopButton.
  ///
  /// In en, this message translates to:
  /// **'Add Stop'**
  String get addStopButton;

  /// No description provided for @addStopsHint.
  ///
  /// In en, this message translates to:
  /// **'Add stops along your route to pick up more passengers'**
  String get addStopsHint;

  /// No description provided for @rideDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetailsTitle;

  /// No description provided for @quickSwitchButton.
  ///
  /// In en, this message translates to:
  /// **'Quick Switch'**
  String get quickSwitchButton;

  /// No description provided for @noVehiclesError.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found. Please add a vehicle to your profile.'**
  String get noVehiclesError;

  /// No description provided for @addVehicleButton.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleButton;

  /// No description provided for @availableSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeatsLabel;

  /// No description provided for @totalCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Capacity:'**
  String get totalCapacityLabel;

  /// No description provided for @pricePerSeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per Seat'**
  String get pricePerSeatLabel;

  /// No description provided for @minimumPriceError.
  ///
  /// In en, this message translates to:
  /// **'Minimum €1'**
  String get minimumPriceError;

  /// No description provided for @priceNegotiableToggle.
  ///
  /// In en, this message translates to:
  /// **'Price Negotiable'**
  String get priceNegotiableToggle;

  /// No description provided for @acceptOnlinePaymentToggle.
  ///
  /// In en, this message translates to:
  /// **'Accept Online Payment'**
  String get acceptOnlinePaymentToggle;

  /// No description provided for @preferencesRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences & Rules'**
  String get preferencesRulesTitle;

  /// No description provided for @rideSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride Summary'**
  String get rideSummaryLabel;

  /// No description provided for @allowPetsToggle.
  ///
  /// In en, this message translates to:
  /// **'Allow Pets'**
  String get allowPetsToggle;

  /// No description provided for @allowSmokingToggle.
  ///
  /// In en, this message translates to:
  /// **'Allow Smoking'**
  String get allowSmokingToggle;

  /// No description provided for @allowLuggageToggle.
  ///
  /// In en, this message translates to:
  /// **'Allow Luggage'**
  String get allowLuggageToggle;

  /// No description provided for @womenOnlyToggle.
  ///
  /// In en, this message translates to:
  /// **'Women Only'**
  String get womenOnlyToggle;

  /// No description provided for @maxDetourLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Detour for Pickups'**
  String get maxDetourLabel;

  /// No description provided for @maxDetourHint.
  ///
  /// In en, this message translates to:
  /// **'How far you\'re willing to go off-route to pick up passengers'**
  String get maxDetourHint;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @sixtyMinLabel.
  ///
  /// In en, this message translates to:
  /// **'60 min'**
  String get sixtyMinLabel;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @createRideButton.
  ///
  /// In en, this message translates to:
  /// **'Create Ride'**
  String get createRideButton;

  /// No description provided for @recurringRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Ride'**
  String get recurringRideTitle;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @stopNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop {number}'**
  String stopNumberLabel(int number);

  /// No description provided for @tapToSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to set location'**
  String get tapToSetLocation;

  /// No description provided for @editWaypointTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit waypoint'**
  String get editWaypointTooltip;

  /// No description provided for @removeWaypointTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove waypoint'**
  String get removeWaypointTooltip;

  /// No description provided for @selectStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Stop {number}'**
  String selectStopTitle(int number);

  /// No description provided for @editStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Stop {number}'**
  String editStopTitle(int number);

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleLabel;

  /// No description provided for @totalCapacityCount.
  ///
  /// In en, this message translates to:
  /// **'Total Capacity: {count}'**
  String totalCapacityCount(int count);

  /// No description provided for @totalPriceForSeats.
  ///
  /// In en, this message translates to:
  /// **'Total: €{price} for {seats} seats'**
  String totalPriceForSeats(String price, int seats);

  /// No description provided for @decreasePriceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Decrease price'**
  String get decreasePriceTooltip;

  /// No description provided for @increasePriceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Increase price'**
  String get increasePriceTooltip;

  /// No description provided for @allowPetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pets are allowed in the car'**
  String get allowPetsSubtitle;

  /// No description provided for @allowSmokingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smoking is allowed during the ride'**
  String get allowSmokingSubtitle;

  /// No description provided for @allowLuggageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Passengers can bring luggage'**
  String get allowLuggageSubtitle;

  /// No description provided for @womenOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ride is for women only'**
  String get womenOnlySubtitle;

  /// No description provided for @notSetPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetPlaceholder;

  /// No description provided for @notSelectedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelectedPlaceholder;

  /// No description provided for @summaryStopsLabel.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get summaryStopsLabel;

  /// No description provided for @intermediateStopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 intermediate stop} other{{count} intermediate stops}}'**
  String intermediateStopsCount(int count);

  /// No description provided for @departureSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departureSummaryLabel;

  /// No description provided for @seatsSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seatsSummaryLabel;

  /// No description provided for @seatsAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String seatsAvailableCount(int count);

  /// No description provided for @priceSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceSummaryLabel;

  /// No description provided for @pricePerSeatSummary.
  ///
  /// In en, this message translates to:
  /// **'€{price} per seat'**
  String pricePerSeatSummary(String price);

  /// No description provided for @pricePerSeatNegotiableSummary.
  ///
  /// In en, this message translates to:
  /// **'€{price} per seat (negotiable)'**
  String pricePerSeatNegotiableSummary(String price);

  /// No description provided for @eventSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventSummaryLabel;

  /// No description provided for @recurringSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringSummaryLabel;

  /// No description provided for @selectOriginTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Origin'**
  String get selectOriginTitle;

  /// No description provided for @selectDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestinationTitle;

  /// No description provided for @maxDetourMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String maxDetourMinutesValue(int minutes);

  /// No description provided for @timeInPastWarning.
  ///
  /// In en, this message translates to:
  /// **'Selected time is in the past — the Create Ride button will be disabled'**
  String get timeInPastWarning;

  /// No description provided for @departureMinimumWarning.
  ///
  /// In en, this message translates to:
  /// **'Departure should be at least 15 minutes from now for passengers to join'**
  String get departureMinimumWarning;

  /// No description provided for @departureAfterEventWarning.
  ///
  /// In en, this message translates to:
  /// **'Departure time is after the event ends — please choose an earlier time'**
  String get departureAfterEventWarning;

  /// No description provided for @rideUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ride updated successfully!'**
  String get rideUpdatedSuccess;

  /// No description provided for @rideCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ride created successfully!'**
  String get rideCreatedSuccess;

  /// No description provided for @bookingRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Request'**
  String get bookingRequestTitle;

  /// No description provided for @requestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get requestSentTitle;

  /// No description provided for @bookingAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Accepted!'**
  String get bookingAcceptedTitle;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the driver to confirm your booking. You\'ll be notified as soon as they respond.'**
  String get waitingForConfirmation;

  /// No description provided for @completePaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment to confirm the ride.'**
  String get completePaymentMessage;

  /// No description provided for @processingPaymentLoading.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPaymentLoading;

  /// No description provided for @completePaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePaymentButton;

  /// No description provided for @expiresInLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get expiresInLabel;

  /// No description provided for @cancelRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequestButton;

  /// No description provided for @viewAllMyRidesButton.
  ///
  /// In en, this message translates to:
  /// **'View All My Rides'**
  String get viewAllMyRidesButton;

  /// No description provided for @yourDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Driver'**
  String get yourDriverLabel;

  /// No description provided for @yourRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Ride'**
  String get yourRideTitle;

  /// No description provided for @bookingConfirmedBadge.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmedBadge;

  /// No description provided for @departureInLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure in'**
  String get departureInLabel;

  /// No description provided for @departingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Departing soon!'**
  String get departingSoonLabel;

  /// No description provided for @rideStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ride has started!'**
  String get rideStartedMessage;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @messageButton.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageButton;

  /// No description provided for @passengerRequestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 passenger request} other{{count} passenger requests}}'**
  String passengerRequestCount(num count);

  /// No description provided for @callButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// No description provided for @failedOpenChatError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat. Please try again.'**
  String get failedOpenChatError;

  /// No description provided for @driverPhoneUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Driver phone number not available.'**
  String get driverPhoneUnavailableError;

  /// No description provided for @couldNotLaunchDialerError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer.'**
  String get couldNotLaunchDialerError;

  /// No description provided for @seatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seatsLabel;

  /// No description provided for @refNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Ref #'**
  String get refNumberLabel;

  /// No description provided for @tapToCopyInstruction.
  ///
  /// In en, this message translates to:
  /// **'(tap to copy)'**
  String get tapToCopyInstruction;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @estimatedArrivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Est. arrival:'**
  String get estimatedArrivalLabel;

  /// No description provided for @joinActiveRideButton.
  ///
  /// In en, this message translates to:
  /// **'Join Active Ride'**
  String get joinActiveRideButton;

  /// No description provided for @viewRideDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Ride Details'**
  String get viewRideDetailsButton;

  /// No description provided for @fileDisputeTitle.
  ///
  /// In en, this message translates to:
  /// **'File a Dispute'**
  String get fileDisputeTitle;

  /// No description provided for @rideIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride ID'**
  String get rideIdLabel;

  /// No description provided for @disputeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dispute Type'**
  String get disputeTypeLabel;

  /// No description provided for @selectDisputeReason.
  ///
  /// In en, this message translates to:
  /// **'Select the reason for your dispute'**
  String get selectDisputeReason;

  /// No description provided for @incorrectFareType.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Fare'**
  String get incorrectFareType;

  /// No description provided for @incorrectFareDesc.
  ///
  /// In en, this message translates to:
  /// **'The fare charged was different from the quoted amount'**
  String get incorrectFareDesc;

  /// No description provided for @incompleteRideType.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Ride'**
  String get incompleteRideType;

  /// No description provided for @incompleteRideDesc.
  ///
  /// In en, this message translates to:
  /// **'The ride did not reach the intended destination'**
  String get incompleteRideDesc;

  /// No description provided for @unauthorizedChargeType.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Charge'**
  String get unauthorizedChargeType;

  /// No description provided for @unauthorizedChargeDesc.
  ///
  /// In en, this message translates to:
  /// **'I was charged without authorization or for a cancelled ride'**
  String get unauthorizedChargeDesc;

  /// No description provided for @poorServiceType.
  ///
  /// In en, this message translates to:
  /// **'Poor Service'**
  String get poorServiceType;

  /// No description provided for @poorServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'The ride quality was unacceptable'**
  String get poorServiceDesc;

  /// No description provided for @safetyConcernType.
  ///
  /// In en, this message translates to:
  /// **'Safety Concern'**
  String get safetyConcernType;

  /// No description provided for @safetyConcernDesc.
  ///
  /// In en, this message translates to:
  /// **'I felt unsafe during the ride'**
  String get safetyConcernDesc;

  /// No description provided for @otherDisputeType.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherDisputeType;

  /// No description provided for @otherDisputeDesc.
  ///
  /// In en, this message translates to:
  /// **'A different issue not listed above'**
  String get otherDisputeDesc;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsLabel;

  /// No description provided for @describeIssueDetailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue in detail...'**
  String get describeIssueDetailPlaceholder;

  /// No description provided for @disputeWarningNote.
  ///
  /// In en, this message translates to:
  /// **'Disputes are reviewed within 24-48 hours. Submitting false disputes may result in account restrictions.'**
  String get disputeWarningNote;

  /// No description provided for @attachReceiptsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Attach receipts or screenshots'**
  String get attachReceiptsPlaceholder;

  /// No description provided for @whatToExpectTitle.
  ///
  /// In en, this message translates to:
  /// **'What to expect'**
  String get whatToExpectTitle;

  /// No description provided for @reviewWithinHours.
  ///
  /// In en, this message translates to:
  /// **'Review within 24-48 hours'**
  String get reviewWithinHours;

  /// No description provided for @emailNotificationExpectation.
  ///
  /// In en, this message translates to:
  /// **'Email notification on status updates'**
  String get emailNotificationExpectation;

  /// No description provided for @fairResolutionExpectation.
  ///
  /// In en, this message translates to:
  /// **'Fair resolution based on evidence'**
  String get fairResolutionExpectation;

  /// No description provided for @submitDisputeButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Dispute'**
  String get submitDisputeButton;

  /// No description provided for @disputeSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispute Submitted'**
  String get disputeSubmittedTitle;

  /// No description provided for @disputeSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Our team will review your dispute within 24-48 hours. You\'ll receive a notification once it\'s resolved.'**
  String get disputeSubmittedMessage;

  /// No description provided for @previousStepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get previousStepTooltip;

  /// No description provided for @goBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBackTooltip;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequiredError;

  /// No description provided for @nameMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLengthError;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @emailVerificationError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get emailVerificationError;

  /// No description provided for @useDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get useDifferentAccount;

  /// No description provided for @builtWithFlutter.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter'**
  String get builtWithFlutter;

  /// No description provided for @showPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPasswordTooltip;

  /// No description provided for @hidePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePasswordTooltip;

  /// No description provided for @signingInMessage.
  ///
  /// In en, this message translates to:
  /// **'Signing in, please wait'**
  String get signingInMessage;

  /// No description provided for @loadingProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait, loading your profile...'**
  String get loadingProfileMessage;

  /// No description provided for @riderOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rider onboarding'**
  String get riderOnboardingTitle;

  /// No description provided for @completeRiderProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your rider profile'**
  String get completeRiderProfile;

  /// No description provided for @riderProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your details so we can personalize rides and matching for you.'**
  String get riderProfileDescription;

  /// No description provided for @completeSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Complete setup'**
  String get completeSetupButton;

  /// No description provided for @riderRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Find and book rides to sporting events. Save money and reduce your carbon footprint.'**
  String get riderRoleDescription;

  /// No description provided for @riderFeatureSearch.
  ///
  /// In en, this message translates to:
  /// **'Search available rides'**
  String get riderFeatureSearch;

  /// No description provided for @riderFeatureBook.
  ///
  /// In en, this message translates to:
  /// **'Book seats instantly'**
  String get riderFeatureBook;

  /// No description provided for @riderFeatureChat.
  ///
  /// In en, this message translates to:
  /// **'Chat with drivers'**
  String get riderFeatureChat;

  /// No description provided for @riderFeatureTrack.
  ///
  /// In en, this message translates to:
  /// **'Track your ride'**
  String get riderFeatureTrack;

  /// No description provided for @driverRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Offer rides and earn money while going to events. Help others get there safely.'**
  String get driverRoleDescription;

  /// No description provided for @driverFeatureCreate.
  ///
  /// In en, this message translates to:
  /// **'Create ride offers'**
  String get driverFeatureCreate;

  /// No description provided for @driverFeaturePrice.
  ///
  /// In en, this message translates to:
  /// **'Set your own price'**
  String get driverFeaturePrice;

  /// No description provided for @driverFeatureAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept ride requests'**
  String get driverFeatureAccept;

  /// No description provided for @driverFeatureEarn.
  ///
  /// In en, this message translates to:
  /// **'Earn with each trip'**
  String get driverFeatureEarn;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @yourDetailsStep.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get yourDetailsStep;

  /// No description provided for @securityStep.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityStep;

  /// No description provided for @yourRoleStep.
  ///
  /// In en, this message translates to:
  /// **'Your Role'**
  String get yourRoleStep;

  /// No description provided for @yourProfileStep.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfileStep;

  /// No description provided for @stepOfCount.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOfCount(int step, int total);

  /// No description provided for @searchUsersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsersTooltip;

  /// No description provided for @muteChat.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get muteChat;

  /// No description provided for @unmuteChat.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmuteChat;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteChat;

  /// No description provided for @paymentDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get paymentDetailsLabel;

  /// No description provided for @ridePaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride Payment'**
  String get ridePaymentLabel;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'SportConnect is a social carpooling platform that connects sports enthusiasts. Share rides, reduce your carbon footprint, and build your sports community.'**
  String get aboutAppDescription;

  /// No description provided for @ecoStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get ecoStatLabel;

  /// No description provided for @liveStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveStatLabel;

  /// No description provided for @sportStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sportStatLabel;

  /// No description provided for @rideShareLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride-Share'**
  String get rideShareLabel;

  /// No description provided for @trackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingLabel;

  /// No description provided for @communityLabel.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityLabel;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @joinTheCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get joinTheCommunity;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @copyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© 2025-2026 SportConnect. All rights reserved.'**
  String get copyrightNotice;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get howCanWeHelp;

  /// No description provided for @responseTimeMessage.
  ///
  /// In en, this message translates to:
  /// **'We typically respond within 24 hours.'**
  String get responseTimeMessage;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of your issue'**
  String get subjectHint;

  /// No description provided for @messageFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageFieldLabel;

  /// No description provided for @messageFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue in detail...'**
  String get messageFieldHint;

  /// No description provided for @attachFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Attach screenshots or files (optional)'**
  String get attachFilesHint;

  /// No description provided for @submitTicketButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicketButton;

  /// No description provided for @responseTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'Most inquiries are answered within 12-24 hours'**
  String get responseTimeInfo;

  /// No description provided for @ticketSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Submitted!'**
  String get ticketSubmittedTitle;

  /// No description provided for @ticketSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve received your message and will get back to you within 24 hours. You will receive an email when your issue is resolved.'**
  String get ticketSubmittedMessage;

  /// No description provided for @findPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Find People'**
  String get findPeopleTitle;

  /// No description provided for @searchByNameHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByNameHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @asDriverFilter.
  ///
  /// In en, this message translates to:
  /// **'As Driver'**
  String get asDriverFilter;

  /// No description provided for @asRiderFilter.
  ///
  /// In en, this message translates to:
  /// **'As Rider'**
  String get asRiderFilter;

  /// No description provided for @additionalCommentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get additionalCommentsLabel;

  /// No description provided for @specificFeedbackHelps.
  ///
  /// In en, this message translates to:
  /// **'Specific feedback helps the community'**
  String get specificFeedbackHelps;

  /// No description provided for @thankYouForReview.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankYouForReview;

  /// No description provided for @submitRatingButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRatingButton;

  /// No description provided for @skipForNowButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNowButton;

  /// No description provided for @navigateButton.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigateButton;

  /// No description provided for @noActiveRideMessage.
  ///
  /// In en, this message translates to:
  /// **'No active ride'**
  String get noActiveRideMessage;

  /// No description provided for @ratePassengerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate Passenger'**
  String get ratePassengerTitle;

  /// No description provided for @howWasYourPassenger.
  ///
  /// In en, this message translates to:
  /// **'How was your passenger?'**
  String get howWasYourPassenger;

  /// No description provided for @cancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledLabel;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @scheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @cancellationReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get cancellationReasonTitle;

  /// No description provided for @cancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about why you\'re cancelling...'**
  String get cancellationReasonHint;

  /// No description provided for @confirmCancellationButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellationButton;

  /// No description provided for @rideCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed!'**
  String get rideCompletedTitle;

  /// No description provided for @rideCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get rideCompletedSubtitle;

  /// No description provided for @rideNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Navigation'**
  String get rideNavigationTitle;

  /// No description provided for @startNavigationButton.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigationButton;

  /// No description provided for @arriveAtPickupButton.
  ///
  /// In en, this message translates to:
  /// **'Arrive at Pickup'**
  String get arriveAtPickupButton;

  /// No description provided for @startTripButton.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTripButton;

  /// No description provided for @endTripButton.
  ///
  /// In en, this message translates to:
  /// **'End Trip'**
  String get endTripButton;

  /// No description provided for @passengerPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Passenger pickup'**
  String get passengerPickupLabel;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @supportCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get supportCategoryGeneral;

  /// No description provided for @supportCategoryAccountIssue.
  ///
  /// In en, this message translates to:
  /// **'Account Issue'**
  String get supportCategoryAccountIssue;

  /// No description provided for @supportCategoryPaymentProblem.
  ///
  /// In en, this message translates to:
  /// **'Payment Problem'**
  String get supportCategoryPaymentProblem;

  /// No description provided for @supportCategoryRideIssue.
  ///
  /// In en, this message translates to:
  /// **'Ride Issue'**
  String get supportCategoryRideIssue;

  /// No description provided for @supportCategoryTechnicalBug.
  ///
  /// In en, this message translates to:
  /// **'Technical Bug'**
  String get supportCategoryTechnicalBug;

  /// No description provided for @supportCategorySafetyReport.
  ///
  /// In en, this message translates to:
  /// **'Safety Report'**
  String get supportCategorySafetyReport;

  /// No description provided for @supportCategoryFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get supportCategoryFeatureRequest;

  /// No description provided for @driversLabel.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driversLabel;

  /// No description provided for @ridersLabel.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get ridersLabel;

  /// No description provided for @sportsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sportsLabel;

  /// No description provided for @yourJourneyStartsHere.
  ///
  /// In en, this message translates to:
  /// **'Your Journey Starts Here'**
  String get yourJourneyStartsHere;

  /// No description provided for @searchRidesAndConnect.
  ///
  /// In en, this message translates to:
  /// **'Search for rides and connect with verified drivers heading your way'**
  String get searchRidesAndConnect;

  /// No description provided for @searchForRides.
  ///
  /// In en, this message translates to:
  /// **'Search for Rides'**
  String get searchForRides;

  /// No description provided for @easyBooking.
  ///
  /// In en, this message translates to:
  /// **'Easy Booking'**
  String get easyBooking;

  /// No description provided for @bookInJustAFewTaps.
  ///
  /// In en, this message translates to:
  /// **'Book in just a few taps'**
  String get bookInJustAFewTaps;

  /// No description provided for @realTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Real-time Tracking'**
  String get realTimeTracking;

  /// No description provided for @trackYourRideLive.
  ///
  /// In en, this message translates to:
  /// **'Track your ride live'**
  String get trackYourRideLive;

  /// No description provided for @startSharingTheRoad.
  ///
  /// In en, this message translates to:
  /// **'Start Sharing the Road'**
  String get startSharingTheRoad;

  /// No description provided for @offerFirstRideMessage.
  ///
  /// In en, this message translates to:
  /// **'Offer your first ride and connect with riders heading your way'**
  String get offerFirstRideMessage;

  /// No description provided for @connectWithRiders.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectWithRiders;

  /// No description provided for @earnPerRide.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earnPerRide;

  /// No description provided for @flexibleSchedule.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexibleSchedule;

  /// No description provided for @offerYourFirstRide.
  ///
  /// In en, this message translates to:
  /// **'Offer Your First Ride'**
  String get offerYourFirstRide;

  /// No description provided for @noRidesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Rides Yet'**
  String get noRidesYetTitle;

  /// No description provided for @noRidesYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a carpool to your next game, practice, or event. Share the ride, split the cost.'**
  String get noRidesYetSubtitle;

  /// No description provided for @findACarpoolNow.
  ///
  /// In en, this message translates to:
  /// **'Find a Carpool'**
  String get findACarpoolNow;

  /// No description provided for @allDriversVerifiedAndRated.
  ///
  /// In en, this message translates to:
  /// **'All drivers are verified and rated'**
  String get allDriversVerifiedAndRated;

  /// No description provided for @levelAndXp.
  ///
  /// In en, this message translates to:
  /// **'Level & XP'**
  String get levelAndXp;

  /// No description provided for @viewAchievements.
  ///
  /// In en, this message translates to:
  /// **'View achievements'**
  String get viewAchievements;

  /// No description provided for @maxLevel.
  ///
  /// In en, this message translates to:
  /// **'Max Level Reached!'**
  String get maxLevel;

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get challengeCompleted;

  /// No description provided for @challengeInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get challengeInProgress;

  /// No description provided for @challengeFirstRide.
  ///
  /// In en, this message translates to:
  /// **'First Ride'**
  String get challengeFirstRide;

  /// No description provided for @challengeFirstRideDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first carpool ride'**
  String get challengeFirstRideDesc;

  /// No description provided for @challengeRideRegular.
  ///
  /// In en, this message translates to:
  /// **'Ride Regular'**
  String get challengeRideRegular;

  /// No description provided for @challengeRideRegularDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 rides'**
  String get challengeRideRegularDesc;

  /// No description provided for @challengeRoadTripper.
  ///
  /// In en, this message translates to:
  /// **'Road Tripper'**
  String get challengeRoadTripper;

  /// No description provided for @challengeRoadTripperDesc.
  ///
  /// In en, this message translates to:
  /// **'Travel 50 km total'**
  String get challengeRoadTripperDesc;

  /// No description provided for @challengeDistanceMaster.
  ///
  /// In en, this message translates to:
  /// **'Distance Master'**
  String get challengeDistanceMaster;

  /// No description provided for @challengeDistanceMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Travel 100 km total'**
  String get challengeDistanceMasterDesc;

  /// No description provided for @challengeStreakBuilder.
  ///
  /// In en, this message translates to:
  /// **'Streak Builder'**
  String get challengeStreakBuilder;

  /// No description provided for @challengeStreakBuilderDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day ride streak'**
  String get challengeStreakBuilderDesc;

  /// No description provided for @challengeCenturyRider.
  ///
  /// In en, this message translates to:
  /// **'Century Rider'**
  String get challengeCenturyRider;

  /// No description provided for @challengeCenturyRiderDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 rides'**
  String get challengeCenturyRiderDesc;

  /// No description provided for @chatMuted.
  ///
  /// In en, this message translates to:
  /// **'Chat muted'**
  String get chatMuted;

  /// No description provided for @chatUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Chat unmuted'**
  String get chatUnmuted;

  /// No description provided for @deleteConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get deleteConversationTitle;

  /// No description provided for @deleteConversationMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove the conversation from your list.'**
  String get deleteConversationMessage;

  /// No description provided for @conversationRemoved.
  ///
  /// In en, this message translates to:
  /// **'Conversation removed'**
  String get conversationRemoved;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// No description provided for @creatingChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Creating chat'**
  String get creatingChatLabel;

  /// No description provided for @failedToCreateChatTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat. Please try again.'**
  String get failedToCreateChatTryAgain;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @blockUserDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserDialogTitle;

  /// No description provided for @blockUserDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Block {name}? You will no longer receive messages from this user.'**
  String blockUserDialogMessage(String name);

  /// No description provided for @blockUserDialogMessageGeneric.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user? You will no longer see their content or receive messages from them.'**
  String get blockUserDialogMessageGeneric;

  /// No description provided for @blockedUserSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked.'**
  String blockedUserSuccess(String name);

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User has been blocked.'**
  String get userBlocked;

  /// No description provided for @couldNotBlockUserTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not block user. Please try again.'**
  String get couldNotBlockUserTryAgain;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get unblockUser;

  /// No description provided for @unblockUserDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}?'**
  String unblockUserDialogMessage(String name);

  /// No description provided for @actionUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get actionUnblock;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked.'**
  String get userUnblocked;

  /// No description provided for @couldNotUnblockUserTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not unblock user. Please try again.'**
  String get couldNotUnblockUserTryAgain;

  /// No description provided for @youBlockedThisUser.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user.'**
  String get youBlockedThisUser;

  /// No description provided for @actionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get actionBlock;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @notificationsAlreadyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are already enabled.'**
  String get notificationsAlreadyEnabled;

  /// No description provided for @notificationPermissionRequested.
  ///
  /// In en, this message translates to:
  /// **'Notification permission requested.'**
  String get notificationPermissionRequested;

  /// No description provided for @pauseDriverAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Pause Driver Account?'**
  String get pauseDriverAccountQuestion;

  /// No description provided for @pauseDriverAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving ride requests until you resume. Your profile and reviews will remain visible.'**
  String get pauseDriverAccountMessage;

  /// No description provided for @driverAccountPaused.
  ///
  /// In en, this message translates to:
  /// **'Driver account paused'**
  String get driverAccountPaused;

  /// No description provided for @pauseAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Pause Account'**
  String get pauseAccountAction;

  /// No description provided for @syncProfile.
  ///
  /// In en, this message translates to:
  /// **'Sync Profile'**
  String get syncProfile;

  /// No description provided for @eventUnableToLoadOriginal.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the original event.'**
  String get eventUnableToLoadOriginal;

  /// No description provided for @eventUnableToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Unable to update event. Please try again.'**
  String get eventUnableToUpdate;

  /// No description provided for @eventSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get eventSignInRequired;

  /// No description provided for @supportCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get supportCategoryOther;

  /// No description provided for @averageResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Average response time'**
  String get averageResponseTime;

  /// No description provided for @backToSettings.
  ///
  /// In en, this message translates to:
  /// **'Back to Settings'**
  String get backToSettings;

  /// No description provided for @couldNotClearChatTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not clear chat. Please try again.'**
  String get couldNotClearChatTryAgain;

  /// No description provided for @sendEmoji.
  ///
  /// In en, this message translates to:
  /// **'Send Emoji'**
  String get sendEmoji;

  /// No description provided for @sendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send Photo'**
  String get sendPhoto;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @clearReply.
  ///
  /// In en, this message translates to:
  /// **'Clear reply'**
  String get clearReply;

  /// No description provided for @messageFromLongPressOptions.
  ///
  /// In en, this message translates to:
  /// **'Message from {name}. Long press for options'**
  String messageFromLongPressOptions(String name);

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// No description provided for @showKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Show keyboard'**
  String get showKeyboard;

  /// No description provided for @showEmojiPicker.
  ///
  /// In en, this message translates to:
  /// **'Show emoji picker'**
  String get showEmojiPicker;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter {value}'**
  String pleaseEnterValue(String value);

  /// No description provided for @uploadVehiclePhotoPermission.
  ///
  /// In en, this message translates to:
  /// **'Access to your photo library is needed to upload a photo of your vehicle.'**
  String get uploadVehiclePhotoPermission;

  /// No description provided for @driverVehicleStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your car so riders know what to expect.'**
  String get driverVehicleStepSubtitle;

  /// No description provided for @vehicleMakeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Toyota, Honda, BMW'**
  String get vehicleMakeHint;

  /// No description provided for @pleaseEnterVehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle make'**
  String get pleaseEnterVehicleMake;

  /// No description provided for @vehicleModelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Corolla, Civic, 3 Series'**
  String get vehicleModelHint;

  /// No description provided for @pleaseEnterVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle model'**
  String get pleaseEnterVehicleModel;

  /// No description provided for @vehicleYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2020'**
  String get vehicleYearHint;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @vehicleColorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., White'**
  String get vehicleColorHint;

  /// No description provided for @licensePlateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., ABC 123'**
  String get licensePlateHint;

  /// No description provided for @licensePlateHelperText.
  ///
  /// In en, this message translates to:
  /// **'2-12 characters, letters & numbers'**
  String get licensePlateHelperText;

  /// No description provided for @pleaseEnterLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Please enter license plate'**
  String get pleaseEnterLicensePlate;

  /// No description provided for @pleaseEnterNumberOfSeats.
  ///
  /// In en, this message translates to:
  /// **'Please enter number of seats'**
  String get pleaseEnterNumberOfSeats;

  /// No description provided for @mustBeWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a whole number'**
  String get mustBeWholeNumber;

  /// No description provided for @enter1To8Seats.
  ///
  /// In en, this message translates to:
  /// **'Enter 1-8 seats'**
  String get enter1To8Seats;

  /// No description provided for @driverStripeStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account to receive payments from your rides.'**
  String get driverStripeStepSubtitle;

  /// No description provided for @stripePoweredByMillions.
  ///
  /// In en, this message translates to:
  /// **'Powered by Stripe, trusted by millions'**
  String get stripePoweredByMillions;

  /// No description provided for @stripeFastTransfersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get paid within 2-3 business days'**
  String get stripeFastTransfersDesc;

  /// No description provided for @stripeEarningsDesc.
  ///
  /// In en, this message translates to:
  /// **'View all your earnings in one place'**
  String get stripeEarningsDesc;

  /// No description provided for @connectWithStripe.
  ///
  /// In en, this message translates to:
  /// **'Connect with Stripe'**
  String get connectWithStripe;

  /// No description provided for @legalConsentPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get legalConsentPrefix;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @andConnector.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andConnector;

  /// No description provided for @termsLinkSemantics.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service, link'**
  String get termsLinkSemantics;

  /// No description provided for @privacyLinkSemantics.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy, link'**
  String get privacyLinkSemantics;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @searchHelpArticles.
  ///
  /// In en, this message translates to:
  /// **'Search help articles...'**
  String get searchHelpArticles;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @closeRouteInfo.
  ///
  /// In en, this message translates to:
  /// **'Close route info'**
  String get closeRouteInfo;

  /// No description provided for @requestDataExport.
  ///
  /// In en, this message translates to:
  /// **'Request Data Export'**
  String get requestDataExport;

  /// No description provided for @withdrawConsent.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Consent'**
  String get withdrawConsent;

  /// No description provided for @downloadMyData.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// No description provided for @downloadMyDataDescription.
  ///
  /// In en, this message translates to:
  /// **'We will prepare a copy of your personal data including your profile, ride history, and reviews. You will receive an email with a download link within 48 hours.'**
  String get downloadMyDataDescription;

  /// No description provided for @dataProcessingNotice.
  ///
  /// In en, this message translates to:
  /// **'Data Processing Notice'**
  String get dataProcessingNotice;

  /// No description provided for @withdrawConsentDescription.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your consent for data processing in the following ways:'**
  String get withdrawConsentDescription;

  /// No description provided for @dataExportRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Data export request submitted.'**
  String get dataExportRequestSubmitted;

  /// No description provided for @deleteKeyword.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteKeyword;

  /// No description provided for @submitReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReviewButton;

  /// No description provided for @pleaseSelectRatingToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating to submit'**
  String get pleaseSelectRatingToSubmit;

  /// No description provided for @unknownDriver.
  ///
  /// In en, this message translates to:
  /// **'Unknown Driver'**
  String get unknownDriver;

  /// No description provided for @errorLoadingDriver.
  ///
  /// In en, this message translates to:
  /// **'Error loading driver'**
  String get errorLoadingDriver;

  /// No description provided for @passengerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Passenger not found'**
  String get passengerNotFound;

  /// No description provided for @errorLoadingPassenger.
  ///
  /// In en, this message translates to:
  /// **'Error loading passenger'**
  String get errorLoadingPassenger;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @notAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableShort;

  /// No description provided for @permissionLocationAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get permissionLocationAccessTitle;

  /// No description provided for @permissionLocationAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'SportConnect needs your location to show nearby rides, calculate distances, and provide accurate navigation during your trips.'**
  String get permissionLocationAccessMessage;

  /// No description provided for @permissionShareLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Location'**
  String get permissionShareLocationTitle;

  /// No description provided for @permissionShareLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current location will be shared with this chat so other participants can see where you are. Your location is only shared when you choose to send it.'**
  String get permissionShareLocationMessage;

  /// No description provided for @permissionRideNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access Required'**
  String get permissionRideNavigationTitle;

  /// No description provided for @permissionRideNavigationMessage.
  ///
  /// In en, this message translates to:
  /// **'SportConnect uses your location while you use the app to show live trip progress, detect pickup and drop-off arrival, and help coordinate rides. It is not used for background tracking.'**
  String get permissionRideNavigationMessage;

  /// No description provided for @permissionCameraPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera & Photos'**
  String get permissionCameraPhotosTitle;

  /// No description provided for @permissionCameraPhotosMessage.
  ///
  /// In en, this message translates to:
  /// **'Access to your camera and photo library is needed to attach images. Your photos are only uploaded when you explicitly choose to share them.'**
  String get permissionCameraPhotosMessage;

  /// No description provided for @permissionStayUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Updated'**
  String get permissionStayUpdatedTitle;

  /// No description provided for @permissionStayUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive ride updates, messages from other riders, booking confirmations, and important safety alerts.'**
  String get permissionStayUpdatedMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @rideOptions.
  ///
  /// In en, this message translates to:
  /// **'Ride options'**
  String get rideOptions;

  /// No description provided for @messagePassenger.
  ///
  /// In en, this message translates to:
  /// **'Message passenger'**
  String get messagePassenger;

  /// No description provided for @passengerOptions.
  ///
  /// In en, this message translates to:
  /// **'Passenger options'**
  String get passengerOptions;

  /// No description provided for @markNoShow.
  ///
  /// In en, this message translates to:
  /// **'Mark no-show'**
  String get markNoShow;

  /// No description provided for @messageDriver.
  ///
  /// In en, this message translates to:
  /// **'Message driver'**
  String get messageDriver;

  /// No description provided for @chatWithDriver.
  ///
  /// In en, this message translates to:
  /// **'Chat with driver'**
  String get chatWithDriver;

  /// No description provided for @chatWithPassenger.
  ///
  /// In en, this message translates to:
  /// **'Chat with passenger'**
  String get chatWithPassenger;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call driver'**
  String get callDriver;

  /// No description provided for @closePassengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Close passenger details'**
  String get closePassengerDetails;

  /// No description provided for @rideRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Ride request details'**
  String get rideRequestDetails;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @driverArrivingIn.
  ///
  /// In en, this message translates to:
  /// **'Driver arriving in ~{minutes} min'**
  String driverArrivingIn(int minutes);

  /// No description provided for @estimatedWait.
  ///
  /// In en, this message translates to:
  /// **'Est. wait: ~{minutes} min'**
  String estimatedWait(int minutes);

  /// No description provided for @customPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Custom pickup point'**
  String get customPickupPoint;

  /// No description provided for @dropPinForPickup.
  ///
  /// In en, this message translates to:
  /// **'Drop a pin for pickup'**
  String get dropPinForPickup;

  /// No description provided for @clearPin.
  ///
  /// In en, this message translates to:
  /// **'Clear pin'**
  String get clearPin;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set Pin'**
  String get setPin;

  /// No description provided for @markNoShowPrompt.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as a no-show? This will be recorded and may affect their rating.'**
  String markNoShowPrompt(String name);

  /// No description provided for @switchVehicle.
  ///
  /// In en, this message translates to:
  /// **'Switch vehicle'**
  String get switchVehicle;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @cloneThisRide.
  ///
  /// In en, this message translates to:
  /// **'Clone This Ride'**
  String get cloneThisRide;

  /// No description provided for @howWasYourRide.
  ///
  /// In en, this message translates to:
  /// **'How was your ride?'**
  String get howWasYourRide;

  /// No description provided for @rateYourExperienceWith.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with {name}'**
  String rateYourExperienceWith(String name);

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report incident'**
  String get reportIncident;

  /// No description provided for @incidentType.
  ///
  /// In en, this message translates to:
  /// **'Type of incident'**
  String get incidentType;

  /// No description provided for @describeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened...'**
  String get describeWhatHappened;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid: {amount}'**
  String amountPaid(String amount);

  /// No description provided for @reasonForRefund.
  ///
  /// In en, this message translates to:
  /// **'Reason for refund'**
  String get reasonForRefund;

  /// No description provided for @additionalDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get additionalDetailsOptional;

  /// No description provided for @submitRefundRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Refund Request'**
  String get submitRefundRequest;

  /// No description provided for @rideSummary.
  ///
  /// In en, this message translates to:
  /// **'Ride summary'**
  String get rideSummary;

  /// No description provided for @expandedView.
  ///
  /// In en, this message translates to:
  /// **'Expanded view'**
  String get expandedView;

  /// No description provided for @compactView.
  ///
  /// In en, this message translates to:
  /// **'Compact view'**
  String get compactView;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get pickOnMap;

  /// No description provided for @searchCountryOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search country or code...'**
  String get searchCountryOrCode;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @safetyCheckInConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Safety check-in confirmed!'**
  String get safetyCheckInConfirmed;

  /// No description provided for @markAsNoShowQuestion.
  ///
  /// In en, this message translates to:
  /// **'Mark as No-Show?'**
  String get markAsNoShowQuestion;

  /// No description provided for @markNoShowDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will cancel {passengerId}\'s booking and notify them. You will have 30 seconds to undo.'**
  String markNoShowDialogMessage(String passengerId);

  /// No description provided for @passengerMarkedNoShow.
  ///
  /// In en, this message translates to:
  /// **'Passenger marked as no-show'**
  String get passengerMarkedNoShow;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @requestedStop.
  ///
  /// In en, this message translates to:
  /// **'Requested stop'**
  String get requestedStop;

  /// No description provided for @createReturnRideQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create Return Ride?'**
  String get createReturnRideQuestion;

  /// No description provided for @createReturnRideMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you like to create a return ride from {destination} back to {origin}?'**
  String createReturnRideMessage(String destination, String origin);

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get noThanks;

  /// No description provided for @returnRideCreated.
  ///
  /// In en, this message translates to:
  /// **'Return ride created!'**
  String get returnRideCreated;

  /// No description provided for @createReturnRide.
  ///
  /// In en, this message translates to:
  /// **'Create Return Ride'**
  String get createReturnRide;

  /// No description provided for @confirmDeparture.
  ///
  /// In en, this message translates to:
  /// **'Confirm Departure'**
  String get confirmDeparture;

  /// No description provided for @allPassengersPickedUpConfirm.
  ///
  /// In en, this message translates to:
  /// **'All passengers picked up? You will begin driving to the destination.'**
  String get allPassengersPickedUpConfirm;

  /// No description provided for @departNow.
  ///
  /// In en, this message translates to:
  /// **'Depart Now'**
  String get departNow;

  /// No description provided for @passengerProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Passenger profile not found'**
  String get passengerProfileNotFound;

  /// No description provided for @failedToOpenChatTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat. Please try again.'**
  String get failedToOpenChatTryAgain;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergencySos;

  /// No description provided for @sosShareConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'This will share your ride details and current location with your contacts. Continue?'**
  String get sosShareConfirmationMessage;

  /// No description provided for @shareSos.
  ///
  /// In en, this message translates to:
  /// **'Share SOS'**
  String get shareSos;

  /// No description provided for @requestAStop.
  ///
  /// In en, this message translates to:
  /// **'Request a Stop'**
  String get requestAStop;

  /// No description provided for @requestStopDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe where you\'d like the driver to stop. The driver can accept or decline.'**
  String get requestStopDescription;

  /// No description provided for @requestStopHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gas station, pharmacy...'**
  String get requestStopHint;

  /// No description provided for @stopRequestSentToDriver.
  ///
  /// In en, this message translates to:
  /// **'Stop request sent to driver'**
  String get stopRequestSentToDriver;

  /// No description provided for @requestStop.
  ///
  /// In en, this message translates to:
  /// **'Request Stop'**
  String get requestStop;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @bookingNotFoundTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Booking not found. Please try again.'**
  String get bookingNotFoundTryAgain;

  /// No description provided for @noShowReported.
  ///
  /// In en, this message translates to:
  /// **'No-show reported'**
  String get noShowReported;

  /// No description provided for @incidentReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Incident report submitted'**
  String get incidentReportSubmitted;

  /// No description provided for @ratingSubmittedThankYou.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted - thank you!'**
  String get ratingSubmittedThankYou;

  /// No description provided for @ratePassenger.
  ///
  /// In en, this message translates to:
  /// **'Rate Passenger'**
  String get ratePassenger;

  /// No description provided for @ratePassengerCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What made this passenger great (or not)?'**
  String get ratePassengerCommentHint;

  /// No description provided for @failedToSubmitValue.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit: {value}'**
  String failedToSubmitValue(String value);

  /// No description provided for @sentMessage.
  ///
  /// In en, this message translates to:
  /// **'Sent: {message}'**
  String sentMessage(String message);

  /// No description provided for @acceptStop.
  ///
  /// In en, this message translates to:
  /// **'Accept Stop'**
  String get acceptStop;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @failedToLoadBookingValue.
  ///
  /// In en, this message translates to:
  /// **'Failed to load booking: {value}'**
  String failedToLoadBookingValue(String value);

  /// No description provided for @bookingNotFoundMayBeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking not found. It may have been cancelled.'**
  String get bookingNotFoundMayBeCancelled;

  /// No description provided for @rideHasBeenCancelled.
  ///
  /// In en, this message translates to:
  /// **'This ride has been cancelled.'**
  String get rideHasBeenCancelled;

  /// No description provided for @bookingRefCopied.
  ///
  /// In en, this message translates to:
  /// **'Booking ref {code} copied!'**
  String bookingRefCopied(String code);

  /// No description provided for @bookingFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Booking failed. Please try again.'**
  String get bookingFailedTryAgain;

  /// No description provided for @addedToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Added to calendar'**
  String get addedToCalendar;

  /// No description provided for @dismissSuccess.
  ///
  /// In en, this message translates to:
  /// **'Dismiss success'**
  String get dismissSuccess;

  /// No description provided for @dismissError.
  ///
  /// In en, this message translates to:
  /// **'Dismiss error'**
  String get dismissError;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmedTitle;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @lastCheckedInMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Last checked in {minutes} min ago'**
  String lastCheckedInMinutesAgo(int minutes);

  /// No description provided for @letContactsKnowSafe.
  ///
  /// In en, this message translates to:
  /// **'Let your contacts know you\'re safe'**
  String get letContactsKnowSafe;

  /// No description provided for @imOk.
  ///
  /// In en, this message translates to:
  /// **'I\'m OK'**
  String get imOk;

  /// No description provided for @incidentTypeUnsafeDriving.
  ///
  /// In en, this message translates to:
  /// **'Unsafe Driving'**
  String get incidentTypeUnsafeDriving;

  /// No description provided for @incidentTypeHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get incidentTypeHarassment;

  /// No description provided for @incidentTypeRouteDeviation.
  ///
  /// In en, this message translates to:
  /// **'Route Deviation'**
  String get incidentTypeRouteDeviation;

  /// No description provided for @incidentTypeVehicleIssue.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Issue'**
  String get incidentTypeVehicleIssue;

  /// No description provided for @incidentTypeNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-Show'**
  String get incidentTypeNoShow;

  /// No description provided for @incidentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incidentTypeOther;

  /// No description provided for @refundReasonDriverNoShow.
  ///
  /// In en, this message translates to:
  /// **'Driver did not show up'**
  String get refundReasonDriverNoShow;

  /// No description provided for @refundReasonRideNotAsDescribed.
  ///
  /// In en, this message translates to:
  /// **'Ride was not as described'**
  String get refundReasonRideNotAsDescribed;

  /// No description provided for @refundReasonUnsafeExperience.
  ///
  /// In en, this message translates to:
  /// **'Felt unsafe during ride'**
  String get refundReasonUnsafeExperience;

  /// No description provided for @refundReasonOvercharged.
  ///
  /// In en, this message translates to:
  /// **'Was overcharged'**
  String get refundReasonOvercharged;

  /// No description provided for @refundReasonCancelledByDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver cancelled last minute'**
  String get refundReasonCancelledByDriver;

  /// No description provided for @refundReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get refundReasonOther;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Est. Arrival'**
  String get estimatedArrival;

  /// No description provided for @partlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly Cloudy'**
  String get partlyCloudy;

  /// No description provided for @rideShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Carpool ride on SportConnect'**
  String get rideShareSubject;

  /// No description provided for @rideShareText.
  ///
  /// In en, this message translates to:
  /// **'🚗 Check out this ride on SportConnect!\n\n📍 {from} → {to}\n📅 {departure}\n💰 {price} € per seat\n🪑 {seats} seats available\n\nJoin me for a comfortable ride! 🌱\n\n🔗 {link}'**
  String rideShareText(
    String from,
    String to,
    String departure,
    String price,
    int seats,
    String link,
  );

  /// No description provided for @tripShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Trip on SportConnect'**
  String get tripShareSubject;

  /// No description provided for @tripShareMessage.
  ///
  /// In en, this message translates to:
  /// **'{userName} is {status} with SportConnect.\n\nFrom: {origin}\nTo: {destination}\nRide ID: {rideId}\n\nDeparture: {departure}'**
  String tripShareMessage(
    String userName,
    String status,
    String origin,
    String destination,
    String rideId,
    String departure,
  );

  /// No description provided for @tripStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'currently on a ride'**
  String get tripStatusInProgress;

  /// No description provided for @tripStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'about to ride'**
  String get tripStatusScheduled;

  /// No description provided for @rideCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Ride Compatibility'**
  String get rideCompatibility;

  /// No description provided for @greatMatch.
  ///
  /// In en, this message translates to:
  /// **'Great match'**
  String get greatMatch;

  /// No description provided for @goodMatch.
  ///
  /// In en, this message translates to:
  /// **'Good match'**
  String get goodMatch;

  /// No description provided for @fairMatch.
  ///
  /// In en, this message translates to:
  /// **'Fair match'**
  String get fairMatch;

  /// No description provided for @nonSmoking.
  ///
  /// In en, this message translates to:
  /// **'Non-smoking'**
  String get nonSmoking;

  /// No description provided for @directRoute.
  ///
  /// In en, this message translates to:
  /// **'Direct route'**
  String get directRoute;

  /// No description provided for @spacious.
  ///
  /// In en, this message translates to:
  /// **'Spacious'**
  String get spacious;

  /// No description provided for @viewActiveRide.
  ///
  /// In en, this message translates to:
  /// **'View Active Ride'**
  String get viewActiveRide;

  /// No description provided for @setPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Set pickup location'**
  String get setPickupLocation;

  /// No description provided for @optionalSetYourPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Optional - set your pickup point'**
  String get optionalSetYourPickupPoint;

  /// No description provided for @eventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventLabel;

  /// No description provided for @aPassenger.
  ///
  /// In en, this message translates to:
  /// **'A passenger'**
  String get aPassenger;

  /// No description provided for @rateAndReview.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review'**
  String get rateAndReview;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get shareReceipt;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @bookThisRouteAgain.
  ///
  /// In en, this message translates to:
  /// **'Book This Route Again'**
  String get bookThisRouteAgain;

  /// No description provided for @waitingForDriverApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver approval'**
  String get waitingForDriverApproval;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @addAsStop.
  ///
  /// In en, this message translates to:
  /// **'Add as Stop'**
  String get addAsStop;

  /// No description provided for @signInToSeeYourRides.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your rides'**
  String get signInToSeeYourRides;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @dateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateAtTime(String date, String time);

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @unableToLoadRidesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Unable to load rides. Please try again.'**
  String get unableToLoadRidesTryAgain;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @tryAdjustingFiltersOrDifferentDate.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search for a different date'**
  String get tryAdjustingFiltersOrDifferentDate;

  /// No description provided for @bestMatchForYourSearch.
  ///
  /// In en, this message translates to:
  /// **'Best match for your search'**
  String get bestMatchForYourSearch;

  /// No description provided for @showCheapestRidesFirst.
  ///
  /// In en, this message translates to:
  /// **'Show cheapest rides first'**
  String get showCheapestRidesFirst;

  /// No description provided for @showRidesLeavingSoonest.
  ///
  /// In en, this message translates to:
  /// **'Show rides leaving soonest'**
  String get showRidesLeavingSoonest;

  /// No description provided for @showBestRatedDriversFirst.
  ///
  /// In en, this message translates to:
  /// **'Show best-rated drivers first'**
  String get showBestRatedDriversFirst;

  /// No description provided for @showFastestRoutesFirst.
  ///
  /// In en, this message translates to:
  /// **'Show fastest routes first'**
  String get showFastestRoutesFirst;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @eventShareText.
  ///
  /// In en, this message translates to:
  /// **'{title} — {eventType}\n{date}\n{address}\n\nJoin me on SportConnect!\n{link}'**
  String eventShareText(
    String title,
    String eventType,
    String date,
    String address,
    String link,
  );

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'SportConnect - Trip Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptBaseFare.
  ///
  /// In en, this message translates to:
  /// **'Base Fare'**
  String get receiptBaseFare;

  /// No description provided for @receiptServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get receiptServiceFee;

  /// No description provided for @receiptRideId.
  ///
  /// In en, this message translates to:
  /// **'Ride ID'**
  String get receiptRideId;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @your_action_was_completed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your action was completed successfully.'**
  String get your_action_was_completed_successfully;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get success;

  /// No description provided for @localhost.
  ///
  /// In en, this message translates to:
  /// **'localhost'**
  String get localhost;

  /// No description provided for @production_mode.
  ///
  /// In en, this message translates to:
  /// **'PRODUCTION MODE'**
  String get production_mode;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get none;

  /// No description provided for @signedout.
  ///
  /// In en, this message translates to:
  /// **'signed-out'**
  String get signedout;

  /// No description provided for @pk_test_51t0hg4ryc7z72fdkkzbcqr4p1v0mi8nzgsxotoy7stj8a3qfqkdlbofdng5fggsinfcvilbokjbtupskomgywirk00mnaqcfsq.
  ///
  /// In en, this message translates to:
  /// **'pk_test_51T0hg4RYC7Z72fDKkzbCQr4P1v0Mi8nzgSXoToY7Stj8A3QfqKdLBOFDNG5fggSinfCVILBOkjBTupskomgywiRk00MnaqCFSq'**
  String
  get pk_test_51t0hg4ryc7z72fdkkzbcqr4p1v0mi8nzgsxotoy7stj8a3qfqkdlbofdng5fggsinfcvilbokjbtupskomgywirk00mnaqcfsq;

  /// No description provided for @passengerreview.
  ///
  /// In en, this message translates to:
  /// **'passengerReview'**
  String get passengerreview;

  /// No description provided for @stripe_not_configured_update_stripeconfig_values.
  ///
  /// In en, this message translates to:
  /// **'Stripe NOT configured - update StripeConfig values'**
  String get stripe_not_configured_update_stripeconfig_values;

  /// No description provided for @eur.
  ///
  /// In en, this message translates to:
  /// **'EUR'**
  String get eur;

  /// No description provided for @pk_test_your_publishable_key_here.
  ///
  /// In en, this message translates to:
  /// **'pk_test_YOUR_PUBLISHABLE_KEY_HERE'**
  String get pk_test_your_publishable_key_here;

  /// No description provided for @fr.
  ///
  /// In en, this message translates to:
  /// **'FR'**
  String get fr;

  /// No description provided for @tnfr.
  ///
  /// In en, this message translates to:
  /// **'tn,fr'**
  String get tnfr;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get users;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'reports'**
  String get reports;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'bookings'**
  String get bookings;

  /// No description provided for @support_tickets.
  ///
  /// In en, this message translates to:
  /// **'support_tickets'**
  String get support_tickets;

  /// No description provided for @driver_connected_accounts.
  ///
  /// In en, this message translates to:
  /// **'driver_connected_accounts'**
  String get driver_connected_accounts;

  /// No description provided for @driver_stats.
  ///
  /// In en, this message translates to:
  /// **'driver_stats'**
  String get driver_stats;

  /// No description provided for @blockedusers.
  ///
  /// In en, this message translates to:
  /// **'blockedUsers'**
  String get blockedusers;

  /// No description provided for @disputes.
  ///
  /// In en, this message translates to:
  /// **'disputes'**
  String get disputes;

  /// No description provided for @archived_transactions.
  ///
  /// In en, this message translates to:
  /// **'archived_transactions'**
  String get archived_transactions;

  /// No description provided for @profile_images.
  ///
  /// In en, this message translates to:
  /// **'profile_images'**
  String get profile_images;

  /// No description provided for @chat_images.
  ///
  /// In en, this message translates to:
  /// **'chat_images'**
  String get chat_images;

  /// No description provided for @vehicle_images.
  ///
  /// In en, this message translates to:
  /// **'vehicle_images'**
  String get vehicle_images;

  /// No description provided for @sportaxitripcom.
  ///
  /// In en, this message translates to:
  /// **'sportaxitrip.com'**
  String get sportaxitripcom;

  /// No description provided for @sportconnect10_contactsportconnectapp.
  ///
  /// In en, this message translates to:
  /// **'SportConnect/1.0 (contact@sportconnect.app)'**
  String get sportconnect10_contactsportconnectapp;

  /// No description provided for @find_and_book_rides_to_sporting_events.
  ///
  /// In en, this message translates to:
  /// **'Find and book rides to sporting events'**
  String get find_and_book_rides_to_sporting_events;

  /// No description provided for @offer_rides_and_earn_money.
  ///
  /// In en, this message translates to:
  /// **'Offer rides and earn money'**
  String get offer_rides_and_earn_money;

  /// No description provided for @your_application_is_under_review.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review'**
  String get your_application_is_under_review;

  /// No description provided for @language_code.
  ///
  /// In en, this message translates to:
  /// **'language_code'**
  String get language_code;

  /// No description provided for @notifications_enabled.
  ///
  /// In en, this message translates to:
  /// **'notifications_enabled'**
  String get notifications_enabled;

  /// No description provided for @ride_reminders.
  ///
  /// In en, this message translates to:
  /// **'ride_reminders'**
  String get ride_reminders;

  /// No description provided for @chat_notifications.
  ///
  /// In en, this message translates to:
  /// **'chat_notifications'**
  String get chat_notifications;

  /// No description provided for @marketing_emails.
  ///
  /// In en, this message translates to:
  /// **'marketing_emails'**
  String get marketing_emails;

  /// No description provided for @show_location.
  ///
  /// In en, this message translates to:
  /// **'show_location'**
  String get show_location;

  /// No description provided for @public_profile.
  ///
  /// In en, this message translates to:
  /// **'public_profile'**
  String get public_profile;

  /// No description provided for @map_style.
  ///
  /// In en, this message translates to:
  /// **'Map Style'**
  String get map_style;

  /// No description provided for @notification_dialog_shown.
  ///
  /// In en, this message translates to:
  /// **'notification_dialog_shown'**
  String get notification_dialog_shown;

  /// No description provided for @analytics_enabled.
  ///
  /// In en, this message translates to:
  /// **'analytics_enabled'**
  String get analytics_enabled;

  /// No description provided for @premium_prompt_seen_.
  ///
  /// In en, this message translates to:
  /// **'premium_prompt_seen_'**
  String get premium_prompt_seen_;

  /// No description provided for @driver_show_on_map.
  ///
  /// In en, this message translates to:
  /// **'driver_show_on_map'**
  String get driver_show_on_map;

  /// No description provided for @driver_allow_instant_booking.
  ///
  /// In en, this message translates to:
  /// **'driver_allow_instant_booking'**
  String get driver_allow_instant_booking;

  /// No description provided for @driver_max_distance.
  ///
  /// In en, this message translates to:
  /// **'driver_max_distance'**
  String get driver_max_distance;

  /// No description provided for @driver_navigation_app.
  ///
  /// In en, this message translates to:
  /// **'driver_navigation_app'**
  String get driver_navigation_app;

  /// No description provided for @sc.
  ///
  /// In en, this message translates to:
  /// **'SC'**
  String get sc;

  /// No description provided for @https.
  ///
  /// In en, this message translates to:
  /// **'https'**
  String get https;

  /// No description provided for @nominatimopenstreetmaporg.
  ///
  /// In en, this message translates to:
  /// **'nominatim.openstreetmap.org'**
  String get nominatimopenstreetmaporg;

  /// No description provided for @node.
  ///
  /// In en, this message translates to:
  /// **'node['**
  String get node;

  /// No description provided for @sports_centre.
  ///
  /// In en, this message translates to:
  /// **'sports_centre'**
  String get sports_centre;

  /// No description provided for @stadium.
  ///
  /// In en, this message translates to:
  /// **'stadium'**
  String get stadium;

  /// No description provided for @pitch.
  ///
  /// In en, this message translates to:
  /// **'pitch'**
  String get pitch;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'university'**
  String get university;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'college'**
  String get college;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'fuel'**
  String get fuel;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'restaurant'**
  String get restaurant;

  /// No description provided for @cafe.
  ///
  /// In en, this message translates to:
  /// **'cafe'**
  String get cafe;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'hospital'**
  String get hospital;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'clinic'**
  String get clinic;

  /// No description provided for @bus_stop.
  ///
  /// In en, this message translates to:
  /// **'bus_stop'**
  String get bus_stop;

  /// No description provided for @station.
  ///
  /// In en, this message translates to:
  /// **'station'**
  String get station;

  /// No description provided for @tram_stop.
  ///
  /// In en, this message translates to:
  /// **'tram_stop'**
  String get tram_stop;

  /// No description provided for @trip_receipt.
  ///
  /// In en, this message translates to:
  /// **'TRIP RECEIPT'**
  String get trip_receipt;

  /// No description provided for @thank_you_for_using_sportconnect.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using SportConnect!'**
  String get thank_you_for_using_sportconnect;

  /// No description provided for @your_ecofriendly_carpooling_choice.
  ///
  /// In en, this message translates to:
  /// **'Your eco-friendly carpooling choice'**
  String get your_ecofriendly_carpooling_choice;

  /// No description provided for @earnings_report.
  ///
  /// In en, this message translates to:
  /// **'EARNINGS REPORT'**
  String get earnings_report;

  /// No description provided for @trip_history.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get trip_history;

  /// No description provided for @sport_connect_messages.
  ///
  /// In en, this message translates to:
  /// **'sport_connect_messages'**
  String get sport_connect_messages;

  /// No description provided for @new_chat_message_notifications.
  ///
  /// In en, this message translates to:
  /// **'New chat message notifications'**
  String get new_chat_message_notifications;

  /// No description provided for @sport_connect_rides.
  ///
  /// In en, this message translates to:
  /// **'sport_connect_rides'**
  String get sport_connect_rides;

  /// No description provided for @ride_booking_and_status_notifications.
  ///
  /// In en, this message translates to:
  /// **'Ride booking and status notifications'**
  String get ride_booking_and_status_notifications;

  /// No description provided for @sport_connect_general.
  ///
  /// In en, this message translates to:
  /// **'sport_connect_general'**
  String get sport_connect_general;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @general_app_notifications.
  ///
  /// In en, this message translates to:
  /// **'General app notifications'**
  String get general_app_notifications;

  /// No description provided for @arrive_at_destination.
  ///
  /// In en, this message translates to:
  /// **'Arrive at destination'**
  String get arrive_at_destination;

  /// No description provided for @take_the_ramp.
  ///
  /// In en, this message translates to:
  /// **'Take the ramp'**
  String get take_the_ramp;

  /// No description provided for @take_the_exit.
  ///
  /// In en, this message translates to:
  /// **'Take the exit'**
  String get take_the_exit;

  /// No description provided for @driving.
  ///
  /// In en, this message translates to:
  /// **'driving'**
  String get driving;

  /// No description provided for @geojson.
  ///
  /// In en, this message translates to:
  /// **'geojson'**
  String get geojson;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @polyline.
  ///
  /// In en, this message translates to:
  /// **'polyline'**
  String get polyline;

  /// No description provided for @polyline6.
  ///
  /// In en, this message translates to:
  /// **'polyline6'**
  String get polyline6;

  /// No description provided for @start_on.
  ///
  /// In en, this message translates to:
  /// **'Start on'**
  String get start_on;

  /// No description provided for @inter.
  ///
  /// In en, this message translates to:
  /// **'Inter'**
  String get inter;

  /// No description provided for @name_is_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get name_is_required;

  /// No description provided for @name_must_be_at_least_2_characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get name_must_be_at_least_2_characters;

  /// No description provided for @name_is_too_long.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get name_is_too_long;

  /// No description provided for @name_cannot_contain_numbers.
  ///
  /// In en, this message translates to:
  /// **'Name cannot contain numbers'**
  String get name_cannot_contain_numbers;

  /// No description provided for @name_contains_invalid_characters.
  ///
  /// In en, this message translates to:
  /// **'Name contains invalid characters'**
  String get name_contains_invalid_characters;

  /// No description provided for @email_is_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_is_required;

  /// No description provided for @please_enter_a_valid_email_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get please_enter_a_valid_email_address;

  /// No description provided for @phone_number_is_too_short.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short'**
  String get phone_number_is_too_short;

  /// No description provided for @phone_number_is_too_long.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too long'**
  String get phone_number_is_too_long;

  /// No description provided for @phone_number_is_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_number_is_required;

  /// No description provided for @password_is_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_is_required;

  /// No description provided for @password_must_be_at_least_8_characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get password_must_be_at_least_8_characters;

  /// No description provided for @include_at_least_one_uppercase_letter.
  ///
  /// In en, this message translates to:
  /// **'Include at least one uppercase letter'**
  String get include_at_least_one_uppercase_letter;

  /// No description provided for @include_at_least_one_lowercase_letter.
  ///
  /// In en, this message translates to:
  /// **'Include at least one lowercase letter'**
  String get include_at_least_one_lowercase_letter;

  /// No description provided for @include_at_least_one_number.
  ///
  /// In en, this message translates to:
  /// **'Include at least one number'**
  String get include_at_least_one_number;

  /// No description provided for @please_confirm_your_password.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get please_confirm_your_password;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @price_is_required.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get price_is_required;

  /// No description provided for @please_enter_a_valid_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get please_enter_a_valid_price;

  /// No description provided for @price_must_be_greater_than_0.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get price_must_be_greater_than_0;

  /// No description provided for @price_seems_too_high.
  ///
  /// In en, this message translates to:
  /// **'Price seems too high'**
  String get price_seems_too_high;

  /// No description provided for @please_select_number_of_seats.
  ///
  /// In en, this message translates to:
  /// **'Please select number of seats'**
  String get please_select_number_of_seats;

  /// No description provided for @date_is_required.
  ///
  /// In en, this message translates to:
  /// **'Date is required'**
  String get date_is_required;

  /// No description provided for @date_must_be_in_the_future.
  ///
  /// In en, this message translates to:
  /// **'Date must be in the future'**
  String get date_must_be_in_the_future;

  /// No description provided for @date_of_birth_is_required.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get date_of_birth_is_required;

  /// No description provided for @license_plate_is_required.
  ///
  /// In en, this message translates to:
  /// **'License plate is required'**
  String get license_plate_is_required;

  /// No description provided for @license_plate_is_too_short.
  ///
  /// In en, this message translates to:
  /// **'License plate is too short'**
  String get license_plate_is_too_short;

  /// No description provided for @license_plate_is_too_long.
  ///
  /// In en, this message translates to:
  /// **'License plate is too long'**
  String get license_plate_is_too_long;

  /// No description provided for @invalid_license_plate_format.
  ///
  /// In en, this message translates to:
  /// **'Invalid license plate format'**
  String get invalid_license_plate_format;

  /// No description provided for @year_is_required.
  ///
  /// In en, this message translates to:
  /// **'Year is required'**
  String get year_is_required;

  /// No description provided for @please_enter_a_valid_year.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid year'**
  String get please_enter_a_valid_year;

  /// No description provided for @vehicle_is_too_old.
  ///
  /// In en, this message translates to:
  /// **'Vehicle is too old'**
  String get vehicle_is_too_old;

  /// No description provided for @invalid_year.
  ///
  /// In en, this message translates to:
  /// **'Invalid year'**
  String get invalid_year;

  /// No description provided for @city_name_is_too_short.
  ///
  /// In en, this message translates to:
  /// **'City name is too short'**
  String get city_name_is_too_short;

  /// No description provided for @city_name_is_too_long.
  ///
  /// In en, this message translates to:
  /// **'City name is too long'**
  String get city_name_is_too_long;

  /// No description provided for @city_name_cannot_contain_numbers.
  ///
  /// In en, this message translates to:
  /// **'City name cannot contain numbers'**
  String get city_name_cannot_contain_numbers;

  /// No description provided for @this_field.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get this_field;

  /// No description provided for @please_sign_in_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get please_sign_in_to_continue;

  /// No description provided for @this_payment_or_payout_could_not_be_found.
  ///
  /// In en, this message translates to:
  /// **'This payment or payout could not be found.'**
  String get this_payment_or_payout_could_not_be_found;

  /// No description provided for @this_request_was_already_processed.
  ///
  /// In en, this message translates to:
  /// **'This request was already processed.'**
  String get this_request_was_already_processed;

  /// No description provided for @too_many_requests_please_wait_a_moment_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Too many requests — please wait a moment and try again.'**
  String get too_many_requests_please_wait_a_moment_and_try_again;

  /// No description provided for @the_request_timed_out_please_check_your_connection_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please check your connection and try again.'**
  String get the_request_timed_out_please_check_your_connection_and_try_again;

  /// No description provided for @service_temporarily_unavailable_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable. Please try again.'**
  String get service_temporarily_unavailable_please_try_again;

  /// No description provided for @security_check_failed_please_refresh_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Security check failed. Please refresh and try again.'**
  String get security_check_failed_please_refresh_and_try_again;

  /// No description provided for @you_don.
  ///
  /// In en, this message translates to:
  /// **'You don'**
  String get you_don;

  /// No description provided for @insufficient_balance_ride_earnings_may_still_be_settling_try_again_in_a_few_hours.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. Ride earnings may still be settling — try again in a few hours.'**
  String
  get insufficient_balance_ride_earnings_may_still_be_settling_try_again_in_a_few_hours;

  /// No description provided for @no_bank_account_linked_please_complete_your_stripe_setup_first.
  ///
  /// In en, this message translates to:
  /// **'No bank account linked. Please complete your Stripe setup first.'**
  String get no_bank_account_linked_please_complete_your_stripe_setup_first;

  /// No description provided for @payouts_not_yet_enabled_on_your_account_please_complete_verification.
  ///
  /// In en, this message translates to:
  /// **'Payouts not yet enabled on your account. Please complete verification.'**
  String
  get payouts_not_yet_enabled_on_your_account_please_complete_verification;

  /// No description provided for @your_stripe_account_isn.
  ///
  /// In en, this message translates to:
  /// **'Your Stripe account isn'**
  String get your_stripe_account_isn;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap '**
  String get tap;

  /// No description provided for @your_card_was_declined_please_try_a_different_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Your card was declined. Please try a different payment method.'**
  String get your_card_was_declined_please_try_a_different_payment_method;

  /// No description provided for @payment_declined_insufficient_funds_on_your_card.
  ///
  /// In en, this message translates to:
  /// **'Payment declined — insufficient funds on your card.'**
  String get payment_declined_insufficient_funds_on_your_card;

  /// No description provided for @your_card_has_expired_please_update_your_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Your card has expired. Please update your payment method.'**
  String get your_card_has_expired_please_update_your_payment_method;

  /// No description provided for @incorrect_card_security_code_please_check_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Incorrect card security code. Please check and try again.'**
  String get incorrect_card_security_code_please_check_and_try_again;

  /// No description provided for @this_payout_can_no_longer_be_cancelled_it.
  ///
  /// In en, this message translates to:
  /// **'This payout can no longer be cancelled — it'**
  String get this_payout_can_no_longer_be_cancelled_it;

  /// No description provided for @payout_failed_please_check_your_bank_details_are_correct.
  ///
  /// In en, this message translates to:
  /// **'Payout failed. Please check your bank details are correct.'**
  String get payout_failed_please_check_your_bank_details_are_correct;

  /// No description provided for @refund_could_not_be_processed_please_contact_support_if_this_persists.
  ///
  /// In en, this message translates to:
  /// **'Refund could not be processed. Please contact support if this persists.'**
  String
  get refund_could_not_be_processed_please_contact_support_if_this_persists;

  /// No description provided for @this_booking_has_already_been_paid.
  ///
  /// In en, this message translates to:
  /// **'This booking has already been paid.'**
  String get this_booking_has_already_been_paid;

  /// No description provided for @this_ride_is_no_longer_available_for_booking.
  ///
  /// In en, this message translates to:
  /// **'This ride is no longer available for booking.'**
  String get this_ride_is_no_longer_available_for_booking;

  /// No description provided for @no_active_booking_found_for_this_ride.
  ///
  /// In en, this message translates to:
  /// **'No active booking found for this ride.'**
  String get no_active_booking_found_for_this_ride;

  /// No description provided for @the_driver_hasn.
  ///
  /// In en, this message translates to:
  /// **'The driver hasn'**
  String get the_driver_hasn;

  /// No description provided for @connection_error_please_check_your_internet_and_try_again.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet and try again.'**
  String get connection_error_please_check_your_internet_and_try_again;

  /// No description provided for @request_timed_out_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get request_timed_out_please_try_again;

  /// No description provided for @something_went_wrong_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get something_went_wrong_please_try_again;

  /// No description provided for @fastest_way_to_set_your_pickup_point.
  ///
  /// In en, this message translates to:
  /// **'Fastest way to set your pickup point'**
  String get fastest_way_to_set_your_pickup_point;

  /// No description provided for @expand_map_for_exact_pickup_point.
  ///
  /// In en, this message translates to:
  /// **'Expand map for exact pickup point'**
  String get expand_map_for_exact_pickup_point;

  /// No description provided for @tap_the_map_to_set_the_exact_point.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the exact point'**
  String get tap_the_map_to_set_the_exact_point;

  /// No description provided for @finding_address.
  ///
  /// In en, this message translates to:
  /// **'Finding address...'**
  String get finding_address;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTIONS'**
  String get suggestions;

  /// No description provided for @selected_address.
  ///
  /// In en, this message translates to:
  /// **'Selected address'**
  String get selected_address;

  /// No description provided for @use_this_address.
  ///
  /// In en, this message translates to:
  /// **'Use this address'**
  String get use_this_address;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @search_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Search unavailable'**
  String get search_unavailable;

  /// No description provided for @no_address_found.
  ///
  /// In en, this message translates to:
  /// **'No address found'**
  String get no_address_found;

  /// No description provided for @try_another_street_or_choose_the_exact_point_on_map.
  ///
  /// In en, this message translates to:
  /// **'Try another street or choose the exact point on map.'**
  String get try_another_street_or_choose_the_exact_point_on_map;

  /// No description provided for @unable_to_search_addresses_try_again.
  ///
  /// In en, this message translates to:
  /// **'Unable to search addresses. Try again.'**
  String get unable_to_search_addresses_try_again;

  /// No description provided for @unable_to_read_a_valid_current_location.
  ///
  /// In en, this message translates to:
  /// **'Unable to read a valid current location.'**
  String get unable_to_read_a_valid_current_location;

  /// No description provided for @your_current_location_appears_to_be_outside_france.
  ///
  /// In en, this message translates to:
  /// **'Your current location appears to be outside France.'**
  String get your_current_location_appears_to_be_outside_france;

  /// No description provided for @invalid_address_location_please_choose_another_result.
  ///
  /// In en, this message translates to:
  /// **'Invalid address location. Please choose another result.'**
  String get invalid_address_location_please_choose_another_result;

  /// No description provided for @invalid_map_position_please_choose_another_point.
  ///
  /// In en, this message translates to:
  /// **'Invalid map position. Please choose another point.'**
  String get invalid_map_position_please_choose_another_point;

  /// No description provided for @please_select_a_location_in_france.
  ///
  /// In en, this message translates to:
  /// **'Please select a location in France.'**
  String get please_select_a_location_in_france;

  /// No description provided for @selected_location.
  ///
  /// In en, this message translates to:
  /// **'Selected location'**
  String get selected_location;

  /// No description provided for @please_select_an_address.
  ///
  /// In en, this message translates to:
  /// **'Please select an address.'**
  String get please_select_an_address;

  /// No description provided for @invalid_selected_location_please_choose_another_point.
  ///
  /// In en, this message translates to:
  /// **'Invalid selected location. Please choose another point.'**
  String get invalid_selected_location_please_choose_another_point;

  /// No description provided for @payment_receipt.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get payment_receipt;

  /// No description provided for @thank_you_for_riding_with_sportconnect.
  ///
  /// In en, this message translates to:
  /// **'Thank you for riding with SportConnect!'**
  String get thank_you_for_riding_with_sportconnect;

  /// No description provided for @refund_amount.
  ///
  /// In en, this message translates to:
  /// **'Refund amount'**
  String get refund_amount;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @could_not_submit_refund_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Could not submit refund. Please try again.'**
  String get could_not_submit_refund_please_try_again;

  /// No description provided for @no_rides_found.
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get no_rides_found;

  /// No description provided for @try_adjusting_your_filters_or_search_for_a_different_route.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search for a different route'**
  String get try_adjusting_your_filters_or_search_for_a_different_route;

  /// No description provided for @no_events_yet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get no_events_yet;

  /// No description provided for @create_an_event_to_bring_your_group_together.
  ///
  /// In en, this message translates to:
  /// **'Create an event to bring your group together'**
  String get create_an_event_to_bring_your_group_together;

  /// No description provided for @no_messages_yet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get no_messages_yet;

  /// No description provided for @start_a_conversation_by_booking_a_ride_or_joining_an_event.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation by booking a ride or joining an event'**
  String get start_a_conversation_by_booking_a_ride_or_joining_an_event;

  /// No description provided for @all_caught_up.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get all_caught_up;

  /// No description provided for @no_reviews_yet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get no_reviews_yet;

  /// No description provided for @reviews_will_appear_after_completed_rides.
  ///
  /// In en, this message translates to:
  /// **'Reviews will appear after completed rides'**
  String get reviews_will_appear_after_completed_rides;

  /// No description provided for @no_vehicles_added.
  ///
  /// In en, this message translates to:
  /// **'No vehicles added'**
  String get no_vehicles_added;

  /// No description provided for @add_a_vehicle_to_start_offering_rides.
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle to start offering rides'**
  String get add_a_vehicle_to_start_offering_rides;

  /// No description provided for @no_bookings_yet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get no_bookings_yet;

  /// No description provided for @your_ride_bookings_will_appear_here.
  ///
  /// In en, this message translates to:
  /// **'Your ride bookings will appear here'**
  String get your_ride_bookings_will_appear_here;

  /// No description provided for @no_results_found.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get no_results_found;

  /// No description provided for @try_different_search_terms_or_filters.
  ///
  /// In en, this message translates to:
  /// **'Try different search terms or filters'**
  String get try_different_search_terms_or_filters;

  /// No description provided for @please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get please_try_again;

  /// No description provided for @select_your_expertise_level.
  ///
  /// In en, this message translates to:
  /// **'Select your expertise level'**
  String get select_your_expertise_level;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @enter_a_valid_french_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid French phone number.'**
  String get enter_a_valid_french_phone_number;

  /// No description provided for @after_33_enter_the_number_without_the_leading_0.
  ///
  /// In en, this message translates to:
  /// **'After +33, enter the number without the leading 0.'**
  String get after_33_enter_the_number_without_the_leading_0;

  /// No description provided for @used_only_for_ride_coordination_and_safety.
  ///
  /// In en, this message translates to:
  /// **'Used only for ride coordination and safety.'**
  String get used_only_for_ride_coordination_and_safety;

  /// No description provided for @no_map_apps_are_available_on_this_device.
  ///
  /// In en, this message translates to:
  /// **'No map apps are available on this device.'**
  String get no_map_apps_are_available_on_this_device;

  /// No description provided for @unable_to_open_maps_right_now.
  ///
  /// In en, this message translates to:
  /// **'Unable to open maps right now.'**
  String get unable_to_open_maps_right_now;

  /// No description provided for @select_location.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get select_location;

  /// No description provided for @france.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get france;

  /// No description provided for @departure_reminder.
  ///
  /// In en, this message translates to:
  /// **'Departure reminder'**
  String get departure_reminder;

  /// No description provided for @search_rides_people_places.
  ///
  /// In en, this message translates to:
  /// **'Search rides, people, places...'**
  String get search_rides_people_places;

  /// No description provided for @explore_nearby_stops.
  ///
  /// In en, this message translates to:
  /// **'Explore nearby stops'**
  String get explore_nearby_stops;

  /// No description provided for @gas_stations.
  ///
  /// In en, this message translates to:
  /// **'Gas Stations'**
  String get gas_stations;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @universities.
  ///
  /// In en, this message translates to:
  /// **'Universities'**
  String get universities;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitals;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @cafs.
  ///
  /// In en, this message translates to:
  /// **'Cafés'**
  String get cafs;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @switch_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Switch Vehicle'**
  String get switch_vehicle;

  /// No description provided for @ladies_only.
  ///
  /// In en, this message translates to:
  /// **'Ladies Only'**
  String get ladies_only;

  /// No description provided for @tap_to_apply.
  ///
  /// In en, this message translates to:
  /// **'Tap to apply'**
  String get tap_to_apply;

  /// No description provided for @ride_progress.
  ///
  /// In en, this message translates to:
  /// **'Ride Progress'**
  String get ride_progress;

  /// No description provided for @ride_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Ride confirmed'**
  String get ride_confirmed;

  /// No description provided for @on_the_way_to_pickup.
  ///
  /// In en, this message translates to:
  /// **'On the way to pickup'**
  String get on_the_way_to_pickup;

  /// No description provided for @almost_at_pickup_point.
  ///
  /// In en, this message translates to:
  /// **'Almost at pickup point'**
  String get almost_at_pickup_point;

  /// No description provided for @en_route_to_destination.
  ///
  /// In en, this message translates to:
  /// **'En route to destination'**
  String get en_route_to_destination;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @driver_left.
  ///
  /// In en, this message translates to:
  /// **'Driver Left'**
  String get driver_left;

  /// No description provided for @arriving.
  ///
  /// In en, this message translates to:
  /// **'Arriving'**
  String get arriving;

  /// No description provided for @riding.
  ///
  /// In en, this message translates to:
  /// **'Riding'**
  String get riding;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @driver_history.
  ///
  /// In en, this message translates to:
  /// **'Driver History'**
  String get driver_history;

  /// No description provided for @please_reauthenticate_before_deleting_your_account.
  ///
  /// In en, this message translates to:
  /// **'Please re-authenticate before deleting your account'**
  String get please_reauthenticate_before_deleting_your_account;

  /// No description provided for @your_account_has_been_suspended_please_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. Please contact support.'**
  String get your_account_has_been_suspended_please_contact_support;

  /// No description provided for @signin_was_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get signin_was_cancelled;

  /// No description provided for @no_user_found_with_this_email.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email'**
  String get no_user_found_with_this_email;

  /// No description provided for @wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrong_password;

  /// No description provided for @invalid_email_or_password.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalid_email_or_password;

  /// No description provided for @email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get email_already_in_use;

  /// No description provided for @invalid_email_address.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalid_email_address;

  /// No description provided for @password_is_too_weak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get password_is_too_weak;

  /// No description provided for @too_many_attempts_please_try_again_later.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get too_many_attempts_please_try_again_later;

  /// No description provided for @please_reauthenticate_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Please re-authenticate to continue'**
  String get please_reauthenticate_to_continue;

  /// No description provided for @an_account_already_exists_with_a_different_signin_method.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method. '**
  String get an_account_already_exists_with_a_different_signin_method;

  /// No description provided for @the_selected_google_account_does_not_match_your_account_email.
  ///
  /// In en, this message translates to:
  /// **'The selected Google account does not match your account email. '**
  String get the_selected_google_account_does_not_match_your_account_email;

  /// No description provided for @requiresrecentlogin.
  ///
  /// In en, this message translates to:
  /// **'requires-recent-login'**
  String get requiresrecentlogin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @weakpassword.
  ///
  /// In en, this message translates to:
  /// **'weak-password'**
  String get weakpassword;

  /// No description provided for @you_must_accept_the_terms_to_continue.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms to continue.'**
  String get you_must_accept_the_terms_to_continue;

  /// No description provided for @ageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am at least 18 years old'**
  String get ageConfirmation;

  /// No description provided for @ageConfirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'You must confirm you are at least 18 years old to continue.'**
  String get ageConfirmationRequired;

  /// No description provided for @from_your_signin_account.
  ///
  /// In en, this message translates to:
  /// **'From your sign-in account'**
  String get from_your_signin_account;

  /// No description provided for @help_riders_recognize_your_car_at_pickup.
  ///
  /// In en, this message translates to:
  /// **'Help riders recognize your car at pickup.'**
  String get help_riders_recognize_your_car_at_pickup;

  /// No description provided for @other_color.
  ///
  /// In en, this message translates to:
  /// **'Other color'**
  String get other_color;

  /// No description provided for @i_agree_to_the.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get i_agree_to_the;

  /// No description provided for @terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_conditions;

  /// No description provided for @recognition_details_appear_here.
  ///
  /// In en, this message translates to:
  /// **'Recognition details appear here'**
  String get recognition_details_appear_here;

  /// No description provided for @what_car_should_riders_look_for.
  ///
  /// In en, this message translates to:
  /// **'What car should riders look for?'**
  String get what_car_should_riders_look_for;

  /// No description provided for @keep_this_simple_make_and_model_are_enough_here.
  ///
  /// In en, this message translates to:
  /// **'Keep this simple. Make and model are enough here.'**
  String get keep_this_simple_make_and_model_are_enough_here;

  /// No description provided for @help_passengers_find_you.
  ///
  /// In en, this message translates to:
  /// **'Help passengers find you'**
  String get help_passengers_find_you;

  /// No description provided for @color_and_plate_are_the_details_riders_use_at_pickup.
  ///
  /// In en, this message translates to:
  /// **'Color and plate are the details riders use at pickup.'**
  String get color_and_plate_are_the_details_riders_use_at_pickup;

  /// No description provided for @how_many_passengers_can_you_take.
  ///
  /// In en, this message translates to:
  /// **'How many passengers can you take?'**
  String get how_many_passengers_can_you_take;

  /// No description provided for @this_is_available_passenger_seats_not_total_car_seats.
  ///
  /// In en, this message translates to:
  /// **'This is available passenger seats, not total car seats.'**
  String get this_is_available_passenger_seats_not_total_car_seats;

  /// No description provided for @vehicle_details.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details'**
  String get vehicle_details;

  /// No description provided for @kept_quieter_because_they_are_less_important_at_pickup.
  ///
  /// In en, this message translates to:
  /// **'Kept quieter because they are less important at pickup.'**
  String get kept_quieter_because_they_are_less_important_at_pickup;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @grey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get grey;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @beige_brown.
  ///
  /// In en, this message translates to:
  /// **'Beige / Brown'**
  String get beige_brown;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save_driver_profile_and_continue.
  ///
  /// In en, this message translates to:
  /// **'Save driver profile and continue'**
  String get save_driver_profile_and_continue;

  /// No description provided for @champagne_pearl_white_bordeaux.
  ///
  /// In en, this message translates to:
  /// **'Champagne, pearl white, bordeaux...'**
  String get champagne_pearl_white_bordeaux;

  /// No description provided for @invalid_value.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalid_value;

  /// No description provided for @address_is_required.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get address_is_required;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @contactAndAddress.
  ///
  /// In en, this message translates to:
  /// **'Contact & Address'**
  String get contactAndAddress;

  /// No description provided for @drivingDetails.
  ///
  /// In en, this message translates to:
  /// **'Driving Details'**
  String get drivingDetails;

  /// No description provided for @carIdentity.
  ///
  /// In en, this message translates to:
  /// **'Car identity'**
  String get carIdentity;

  /// No description provided for @recognition.
  ///
  /// In en, this message translates to:
  /// **'Recognition'**
  String get recognition;

  /// No description provided for @passengerSeats.
  ///
  /// In en, this message translates to:
  /// **'Passenger seats'**
  String get passengerSeats;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @whyConnectPayouts.
  ///
  /// In en, this message translates to:
  /// **'Why connect payouts?'**
  String get whyConnectPayouts;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @registrationYear.
  ///
  /// In en, this message translates to:
  /// **'Registration year'**
  String get registrationYear;

  /// No description provided for @onlyUsedWhenNeededForPickupVerification.
  ///
  /// In en, this message translates to:
  /// **'Only used when needed for pickup verification.'**
  String get onlyUsedWhenNeededForPickupVerification;

  /// No description provided for @addColorAndPlateSoRidersCanFindYou.
  ///
  /// In en, this message translates to:
  /// **'Add color and plate so riders can find you'**
  String get addColorAndPlateSoRidersCanFindYou;

  /// No description provided for @chooseACommonColorOrUseOtherColor.
  ///
  /// In en, this message translates to:
  /// **'Choose a common color or use Other color.'**
  String get chooseACommonColorOrUseOtherColor;

  /// No description provided for @selectedColor.
  ///
  /// In en, this message translates to:
  /// **'Selected color: {color}'**
  String selectedColor(String color);

  /// No description provided for @customColorWillBeShownToRidersAsWritten.
  ///
  /// In en, this message translates to:
  /// **'Custom color will be shown to riders as written.'**
  String get customColorWillBeShownToRidersAsWritten;

  /// No description provided for @chooseSeatsAvailableForPassengers.
  ///
  /// In en, this message translates to:
  /// **'Choose seats available for passengers.'**
  String get chooseSeatsAvailableForPassengers;

  /// No description provided for @optionalDetailUsedForRideContext.
  ///
  /// In en, this message translates to:
  /// **'Optional detail used for ride context.'**
  String get optionalDetailUsedForRideContext;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @maximumSeats.
  ///
  /// In en, this message translates to:
  /// **'Maximum seats'**
  String get maximumSeats;

  /// No description provided for @colorDescriptionIsTooLong.
  ///
  /// In en, this message translates to:
  /// **'Color description is too long'**
  String get colorDescriptionIsTooLong;

  /// No description provided for @useAClearColorNameLikeGreyBlueOrPearlWhite.
  ///
  /// In en, this message translates to:
  /// **'Use a clear color name, like grey, blue, or pearl white.'**
  String get useAClearColorNameLikeGreyBlueOrPearlWhite;

  /// No description provided for @suggestedPriceValue.
  ///
  /// In en, this message translates to:
  /// **'Suggested: €{price}'**
  String suggestedPriceValue(String price);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'dob'**
  String get dob;

  /// No description provided for @expertise.
  ///
  /// In en, this message translates to:
  /// **'expertise'**
  String get expertise;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'terms'**
  String get terms;

  /// No description provided for @license_plate.
  ///
  /// In en, this message translates to:
  /// **'license_plate'**
  String get license_plate;

  /// No description provided for @fuel_type.
  ///
  /// In en, this message translates to:
  /// **'fuel_type'**
  String get fuel_type;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up;

  /// No description provided for @sportconnect_logo.
  ///
  /// In en, this message translates to:
  /// **'SportConnect logo'**
  String get sportconnect_logo;

  /// No description provided for @signing_in_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Signing in, please wait'**
  String get signing_in_please_wait;

  /// No description provided for @discard_changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discard_changes;

  /// No description provided for @your_profile_info_will_not_be_saved_if_you_go_back.
  ///
  /// In en, this message translates to:
  /// **'Your profile info will not be saved if you go back.'**
  String get your_profile_info_will_not_be_saved_if_you_go_back;

  /// No description provided for @keep_editing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keep_editing;

  /// No description provided for @complete_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get complete_your_profile;

  /// No description provided for @step_2_of_2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get step_2_of_2;

  /// No description provided for @rider_onboarding_form.
  ///
  /// In en, this message translates to:
  /// **'Rider onboarding form'**
  String get rider_onboarding_form;

  /// No description provided for @complete_rider_onboarding.
  ///
  /// In en, this message translates to:
  /// **'Complete rider onboarding'**
  String get complete_rider_onboarding;

  /// No description provided for @profile_not_loaded_yet_please_wait_a_moment.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Profile not loaded yet. Please wait a moment.'**
  String get profile_not_loaded_yet_please_wait_a_moment;

  /// No description provided for @please_enter_a_valid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get please_enter_a_valid_phone_number;

  /// No description provided for @please_enter_your_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter your address.'**
  String get please_enter_your_address;

  /// No description provided for @profile_complete_welcome_aboard.
  ///
  /// In en, this message translates to:
  /// **'🎉 Profile complete! Welcome aboard.'**
  String get profile_complete_welcome_aboard;

  /// No description provided for @your_saved_info_has_been_prefilled.
  ///
  /// In en, this message translates to:
  /// **'Your saved info has been pre-filled.'**
  String get your_saved_info_has_been_prefilled;

  /// No description provided for @failed_to_load_your_profile_some_fields_may_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your profile. Some fields may be empty.'**
  String get failed_to_load_your_profile_some_fields_may_be_empty;

  /// No description provided for @verification_requirements.
  ///
  /// In en, this message translates to:
  /// **'Verification Requirements'**
  String get verification_requirements;

  /// No description provided for @almost_there.
  ///
  /// In en, this message translates to:
  /// **'Almost there! 📍'**
  String get almost_there;

  /// No description provided for @skip_for_now.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip_for_now;

  /// No description provided for @confirm_date.
  ///
  /// In en, this message translates to:
  /// **'Confirm Date'**
  String get confirm_date;

  /// No description provided for @account_setup.
  ///
  /// In en, this message translates to:
  /// **'Account Setup'**
  String get account_setup;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @or_continue_with_email.
  ///
  /// In en, this message translates to:
  /// **'Or continue with email'**
  String get or_continue_with_email;

  /// No description provided for @agree_to_terms_of_service_and_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Agree to Terms of Service and Privacy Policy'**
  String get agree_to_terms_of_service_and_privacy_policy;

  /// No description provided for @googlesignincanceled.
  ///
  /// In en, this message translates to:
  /// **'google-sign-in-canceled'**
  String get googlesignincanceled;

  /// No description provided for @accountexistswithdifferentcredential.
  ///
  /// In en, this message translates to:
  /// **'account-exists-with-different-credential'**
  String get accountexistswithdifferentcredential;

  /// No description provided for @wrongpassword.
  ///
  /// In en, this message translates to:
  /// **'wrong-password'**
  String get wrongpassword;

  /// No description provided for @every_day.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get every_day;

  /// No description provided for @every_week.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get every_week;

  /// No description provided for @every_2_weeks.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get every_2_weeks;

  /// No description provided for @every_month.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get every_month;

  /// No description provided for @every_year.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get every_year;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get weekly;

  /// No description provided for @weeklyinterval2.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY;INTERVAL=2'**
  String get weeklyinterval2;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @martial_arts.
  ///
  /// In en, this message translates to:
  /// **'Martial Arts'**
  String get martial_arts;

  /// No description provided for @football.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get football;

  /// No description provided for @basketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get basketball;

  /// No description provided for @volleyball.
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get volleyball;

  /// No description provided for @tennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get tennis;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @swimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimming;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @hiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get hiking;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @no_ride_info_yet.
  ///
  /// In en, this message translates to:
  /// **'No ride info yet'**
  String get no_ride_info_yet;

  /// No description provided for @need_ride.
  ///
  /// In en, this message translates to:
  /// **'need_ride'**
  String get need_ride;

  /// No description provided for @self_arranged.
  ///
  /// In en, this message translates to:
  /// **'self_arranged'**
  String get self_arranged;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @no_recurrence_pattern_fits_this_startend_window.
  ///
  /// In en, this message translates to:
  /// **'No recurrence pattern fits this start/end window. '**
  String get no_recurrence_pattern_fits_this_startend_window;

  /// No description provided for @extend_end_time_or_set_a_later_repeat_end_date.
  ///
  /// In en, this message translates to:
  /// **'Extend end time or set a later repeat end date.'**
  String get extend_end_time_or_set_a_later_repeat_end_date;

  /// No description provided for @failed_to_load_attendees.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendees'**
  String get failed_to_load_attendees;

  /// No description provided for @no_attendees_yet.
  ///
  /// In en, this message translates to:
  /// **'No attendees yet'**
  String get no_attendees_yet;

  /// No description provided for @failed_to_open_chat_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat. Please try again.'**
  String get failed_to_open_chat_please_try_again;

  /// No description provided for @view_all_attendees.
  ///
  /// In en, this message translates to:
  /// **'View all attendees →'**
  String get view_all_attendees;

  /// No description provided for @cancel_event.
  ///
  /// In en, this message translates to:
  /// **'Cancel Event'**
  String get cancel_event;

  /// No description provided for @keep_event.
  ///
  /// In en, this message translates to:
  /// **'Keep Event'**
  String get keep_event;

  /// No description provided for @delete_event.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get delete_event;

  /// No description provided for @are_you_sure_you_want_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete '**
  String get are_you_sure_you_want_to_delete;

  /// No description provided for @recurring_event.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Recurring Event'**
  String get recurring_event;

  /// No description provided for @this_event.
  ///
  /// In en, this message translates to:
  /// **'This event'**
  String get this_event;

  /// No description provided for @all_events.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get all_events;

  /// No description provided for @not_label.
  ///
  /// In en, this message translates to:
  /// **'not'**
  String get not_label;

  /// No description provided for @custom_label.
  ///
  /// In en, this message translates to:
  /// **'custom'**
  String get custom_label;

  /// No description provided for @opening_google_calendar.
  ///
  /// In en, this message translates to:
  /// **'Opening Google Calendar...'**
  String get opening_google_calendar;

  /// No description provided for @opening_google_calendar_recurring.
  ///
  /// In en, this message translates to:
  /// **'Opening Google Calendar (recurring: {patternLabel})...'**
  String opening_google_calendar_recurring(Object patternLabel);

  /// No description provided for @this_event_repeats_deleting_it_will_remove_all_occurrences_past_and_future.
  ///
  /// In en, this message translates to:
  /// **'This event repeats. Deleting it will remove ALL occurrences (past and future).'**
  String
  get this_event_repeats_deleting_it_will_remove_all_occurrences_past_and_future;

  /// No description provided for @to_delete_only_specific_occurrences_use_google_calendar_tap_the_event.
  ///
  /// In en, this message translates to:
  /// **'To delete only specific occurrences, use Google Calendar: tap the event → '**
  String
  get to_delete_only_specific_occurrences_use_google_calendar_tap_the_event;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @premium_event_chat.
  ///
  /// In en, this message translates to:
  /// **'Premium event chat'**
  String get premium_event_chat;

  /// No description provided for @subscribe_to_premium_to_join_attendee_group_chats_for_events.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Premium to join attendee group chats for events.'**
  String get subscribe_to_premium_to_join_attendee_group_chats_for_events;

  /// No description provided for @upgrade_to_premium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgrade_to_premium;

  /// No description provided for @reason_optional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reason_optional;

  /// No description provided for @event_group_chat_is_available_to_premium_subscribers_only.
  ///
  /// In en, this message translates to:
  /// **'Event group chat is available to Premium subscribers only.'**
  String get event_group_chat_is_available_to_premium_subscribers_only;

  /// No description provided for @could_not_open_calendar_please_ensure_google_calendar_is_available.
  ///
  /// In en, this message translates to:
  /// **'Could not open calendar. Please ensure Google Calendar is available.'**
  String get could_not_open_calendar_please_ensure_google_calendar_is_available;

  /// No description provided for @events_near_me.
  ///
  /// In en, this message translates to:
  /// **'Events near me'**
  String get events_near_me;

  /// No description provided for @everywhere.
  ///
  /// In en, this message translates to:
  /// **'Everywhere'**
  String get everywhere;

  /// No description provided for @retry_loading_events.
  ///
  /// In en, this message translates to:
  /// **'Retry loading events'**
  String get retry_loading_events;

  /// No description provided for @all_loaded_events_shown.
  ///
  /// In en, this message translates to:
  /// **'All loaded events shown'**
  String get all_loaded_events_shown;

  /// No description provided for @load_more_events.
  ///
  /// In en, this message translates to:
  /// **'Load more events'**
  String get load_more_events;

  /// No description provided for @create_event.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get create_event;

  /// No description provided for @could_not_load_events.
  ///
  /// In en, this message translates to:
  /// **'Could not load events'**
  String get could_not_load_events;

  /// No description provided for @no_matching_loaded_events.
  ///
  /// In en, this message translates to:
  /// **'No matching loaded events'**
  String get no_matching_loaded_events;

  /// No description provided for @search_loaded_events_by_title_place_organizer.
  ///
  /// In en, this message translates to:
  /// **'Search loaded events by title, place, organizer'**
  String get search_loaded_events_by_title_place_organizer;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @title_is_required.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get title_is_required;

  /// No description provided for @title_must_be_at_least_3_characters.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters'**
  String get title_must_be_at_least_3_characters;

  /// No description provided for @please_pick_a_location.
  ///
  /// In en, this message translates to:
  /// **'Please pick a location.'**
  String get please_pick_a_location;

  /// No description provided for @start_time_must_be_in_the_future.
  ///
  /// In en, this message translates to:
  /// **'Start time must be in the future.'**
  String get start_time_must_be_in_the_future;

  /// No description provided for @end_time_must_be_after_start_time.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get end_time_must_be_after_start_time;

  /// No description provided for @select_a_recurrence_pattern.
  ///
  /// In en, this message translates to:
  /// **'Select a recurrence pattern.'**
  String get select_a_recurrence_pattern;

  /// No description provided for @repeat_end_date_must_be_on_or_after_the_start_date.
  ///
  /// In en, this message translates to:
  /// **'Repeat end date must be on or after the start date.'**
  String get repeat_end_date_must_be_on_or_after_the_start_date;

  /// No description provided for @please_wait_for_the_current_submission_to_finish.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the current submission to finish.'**
  String get please_wait_for_the_current_submission_to_finish;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @please_select_a_location.
  ///
  /// In en, this message translates to:
  /// **'Please select a location.'**
  String get please_select_a_location;

  /// No description provided for @start_time_is_required.
  ///
  /// In en, this message translates to:
  /// **'Start time is required'**
  String get start_time_is_required;

  /// No description provided for @event_is_still_loading.
  ///
  /// In en, this message translates to:
  /// **'Event is still loading.'**
  String get event_is_still_loading;

  /// No description provided for @event_created_but_the_cover_image_could_not_be_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Event created, but the cover image could not be uploaded.'**
  String get event_created_but_the_cover_image_could_not_be_uploaded;

  /// No description provided for @ride_in_progress.
  ///
  /// In en, this message translates to:
  /// **'RIDE IN PROGRESS'**
  String get ride_in_progress;

  /// No description provided for @next_ride.
  ///
  /// In en, this message translates to:
  /// **'Next ride'**
  String get next_ride;

  /// No description provided for @review_and_respond_before_passengers_choose_another_ride.
  ///
  /// In en, this message translates to:
  /// **'Review and respond before passengers choose another ride.'**
  String get review_and_respond_before_passengers_choose_another_ride;

  /// No description provided for @ready_for_your_next_trip.
  ///
  /// In en, this message translates to:
  /// **'Ready for your next trip?'**
  String get ready_for_your_next_trip;

  /// No description provided for @publish_a_ride_and_start_receiving_passenger_requests.
  ///
  /// In en, this message translates to:
  /// **'Publish a ride and start receiving passenger requests.'**
  String get publish_a_ride_and_start_receiving_passenger_requests;

  /// Accessibility label for generic map control buttons
  ///
  /// In en, this message translates to:
  /// **'Map control'**
  String get mapControlLabel;

  /// No description provided for @rideFilterSemantics.
  ///
  /// In en, this message translates to:
  /// **'{filterLabel} filter, {count, plural, =0{0 rides} =1{1 ride} other{{count} rides}}'**
  String rideFilterSemantics(String filterLabel, num count);

  /// No description provided for @last_updated_february_23_2026.
  ///
  /// In en, this message translates to:
  /// **'Last updated: February 23, 2026'**
  String get last_updated_february_23_2026;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get en;

  /// No description provided for @utf8.
  ///
  /// In en, this message translates to:
  /// **'UTF-8'**
  String get utf8;

  /// No description provided for @viewport.
  ///
  /// In en, this message translates to:
  /// **'viewport'**
  String get viewport;

  /// No description provided for @widthdevicewidth_initialscale10.
  ///
  /// In en, this message translates to:
  /// **'width=device-width, initial-scale=1.0'**
  String get widthdevicewidth_initialscale10;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'subtitle'**
  String get subtitle;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'highlight'**
  String get highlight;

  /// No description provided for @mailtolegalsportconnectapp.
  ///
  /// In en, this message translates to:
  /// **'mailto:legal@sportconnect.app'**
  String get mailtolegalsportconnectapp;

  /// No description provided for @mailtoprivacysportconnectapp.
  ///
  /// In en, this message translates to:
  /// **'mailto:privacy@sportconnect.app'**
  String get mailtoprivacysportconnectapp;

  /// No description provided for @delete_conversation.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get delete_conversation;

  /// No description provided for @this_will_remove_the_conversation_from_your_chat_list.
  ///
  /// In en, this message translates to:
  /// **'This will remove the conversation from your chat list. '**
  String get this_will_remove_the_conversation_from_your_chat_list;

  /// No description provided for @clear_chat_history.
  ///
  /// In en, this message translates to:
  /// **'Clear chat history'**
  String get clear_chat_history;

  /// No description provided for @this_will_clear_the_messages_from_this_chat_for_you_only.
  ///
  /// In en, this message translates to:
  /// **'This will clear the messages from this chat for you only. '**
  String get this_will_clear_the_messages_from_this_chat_for_you_only;

  /// No description provided for @clear_history.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clear_history;

  /// No description provided for @message_options.
  ///
  /// In en, this message translates to:
  /// **'Message options'**
  String get message_options;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @conversation_deleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversation_deleted;

  /// No description provided for @choose_what_you_want_to_share_in_this_chat.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to share in this chat.'**
  String get choose_what_you_want_to_share_in_this_chat;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @cameraAccessIsNeededToTakeAndSendPhotosInThisChat.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to take and send photos in this chat.'**
  String get cameraAccessIsNeededToTakeAndSendPhotosInThisChat;

  /// No description provided for @failedToSendImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send image'**
  String get failedToSendImage;

  /// No description provided for @permissionDeniedPleaseCheckYourConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please check your connection and try again.'**
  String get permissionDeniedPleaseCheckYourConnectionAndTryAgain;

  /// No description provided for @networkErrorPleaseCheckYourInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkErrorPleaseCheckYourInternetConnection;

  /// No description provided for @clearChatHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This will clear the messages from this chat for you only. The conversation will stay in your chat list.'**
  String get clearChatHistoryMessage;

  /// No description provided for @pleaseEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services'**
  String get pleaseEnableLocationServices;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// No description provided for @couldNotGetYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location'**
  String get couldNotGetYourLocation;

  /// No description provided for @failedToGetLocationValue.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: {value}'**
  String failedToGetLocationValue(Object value);

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @preview_mode.
  ///
  /// In en, this message translates to:
  /// **'Preview mode'**
  String get preview_mode;

  /// No description provided for @chat_preview.
  ///
  /// In en, this message translates to:
  /// **'Chat preview'**
  String get chat_preview;

  /// No description provided for @person_add.
  ///
  /// In en, this message translates to:
  /// **'person_add'**
  String get person_add;

  /// No description provided for @check_circle.
  ///
  /// In en, this message translates to:
  /// **'check_circle'**
  String get check_circle;

  /// No description provided for @event_busy.
  ///
  /// In en, this message translates to:
  /// **'event_busy'**
  String get event_busy;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'schedule'**
  String get schedule;

  /// No description provided for @directions_car.
  ///
  /// In en, this message translates to:
  /// **'directions_car'**
  String get directions_car;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'flag'**
  String get flag;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'block'**
  String get block;

  /// No description provided for @chat_bubble.
  ///
  /// In en, this message translates to:
  /// **'chat_bubble'**
  String get chat_bubble;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'person'**
  String get person;

  /// No description provided for @arrow_upward.
  ///
  /// In en, this message translates to:
  /// **'arrow_upward'**
  String get arrow_upward;

  /// No description provided for @emoji_events.
  ///
  /// In en, this message translates to:
  /// **'emoji_events'**
  String get emoji_events;

  /// No description provided for @local_fire_department.
  ///
  /// In en, this message translates to:
  /// **'local_fire_department'**
  String get local_fire_department;

  /// No description provided for @star.
  ///
  /// In en, this message translates to:
  /// **'star'**
  String get star;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get warning;

  /// No description provided for @campaign.
  ///
  /// In en, this message translates to:
  /// **'campaign'**
  String get campaign;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @new_ride_request.
  ///
  /// In en, this message translates to:
  /// **'New Ride Request'**
  String get new_ride_request;

  /// No description provided for @booking_accepted.
  ///
  /// In en, this message translates to:
  /// **'Booking Accepted!'**
  String get booking_accepted;

  /// No description provided for @booking_declined.
  ///
  /// In en, this message translates to:
  /// **'Booking Declined'**
  String get booking_declined;

  /// No description provided for @ride_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Ride Cancelled'**
  String get ride_cancelled;

  /// No description provided for @new_message.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get new_message;

  /// No description provided for @achievement_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked! 🏆'**
  String get achievement_unlocked;

  /// No description provided for @level_up.
  ///
  /// In en, this message translates to:
  /// **'Level Up! 🎉'**
  String get level_up;

  /// No description provided for @driver_has_arrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived! 🚗'**
  String get driver_has_arrived;

  /// No description provided for @event_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Event Cancelled'**
  String get event_cancelled;

  /// No description provided for @mark_read.
  ///
  /// In en, this message translates to:
  /// **'mark_read'**
  String get mark_read;

  /// No description provided for @find_yournride.
  ///
  /// In en, this message translates to:
  /// **'Find Your\\nRide'**
  String get find_yournride;

  /// No description provided for @match_with_runners.
  ///
  /// In en, this message translates to:
  /// **'Match with Runners'**
  String get match_with_runners;

  /// No description provided for @offer_anseat.
  ///
  /// In en, this message translates to:
  /// **'Offer a\\nSeat'**
  String get offer_anseat;

  /// No description provided for @drive_split_costs.
  ///
  /// In en, this message translates to:
  /// **'Drive & Split Costs'**
  String get drive_split_costs;

  /// No description provided for @plan_yournroute.
  ///
  /// In en, this message translates to:
  /// **'Plan Your\\nRoute'**
  String get plan_yournroute;

  /// No description provided for @smart_route_sync.
  ///
  /// In en, this message translates to:
  /// **'Smart Route Sync'**
  String get smart_route_sync;

  /// No description provided for @connectn_go.
  ///
  /// In en, this message translates to:
  /// **'Connect\\n& Go'**
  String get connectn_go;

  /// No description provided for @community_you_trust.
  ///
  /// In en, this message translates to:
  /// **'Community You Trust'**
  String get community_you_trust;

  /// No description provided for @onboarding_complete.
  ///
  /// In en, this message translates to:
  /// **'onboarding_complete'**
  String get onboarding_complete;

  /// No description provided for @last_onboarding_version.
  ///
  /// In en, this message translates to:
  /// **'last_onboarding_version'**
  String get last_onboarding_version;

  /// No description provided for @ride_to_paris_10k.
  ///
  /// In en, this message translates to:
  /// **'Ride to Paris 10K'**
  String get ride_to_paris_10k;

  /// No description provided for @offer_your_ride.
  ///
  /// In en, this message translates to:
  /// **'Offer your ride'**
  String get offer_your_ride;

  /// No description provided for @paris_10k_2_seats_available.
  ///
  /// In en, this message translates to:
  /// **'Paris 10K • 2 seats available'**
  String get paris_10k_2_seats_available;

  /// No description provided for @estimated_earning.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED EARNING'**
  String get estimated_earning;

  /// No description provided for @fill_2_seats.
  ///
  /// In en, this message translates to:
  /// **'Fill 2 seats'**
  String get fill_2_seats;

  /// No description provided for @set_available_seats.
  ///
  /// In en, this message translates to:
  /// **'Set available seats'**
  String get set_available_seats;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// No description provided for @driver_tools.
  ///
  /// In en, this message translates to:
  /// **'Driver tools'**
  String get driver_tools;

  /// No description provided for @pickup_route.
  ///
  /// In en, this message translates to:
  /// **'Pickup route'**
  String get pickup_route;

  /// No description provided for @coordinate_pickup_before_the_event.
  ///
  /// In en, this message translates to:
  /// **'Coordinate pickup before the event'**
  String get coordinate_pickup_before_the_event;

  /// No description provided for @trip_plan.
  ///
  /// In en, this message translates to:
  /// **'Trip plan'**
  String get trip_plan;

  /// No description provided for @sun_15_jun.
  ///
  /// In en, this message translates to:
  /// **'Sun, 15 Jun'**
  String get sun_15_jun;

  /// No description provided for @paris_10k_2_passengers.
  ///
  /// In en, this message translates to:
  /// **'Paris 10K • 2 passengers'**
  String get paris_10k_2_passengers;

  /// No description provided for @inapp_chat.
  ///
  /// In en, this message translates to:
  /// **'In-app chat'**
  String get inapp_chat;

  /// No description provided for @confirm_bags_pickup_spot_and_arrival_time.
  ///
  /// In en, this message translates to:
  /// **'Confirm bags, pickup spot, and arrival time.'**
  String get confirm_bags_pickup_spot_and_arrival_time;

  /// No description provided for @runner_carpool_network.
  ///
  /// In en, this message translates to:
  /// **'Runner carpool network'**
  String get runner_carpool_network;

  /// No description provided for @travel_with_people_going_to_the_same_event.
  ///
  /// In en, this message translates to:
  /// **'Travel with people going to the same event.'**
  String get travel_with_people_going_to_the_same_event;

  /// No description provided for @sun_15_jun_2025.
  ///
  /// In en, this message translates to:
  /// **'Sun, 15 Jun 2025'**
  String get sun_15_jun_2025;

  /// No description provided for @pickup_near_paris_france.
  ///
  /// In en, this message translates to:
  /// **'Pickup near Paris, France'**
  String get pickup_near_paris_france;

  /// No description provided for @passenger_contribution_from_8.
  ///
  /// In en, this message translates to:
  /// **'Passenger contribution from €8'**
  String get passenger_contribution_from_8;

  /// No description provided for @find_a_ride_to_your_race.
  ///
  /// In en, this message translates to:
  /// **'Find a ride to your race'**
  String get find_a_ride_to_your_race;

  /// No description provided for @offer_seats_and_earn.
  ///
  /// In en, this message translates to:
  /// **'Offer seats and earn'**
  String get offer_seats_and_earn;

  /// No description provided for @plan_the_route_together.
  ///
  /// In en, this message translates to:
  /// **'Plan the route together'**
  String get plan_the_route_together;

  /// No description provided for @connect_safely_and_go.
  ///
  /// In en, this message translates to:
  /// **'Connect safely and go'**
  String get connect_safely_and_go;

  /// No description provided for @paris.
  ///
  /// In en, this message translates to:
  /// **'PARIS'**
  String get paris;

  /// No description provided for @driver_starts.
  ///
  /// In en, this message translates to:
  /// **'Driver starts'**
  String get driver_starts;

  /// No description provided for @route_opens_for_passengers.
  ///
  /// In en, this message translates to:
  /// **'Route opens for passengers'**
  String get route_opens_for_passengers;

  /// No description provided for @pickup_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Pickup confirmed'**
  String get pickup_confirmed;

  /// No description provided for @shared_meeting_point.
  ///
  /// In en, this message translates to:
  /// **'Shared meeting point'**
  String get shared_meeting_point;

  /// No description provided for @arrive_at_event.
  ///
  /// In en, this message translates to:
  /// **'Arrive at event'**
  String get arrive_at_event;

  /// No description provided for @paris_10k_race_village.
  ///
  /// In en, this message translates to:
  /// **'Paris 10K race village'**
  String get paris_10k_race_village;

  /// No description provided for @trusted_runners.
  ///
  /// In en, this message translates to:
  /// **'Trusted runners'**
  String get trusted_runners;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @before_pickup.
  ///
  /// In en, this message translates to:
  /// **'Before pickup'**
  String get before_pickup;

  /// No description provided for @live_route.
  ///
  /// In en, this message translates to:
  /// **'Live route'**
  String get live_route;

  /// No description provided for @trip_visibility.
  ///
  /// In en, this message translates to:
  /// **'Trip visibility'**
  String get trip_visibility;

  /// No description provided for @safer_rides.
  ///
  /// In en, this message translates to:
  /// **'Safer rides'**
  String get safer_rides;

  /// No description provided for @event_travel.
  ///
  /// In en, this message translates to:
  /// **'Event travel'**
  String get event_travel;

  /// No description provided for @from_8.
  ///
  /// In en, this message translates to:
  /// **'From €8'**
  String get from_8;

  /// No description provided for @onboardingEstimatedEarning.
  ///
  /// In en, this message translates to:
  /// **'€16'**
  String get onboardingEstimatedEarning;

  /// No description provided for @rides_available.
  ///
  /// In en, this message translates to:
  /// **'RIDES AVAILABLE'**
  String get rides_available;

  /// No description provided for @fuel_offset.
  ///
  /// In en, this message translates to:
  /// **'Fuel offset'**
  String get fuel_offset;

  /// No description provided for @earn.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earn;

  /// No description provided for @set_time.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get set_time;

  /// No description provided for @pickup_0640.
  ///
  /// In en, this message translates to:
  /// **'Pickup 06:40'**
  String get pickup_0640;

  /// No description provided for @previous_step.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get previous_step;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @cancel_anytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancel_anytime;

  /// No description provided for @save_about_16_compared_to_monthly.
  ///
  /// In en, this message translates to:
  /// **'Save about 16% compared to monthly'**
  String get save_about_16_compared_to_monthly;

  /// No description provided for @actionrequiredrequestedcapabilities.
  ///
  /// In en, this message translates to:
  /// **'actionRequiredRequestedCapabilities'**
  String get actionrequiredrequestedcapabilities;

  /// No description provided for @listed.
  ///
  /// In en, this message translates to:
  /// **'listed'**
  String get listed;

  /// No description provided for @platformpaused.
  ///
  /// In en, this message translates to:
  /// **'platformPaused'**
  String get platformpaused;

  /// No description provided for @rejectedfraud.
  ///
  /// In en, this message translates to:
  /// **'rejectedFraud'**
  String get rejectedfraud;

  /// No description provided for @rejectedincompleteverification.
  ///
  /// In en, this message translates to:
  /// **'rejectedIncompleteVerification'**
  String get rejectedincompleteverification;

  /// No description provided for @rejectedlisted.
  ///
  /// In en, this message translates to:
  /// **'rejectedListed'**
  String get rejectedlisted;

  /// No description provided for @rejectedother.
  ///
  /// In en, this message translates to:
  /// **'rejectedOther'**
  String get rejectedother;

  /// No description provided for @rejectedplatformfraud.
  ///
  /// In en, this message translates to:
  /// **'rejectedPlatformFraud'**
  String get rejectedplatformfraud;

  /// No description provided for @rejectedplatformother.
  ///
  /// In en, this message translates to:
  /// **'rejectedPlatformOther'**
  String get rejectedplatformother;

  /// No description provided for @rejectedplatformtermsofservice.
  ///
  /// In en, this message translates to:
  /// **'rejectedPlatformTermsOfService'**
  String get rejectedplatformtermsofservice;

  /// No description provided for @rejectedtermsofservice.
  ///
  /// In en, this message translates to:
  /// **'rejectedTermsOfService'**
  String get rejectedtermsofservice;

  /// No description provided for @requirementspastdue.
  ///
  /// In en, this message translates to:
  /// **'requirementsPastDue'**
  String get requirementspastdue;

  /// No description provided for @requirementspendingverification.
  ///
  /// In en, this message translates to:
  /// **'requirementsPendingVerification'**
  String get requirementspendingverification;

  /// No description provided for @underreview.
  ///
  /// In en, this message translates to:
  /// **'underReview'**
  String get underreview;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'canceled'**
  String get canceled;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @bankaccount.
  ///
  /// In en, this message translates to:
  /// **'bankAccount'**
  String get bankaccount;

  /// No description provided for @bank_account.
  ///
  /// In en, this message translates to:
  /// **'bank_account'**
  String get bank_account;

  /// No description provided for @google_play_billing_is_not_available_on_this_app_instance.
  ///
  /// In en, this message translates to:
  /// **'Google Play Billing is not available on this app instance. '**
  String get google_play_billing_is_not_available_on_this_app_instance;

  /// No description provided for @google_play_billing_is_unavailable_on_this_deviceaccount.
  ///
  /// In en, this message translates to:
  /// **'Google Play Billing is unavailable on this device/account.'**
  String get google_play_billing_is_unavailable_on_this_deviceaccount;

  /// No description provided for @this_subscription_product_is_not_available_for_your_accountregion_yet.
  ///
  /// In en, this message translates to:
  /// **'This subscription product is not available for your account/region yet.'**
  String
  get this_subscription_product_is_not_available_for_your_accountregion_yet;

  /// No description provided for @purchase_cancelled_by_user.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled by user.'**
  String get purchase_cancelled_by_user;

  /// No description provided for @channelerror.
  ///
  /// In en, this message translates to:
  /// **'channel-error'**
  String get channelerror;

  /// No description provided for @withdrawable_now_is_your_instantavailable_balance_you_can_transfer_this_to_your_bank_immediatelynn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable Now is your instant-available balance — you can transfer this to your bank immediately.\\n\\n'**
  String
  get withdrawable_now_is_your_instantavailable_balance_you_can_transfer_this_to_your_bank_immediatelynn;

  /// No description provided for @got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get got_it;

  /// No description provided for @withdrawable_now_is_your_instantavailable_balance_processing_funds_are_in_stripe.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable Now is your instant-available balance. Processing funds are in Stripe'**
  String
  get withdrawable_now_is_your_instantavailable_balance_processing_funds_are_in_stripe;

  /// No description provided for @your_stripe_account_id_is_missing_please_reconnect_your_payout_account.
  ///
  /// In en, this message translates to:
  /// **'Your Stripe account ID is missing. Please reconnect your payout account.'**
  String
  get your_stripe_account_id_is_missing_please_reconnect_your_payout_account;

  /// No description provided for @writeln_writelnl10nexportearningssummary_writeln.
  ///
  /// In en, this message translates to:
  /// **')\r\n      ..writeln()\r\n      ..writeln(l10n.exportEarningsSummary)\r\n      ..writeln(\r\n        '**
  String get writeln_writelnl10nexportearningssummary_writeln;

  /// No description provided for @get_paid_fornevery_ride.
  ///
  /// In en, this message translates to:
  /// **'Get paid for\nevery ride'**
  String get get_paid_fornevery_ride;

  /// No description provided for @set_up_eur_payouts_in_minutes_andnreceive_earnings_automatically.
  ///
  /// In en, this message translates to:
  /// **'Set up EUR payouts in minutes and\nreceive earnings automatically.'**
  String get set_up_eur_payouts_in_minutes_andnreceive_earnings_automatically;

  /// No description provided for @eur_balance.
  ///
  /// In en, this message translates to:
  /// **'EUR balance'**
  String get eur_balance;

  /// No description provided for @ready_for_eur_payout.
  ///
  /// In en, this message translates to:
  /// **'Ready for EUR payout'**
  String get ready_for_eur_payout;

  /// No description provided for @why_drivers_love_payouts_onnsportconnect.
  ///
  /// In en, this message translates to:
  /// **'Why drivers love payouts on\nSportConnect'**
  String get why_drivers_love_payouts_onnsportconnect;

  /// No description provided for @before_you_continue.
  ///
  /// In en, this message translates to:
  /// **'Before you continue'**
  String get before_you_continue;

  /// No description provided for @heres_what_youll_need_to_get_set_up.
  ///
  /// In en, this message translates to:
  /// **'Here’s what you’ll need to get set up.'**
  String get heres_what_youll_need_to_get_set_up;

  /// No description provided for @maybe_later.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybe_later;

  /// No description provided for @payouts_ready.
  ///
  /// In en, this message translates to:
  /// **'Payouts ready!'**
  String get payouts_ready;

  /// No description provided for @your_account_is_connected_and_yourenall_set_to_receive_earnings.
  ///
  /// In en, this message translates to:
  /// **'Your account is connected and you’re\nall set to receive earnings.'**
  String get your_account_is_connected_and_yourenall_set_to_receive_earnings;

  /// No description provided for @powered_by.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get powered_by;

  /// No description provided for @stripe.
  ///
  /// In en, this message translates to:
  /// **'stripe'**
  String get stripe;

  /// No description provided for @s.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get s;

  /// No description provided for @takes_about_3_minutes.
  ///
  /// In en, this message translates to:
  /// **'Takes about 3 minutes'**
  String get takes_about_3_minutes;

  /// No description provided for @your_security_is_our_priority.
  ///
  /// In en, this message translates to:
  /// **'Your security is our priority'**
  String get your_security_is_our_priority;

  /// No description provided for @sportconnect_partners_with_stripe_to_securely_collect_and_protect_your_information_your_data_is_encrypted_and_never_shared_with_us.
  ///
  /// In en, this message translates to:
  /// **'SportConnect partners with Stripe to securely collect and protect your information. Your data is encrypted and never shared with us.'**
  String
  get sportconnect_partners_with_stripe_to_securely_collect_and_protect_your_information_your_data_is_encrypted_and_never_shared_with_us;

  /// No description provided for @payout_account.
  ///
  /// In en, this message translates to:
  /// **'Payout account'**
  String get payout_account;

  /// No description provided for @bnp_paribas_4521.
  ///
  /// In en, this message translates to:
  /// **'BNP Paribas •••• 4521'**
  String get bnp_paribas_4521;

  /// No description provided for @next_payout.
  ///
  /// In en, this message translates to:
  /// **'Next payout'**
  String get next_payout;

  /// No description provided for @wed_28_may.
  ///
  /// In en, this message translates to:
  /// **'Wed, 28 May'**
  String get wed_28_may;

  /// No description provided for @payout_schedule.
  ///
  /// In en, this message translates to:
  /// **'Payout schedule'**
  String get payout_schedule;

  /// No description provided for @weekly_to_your_french_iban.
  ///
  /// In en, this message translates to:
  /// **'Weekly to your French IBAN'**
  String get weekly_to_your_french_iban;

  /// No description provided for @earnings_snapshot.
  ///
  /// In en, this message translates to:
  /// **'Earnings snapshot'**
  String get earnings_snapshot;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This week⌄'**
  String get this_week;

  /// No description provided for @youre_doing_great.
  ///
  /// In en, this message translates to:
  /// **'You’re doing great!'**
  String get youre_doing_great;

  /// No description provided for @keep_driving_more_rides_more_earnings.
  ///
  /// In en, this message translates to:
  /// **'Keep driving. More rides, more earnings.'**
  String get keep_driving_more_rides_more_earnings;

  /// No description provided for @connect_stripe_account.
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe account'**
  String get connect_stripe_account;

  /// No description provided for @continue_to_stripe.
  ///
  /// In en, this message translates to:
  /// **'Continue to Stripe'**
  String get continue_to_stripe;

  /// No description provided for @back_to_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get back_to_dashboard;

  /// No description provided for @need_help_visit_our.
  ///
  /// In en, this message translates to:
  /// **'Need help? Visit our '**
  String get need_help_visit_our;

  /// No description provided for @support_center.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get support_center;

  /// No description provided for @secure_by_stripe.
  ///
  /// In en, this message translates to:
  /// **'Secure by Stripe'**
  String get secure_by_stripe;

  /// No description provided for @pci_dss_compliant.
  ///
  /// In en, this message translates to:
  /// **'PCI DSS Compliant'**
  String get pci_dss_compliant;

  /// No description provided for @fast_payouts.
  ///
  /// In en, this message translates to:
  /// **'Fast payouts'**
  String get fast_payouts;

  /// No description provided for @secure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secure;

  /// No description provided for @eugrade_safety.
  ///
  /// In en, this message translates to:
  /// **'EU-grade safety'**
  String get eugrade_safety;

  /// No description provided for @low_fees.
  ///
  /// In en, this message translates to:
  /// **'Low fees'**
  String get low_fees;

  /// No description provided for @transparent_pricing.
  ///
  /// In en, this message translates to:
  /// **'Transparent pricing'**
  String get transparent_pricing;

  /// No description provided for @french_iban.
  ///
  /// In en, this message translates to:
  /// **'French IBAN'**
  String get french_iban;

  /// No description provided for @to_receive_eur_payouts.
  ///
  /// In en, this message translates to:
  /// **'To receive EUR payouts'**
  String get to_receive_eur_payouts;

  /// No description provided for @identity_verification.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identity_verification;

  /// No description provided for @carte_didentit_or_passport.
  ///
  /// In en, this message translates to:
  /// **'Carte d’identité or passport'**
  String get carte_didentit_or_passport;

  /// No description provided for @french_tax_details.
  ///
  /// In en, this message translates to:
  /// **'French tax details'**
  String get french_tax_details;

  /// No description provided for @for_french_tax_records.
  ///
  /// In en, this message translates to:
  /// **'For French tax records'**
  String get for_french_tax_records;

  /// No description provided for @payment_method_saved.
  ///
  /// In en, this message translates to:
  /// **'Payment method saved'**
  String get payment_method_saved;

  /// No description provided for @total_spent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get total_spent;

  /// No description provided for @instant_payouts_can_be_cancelled_while_still_pending_once_in_transit_your_bank_is_already_processing_the_transfer.
  ///
  /// In en, this message translates to:
  /// **'Instant payouts can be cancelled while still pending. Once in transit, your bank is already processing the transfer.'**
  String
  get instant_payouts_can_be_cancelled_while_still_pending_once_in_transit_your_bank_is_already_processing_the_transfer;

  /// No description provided for @payout_progress.
  ///
  /// In en, this message translates to:
  /// **'Payout Progress'**
  String get payout_progress;

  /// No description provided for @why_did_this_fail.
  ///
  /// In en, this message translates to:
  /// **'Why did this fail?'**
  String get why_did_this_fail;

  /// No description provided for @payout_requested.
  ///
  /// In en, this message translates to:
  /// **'Payout Requested'**
  String get payout_requested;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @in_transit_to_bank.
  ///
  /// In en, this message translates to:
  /// **'In Transit to Bank'**
  String get in_transit_to_bank;

  /// No description provided for @funds_arrived.
  ///
  /// In en, this message translates to:
  /// **'Funds Arrived'**
  String get funds_arrived;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @this_payout_cannot_be_cancelled_no_stripe_reference_found.
  ///
  /// In en, this message translates to:
  /// **'This payout cannot be cancelled — no Stripe reference found.'**
  String get this_payout_cannot_be_cancelled_no_stripe_reference_found;

  /// No description provided for @choose_your_plan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get choose_your_plan;

  /// No description provided for @upgrade_your_sportconnect_account_in_seconds.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your SportConnect account in seconds.'**
  String get upgrade_your_sportconnect_account_in_seconds;

  /// No description provided for @loading_subscription_plans.
  ///
  /// In en, this message translates to:
  /// **'Loading subscription plans...'**
  String get loading_subscription_plans;

  /// No description provided for @retry_loading_plans.
  ///
  /// In en, this message translates to:
  /// **'Retry loading plans'**
  String get retry_loading_plans;

  /// No description provided for @your_payment_details_are_encrypted_and_processed_securely.
  ///
  /// In en, this message translates to:
  /// **'Your payment details are encrypted and processed securely.'**
  String get your_payment_details_are_encrypted_and_processed_securely;

  /// No description provided for @subscribe_now.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribe_now;

  /// No description provided for @premium_checkout.
  ///
  /// In en, this message translates to:
  /// **'Premium Checkout'**
  String get premium_checkout;

  /// No description provided for @premium_activated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Premium activated successfully.'**
  String get premium_activated_successfully;

  /// No description provided for @upgrade_to_pro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgrade_to_pro;

  /// No description provided for @premium_carpooling_madenfor_runners_like_you.
  ///
  /// In en, this message translates to:
  /// **'Premium carpooling made\\nfor runners like you'**
  String get premium_carpooling_madenfor_runners_like_you;

  /// No description provided for @everything_you_get.
  ///
  /// In en, this message translates to:
  /// **'Everything you get'**
  String get everything_you_get;

  /// No description provided for @pricingUnavailableCheckYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Pricing unavailable — check your connection'**
  String get pricingUnavailableCheckYourConnection;

  /// No description provided for @pricingUnavailableTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Pricing unavailable — tap to retry'**
  String get pricingUnavailableTapToRetry;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @billedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// No description provided for @trusted_by_12000_runners.
  ///
  /// In en, this message translates to:
  /// **'Trusted by 12,000+ runners'**
  String get trusted_by_12000_runners;

  /// No description provided for @start_free_trial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get start_free_trial;

  /// No description provided for @smart_ride_matching.
  ///
  /// In en, this message translates to:
  /// **'Smart Ride Matching'**
  String get smart_ride_matching;

  /// No description provided for @unlimited_saved_routes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Saved Routes'**
  String get unlimited_saved_routes;

  /// No description provided for @verified_community.
  ///
  /// In en, this message translates to:
  /// **'Verified Community'**
  String get verified_community;

  /// No description provided for @crew_coordination.
  ///
  /// In en, this message translates to:
  /// **'Crew Coordination'**
  String get crew_coordination;

  /// No description provided for @race_day_priority.
  ///
  /// In en, this message translates to:
  /// **'Race Day Priority'**
  String get race_day_priority;

  /// No description provided for @priority_support.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get priority_support;

  /// No description provided for @smart_match.
  ///
  /// In en, this message translates to:
  /// **'Smart Match'**
  String get smart_match;

  /// No description provided for @unlimited_routes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Routes'**
  String get unlimited_routes;

  /// No description provided for @verified_riders.
  ///
  /// In en, this message translates to:
  /// **'Verified Riders'**
  String get verified_riders;

  /// No description provided for @crew_rides.
  ///
  /// In en, this message translates to:
  /// **'Crew Rides'**
  String get crew_rides;

  /// No description provided for @race_priority.
  ///
  /// In en, this message translates to:
  /// **'Race Priority'**
  String get race_priority;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @appStoreBilling.
  ///
  /// In en, this message translates to:
  /// **'App Store billing'**
  String get appStoreBilling;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get securePayment;

  /// No description provided for @joinRunnersWorldwide.
  ///
  /// In en, this message translates to:
  /// **'Join runners worldwide'**
  String get joinRunnersWorldwide;

  /// No description provided for @smartRideMatchingDescription.
  ///
  /// In en, this message translates to:
  /// **'Auto-paired with runners heading to your race or training spot.'**
  String get smartRideMatchingDescription;

  /// No description provided for @unlimitedSavedRoutesDescription.
  ///
  /// In en, this message translates to:
  /// **'Save and share your favorite carpool routes with your crew.'**
  String get unlimitedSavedRoutesDescription;

  /// No description provided for @verifiedCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Every rider is ID-verified. Ride safe with trusted runners.'**
  String get verifiedCommunityDescription;

  /// No description provided for @crewCoordinationDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize group rides for your entire running club in one tap.'**
  String get crewCoordinationDescription;

  /// No description provided for @raceDayPriorityDescription.
  ///
  /// In en, this message translates to:
  /// **'First pick on rides for marathon day and major events.'**
  String get raceDayPriorityDescription;

  /// No description provided for @prioritySupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Skip the queue. Get help within minutes, not hours.'**
  String get prioritySupportDescription;

  /// No description provided for @moneybacknguarantee.
  ///
  /// In en, this message translates to:
  /// **'Money-back\\nguarantee'**
  String get moneybacknguarantee;

  /// No description provided for @cancelnanytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel\\nanytime'**
  String get cancelnanytime;

  /// No description provided for @securenpayment.
  ///
  /// In en, this message translates to:
  /// **'Secure\\npayment'**
  String get securenpayment;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @thisweek.
  ///
  /// In en, this message translates to:
  /// **'thisWeek'**
  String get thisweek;

  /// No description provided for @unable_to_complete_checkout_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete checkout. Please try again.'**
  String get unable_to_complete_checkout_please_try_again;

  /// No description provided for @version_119.
  ///
  /// In en, this message translates to:
  /// **'Version 1.1.9'**
  String get version_119;

  /// No description provided for @built_with_flutter.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter'**
  String get built_with_flutter;

  /// No description provided for @sportconnect_is_a_carpooling_and_rideshare_platform_designed.
  ///
  /// In en, this message translates to:
  /// **'SportConnect is a carpooling and rideshare platform designed '**
  String get sportconnect_is_a_carpooling_and_rideshare_platform_designed;

  /// No description provided for @join_the_community.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get join_the_community;

  /// No description provided for @open_source_licenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get open_source_licenses;

  /// No description provided for @total_xp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get total_xp;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @platinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get platinum;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @background_check_passed.
  ///
  /// In en, this message translates to:
  /// **'Background Check Passed'**
  String get background_check_passed;

  /// No description provided for @your_background_check_is_complete_and_you_are_verified_to_drive_with_sportconnect.
  ///
  /// In en, this message translates to:
  /// **'Your background check is complete and you are verified to drive with SportConnect.'**
  String
  get your_background_check_is_complete_and_you_are_verified_to_drive_with_sportconnect;

  /// No description provided for @attach_image.
  ///
  /// In en, this message translates to:
  /// **'Attach image'**
  String get attach_image;

  /// No description provided for @action_required.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get action_required;

  /// No description provided for @driver_license.
  ///
  /// In en, this message translates to:
  /// **'Driver License'**
  String get driver_license;

  /// No description provided for @vehicle_registration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration'**
  String get vehicle_registration;

  /// No description provided for @vehicle_insurance.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Insurance'**
  String get vehicle_insurance;

  /// No description provided for @upload_feature_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Upload feature coming soon'**
  String get upload_feature_coming_soon;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @try_different_keywords_or_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or contact support'**
  String get try_different_keywords_or_contact_support;

  /// No description provided for @getting_started.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get getting_started;

  /// No description provided for @rides_booking.
  ///
  /// In en, this message translates to:
  /// **'Rides & Booking'**
  String get rides_booking;

  /// No description provided for @safety_trust.
  ///
  /// In en, this message translates to:
  /// **'Safety & Trust'**
  String get safety_trust;

  /// No description provided for @account_profile.
  ///
  /// In en, this message translates to:
  /// **'Account & Profile'**
  String get account_profile;

  /// No description provided for @help_center_getting_started_create_account_question.
  ///
  /// In en, this message translates to:
  /// **'How do I create an account?'**
  String get help_center_getting_started_create_account_question;

  /// No description provided for @help_center_getting_started_create_account_answer.
  ///
  /// In en, this message translates to:
  /// **'Download the app, tap \"Sign Up\", and follow the wizard. You can sign up with email, Google, or Apple ID.'**
  String get help_center_getting_started_create_account_answer;

  /// No description provided for @help_center_getting_started_switch_role_question.
  ///
  /// In en, this message translates to:
  /// **'How do I switch between rider and driver?'**
  String get help_center_getting_started_switch_role_question;

  /// No description provided for @help_center_getting_started_switch_role_answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings > Switch Role. If you haven\'t registered as a driver yet, you\'ll need to complete the driver onboarding process.'**
  String get help_center_getting_started_switch_role_answer;

  /// No description provided for @help_center_getting_started_free_question.
  ///
  /// In en, this message translates to:
  /// **'Is SportConnect free to use?'**
  String get help_center_getting_started_free_question;

  /// No description provided for @help_center_getting_started_free_answer.
  ///
  /// In en, this message translates to:
  /// **'Creating an account is free. Riders pay per ride booked. Drivers earn money by offering rides minus a small service fee.'**
  String get help_center_getting_started_free_answer;

  /// No description provided for @help_center_rides_booking_question.
  ///
  /// In en, this message translates to:
  /// **'How do I book a ride?'**
  String get help_center_rides_booking_question;

  /// No description provided for @help_center_rides_booking_answer.
  ///
  /// In en, this message translates to:
  /// **'Search for rides from the Explore tab, select a ride that matches your route, review the details, and tap \"Book Ride\".'**
  String get help_center_rides_booking_answer;

  /// No description provided for @help_center_rides_cancel_question.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a booked ride?'**
  String get help_center_rides_cancel_question;

  /// No description provided for @help_center_rides_cancel_answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, go to Activity > select the ride > Cancel. Please note that frequent cancellations may affect your rating.'**
  String get help_center_rides_cancel_answer;

  /// No description provided for @help_center_rides_matching_question.
  ///
  /// In en, this message translates to:
  /// **'How does ride matching work?'**
  String get help_center_rides_matching_question;

  /// No description provided for @help_center_rides_matching_answer.
  ///
  /// In en, this message translates to:
  /// **'Our algorithm matches riders with drivers based on route overlap, departure time, and user preferences. You can also request a ride and let drivers find you.'**
  String get help_center_rides_matching_answer;

  /// No description provided for @help_center_rides_late_question.
  ///
  /// In en, this message translates to:
  /// **'What if my ride is late?'**
  String get help_center_rides_late_question;

  /// No description provided for @help_center_rides_late_answer.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive real-time updates on your ride status. If the driver is significantly late, you can contact them directly through the in-app chat.'**
  String get help_center_rides_late_answer;

  /// No description provided for @help_center_payments_question.
  ///
  /// In en, this message translates to:
  /// **'How do payments work?'**
  String get help_center_payments_question;

  /// No description provided for @help_center_payments_answer.
  ///
  /// In en, this message translates to:
  /// **'Payments are processed securely through Stripe. Riders pay when booking, and drivers receive earnings after ride completion.'**
  String get help_center_payments_answer;

  /// No description provided for @help_center_payouts_question.
  ///
  /// In en, this message translates to:
  /// **'When do drivers get paid?'**
  String get help_center_payouts_question;

  /// No description provided for @help_center_payouts_answer.
  ///
  /// In en, this message translates to:
  /// **'Drivers receive payouts weekly to their linked Stripe account. You can track your earnings in the Earnings tab.'**
  String get help_center_payouts_answer;

  /// No description provided for @help_center_fees_question.
  ///
  /// In en, this message translates to:
  /// **'What are the service fees?'**
  String get help_center_fees_question;

  /// No description provided for @help_center_fees_answer.
  ///
  /// In en, this message translates to:
  /// **'SportConnect charges a small service fee (typically 10%) to cover platform costs, payment processing, and insurance.'**
  String get help_center_fees_answer;

  /// No description provided for @help_center_safety_question.
  ///
  /// In en, this message translates to:
  /// **'How is my safety ensured?'**
  String get help_center_safety_question;

  /// No description provided for @help_center_safety_answer.
  ///
  /// In en, this message translates to:
  /// **'All drivers undergo verification. Rides include live GPS tracking, in-app chat, and all trips are logged for safety.'**
  String get help_center_safety_answer;

  /// No description provided for @help_center_safety_report_question.
  ///
  /// In en, this message translates to:
  /// **'How do I report a safety issue?'**
  String get help_center_safety_report_question;

  /// No description provided for @help_center_safety_report_answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Report a Problem during or after a ride. Safety reports are prioritized and reviewed within 24 hours.'**
  String get help_center_safety_report_answer;

  /// No description provided for @help_center_safety_share_question.
  ///
  /// In en, this message translates to:
  /// **'Can I share my ride with someone?'**
  String get help_center_safety_share_question;

  /// No description provided for @help_center_safety_share_answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, during an active ride you can share your live trip details with trusted contacts.'**
  String get help_center_safety_share_answer;

  /// No description provided for @help_center_account_verify_question.
  ///
  /// In en, this message translates to:
  /// **'How do I verify my account?'**
  String get help_center_account_verify_question;

  /// No description provided for @help_center_account_verify_answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Verify Account. You can verify your email, phone number, and provide government ID for full verification.'**
  String get help_center_account_verify_answer;

  /// No description provided for @help_center_account_delete_question.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get help_center_account_delete_question;

  /// No description provided for @help_center_account_delete_answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Account Actions > Delete Account. This action is permanent and cannot be undone.'**
  String get help_center_account_delete_answer;

  /// No description provided for @help_center_account_email_question.
  ///
  /// In en, this message translates to:
  /// **'Can I change my email address?'**
  String get help_center_account_email_question;

  /// No description provided for @help_center_account_email_answer.
  ///
  /// In en, this message translates to:
  /// **'Currently, you can update your display name and profile info. For email changes, please contact support.'**
  String get help_center_account_email_answer;

  /// No description provided for @my_vehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get my_vehicles;

  /// No description provided for @manage_your_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Manage your vehicles'**
  String get manage_your_vehicles;

  /// No description provided for @my_events.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get my_events;

  /// No description provided for @created_joined_events.
  ///
  /// In en, this message translates to:
  /// **'Created & joined events'**
  String get created_joined_events;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @view_your_badges_rewards.
  ///
  /// In en, this message translates to:
  /// **'View your badges & rewards'**
  String get view_your_badges_rewards;

  /// No description provided for @view_your_notifications.
  ///
  /// In en, this message translates to:
  /// **'View your notifications'**
  String get view_your_notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @app_preferences_privacy.
  ///
  /// In en, this message translates to:
  /// **'App preferences & privacy'**
  String get app_preferences_privacy;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'report'**
  String get report;

  /// No description provided for @attach_evidence.
  ///
  /// In en, this message translates to:
  /// **'Attach evidence'**
  String get attach_evidence;

  /// No description provided for @manage_booking_pickup_radius_payout_and_map_visibility.
  ///
  /// In en, this message translates to:
  /// **'Manage booking, pickup radius, payout, and map visibility'**
  String get manage_booking_pickup_radius_payout_and_map_visibility;

  /// No description provided for @choose_map_appearance.
  ///
  /// In en, this message translates to:
  /// **'Choose map appearance'**
  String get choose_map_appearance;

  /// No description provided for @by_using_sportconnect_you_consent_to_the_data_processing_described_above_and_in_our_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'By using SportConnect, you consent to the data processing described above and in our Privacy Policy.'**
  String
  get by_using_sportconnect_you_consent_to_the_data_processing_described_above_and_in_our_privacy_policy;

  /// No description provided for @sportconnect_premium.
  ///
  /// In en, this message translates to:
  /// **'SportConnect Premium'**
  String get sportconnect_premium;

  /// No description provided for @unlock_smart_matching_priority_rides_more.
  ///
  /// In en, this message translates to:
  /// **'Unlock smart matching, priority rides & more'**
  String get unlock_smart_matching_priority_rides_more;

  /// No description provided for @notification_permission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notification_permission;

  /// No description provided for @reallow_push_notifications_for_this_device.
  ///
  /// In en, this message translates to:
  /// **'Re-allow push notifications for this device'**
  String get reallow_push_notifications_for_this_device;

  /// No description provided for @analytics_crash_reports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Crash Reports'**
  String get analytics_crash_reports;

  /// No description provided for @allow_anonymous_usage_data_and_crash_reports.
  ///
  /// In en, this message translates to:
  /// **'Allow anonymous usage data and crash reports'**
  String get allow_anonymous_usage_data_and_crash_reports;

  /// No description provided for @data_processing_notice.
  ///
  /// In en, this message translates to:
  /// **'Data Processing Notice'**
  String get data_processing_notice;

  /// No description provided for @how_we_collect_use_and_protect_your_data.
  ///
  /// In en, this message translates to:
  /// **'How we collect, use, and protect your data'**
  String get how_we_collect_use_and_protect_your_data;

  /// No description provided for @withdraw_consent.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Consent'**
  String get withdraw_consent;

  /// No description provided for @manage_or_withdraw_your_data_consent.
  ///
  /// In en, this message translates to:
  /// **'Manage or withdraw your data consent'**
  String get manage_or_withdraw_your_data_consent;

  /// No description provided for @download_my_data.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get download_my_data;

  /// No description provided for @export_a_copy_of_your_personal_data.
  ///
  /// In en, this message translates to:
  /// **'Export a copy of your personal data'**
  String get export_a_copy_of_your_personal_data;

  /// No description provided for @view_your_past_rides_and_charges.
  ///
  /// In en, this message translates to:
  /// **'View your past rides and charges'**
  String get view_your_past_rides_and_charges;

  /// No description provided for @update_your_account_password.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get update_your_account_password;

  /// No description provided for @get_help_from_our_team.
  ///
  /// In en, this message translates to:
  /// **'Get help from our team'**
  String get get_help_from_our_team;

  /// No description provided for @manage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manage_subscription;

  /// No description provided for @cancel_or_change_your_plan_in_the_store.
  ///
  /// In en, this message translates to:
  /// **'Cancel or change your plan in the store'**
  String get cancel_or_change_your_plan_in_the_store;

  /// No description provided for @restore_purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restore_purchases;

  /// No description provided for @reapply_your_active_subscription.
  ///
  /// In en, this message translates to:
  /// **'Re-apply your active subscription'**
  String get reapply_your_active_subscription;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @could_not_open_subscription_management.
  ///
  /// In en, this message translates to:
  /// **'Could not open subscription management.'**
  String get could_not_open_subscription_management;

  /// No description provided for @available_forms.
  ///
  /// In en, this message translates to:
  /// **'Available Forms'**
  String get available_forms;

  /// No description provided for @downloading_document.
  ///
  /// In en, this message translates to:
  /// **'Downloading document...'**
  String get downloading_document;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @notAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get notAvailableYet;

  /// No description provided for @thisPlanIsNotAvailableFromTheStoreYet.
  ///
  /// In en, this message translates to:
  /// **'This plan is not available from the store yet.'**
  String get thisPlanIsNotAvailableFromTheStoreYet;

  /// No description provided for @protect_your_account.
  ///
  /// In en, this message translates to:
  /// **'Protect your account'**
  String get protect_your_account;

  /// No description provided for @twofactor_authentication_adds_an_extra_layer_of_security_to_your_account_to_log_in_you.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication adds an extra layer of security to your account. To log in, you'**
  String
  get twofactor_authentication_adds_an_extra_layer_of_security_to_your_account_to_log_in_you;

  /// No description provided for @sms_verification.
  ///
  /// In en, this message translates to:
  /// **'SMS Verification'**
  String get sms_verification;

  /// No description provided for @receive_codes_via_text_message.
  ///
  /// In en, this message translates to:
  /// **'Receive codes via text message'**
  String get receive_codes_via_text_message;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get medium;

  /// No description provided for @please_describe_the_issue.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get please_describe_the_issue;

  /// No description provided for @inapp.
  ///
  /// In en, this message translates to:
  /// **'In-App'**
  String get inapp;

  /// No description provided for @driver_review.
  ///
  /// In en, this message translates to:
  /// **'Driver Review'**
  String get driver_review;

  /// No description provided for @passenger_review.
  ///
  /// In en, this message translates to:
  /// **'Passenger Review'**
  String get passenger_review;

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get just_now;

  /// No description provided for @as_driver.
  ///
  /// In en, this message translates to:
  /// **'As Driver'**
  String get as_driver;

  /// No description provided for @as_rider.
  ///
  /// In en, this message translates to:
  /// **'As Rider'**
  String get as_rider;

  /// No description provided for @report_review.
  ///
  /// In en, this message translates to:
  /// **'Report Review'**
  String get report_review;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @departure_time.
  ///
  /// In en, this message translates to:
  /// **'departure_time'**
  String get departure_time;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'scheduled'**
  String get scheduled;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'refunded'**
  String get refunded;

  /// No description provided for @partiallyrefunded.
  ///
  /// In en, this message translates to:
  /// **'partiallyRefunded'**
  String get partiallyrefunded;

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'instant'**
  String get instant;

  /// No description provided for @marked_as_noshow.
  ///
  /// In en, this message translates to:
  /// **'Marked as No-Show'**
  String get marked_as_noshow;

  /// No description provided for @ride_delayed.
  ///
  /// In en, this message translates to:
  /// **'Ride Delayed'**
  String get ride_delayed;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @no_pending_requests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get no_pending_requests;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @destination_is_locked_because_an_event_is_selected.
  ///
  /// In en, this message translates to:
  /// **'Destination is locked because an event is selected.'**
  String get destination_is_locked_because_an_event_is_selected;

  /// No description provided for @how_was_your_passenger.
  ///
  /// In en, this message translates to:
  /// **'How was your passenger?'**
  String get how_was_your_passenger;

  /// No description provided for @your_honest_feedback_helps_build_a_safer_more_reliable_community.
  ///
  /// In en, this message translates to:
  /// **'Your honest feedback helps build a safer, more reliable community.'**
  String get your_honest_feedback_helps_build_a_safer_more_reliable_community;

  /// No description provided for @no_accepted_passengers_to_rate_for_this_ride.
  ///
  /// In en, this message translates to:
  /// **'No accepted passengers to rate for this ride.'**
  String get no_accepted_passengers_to_rate_for_this_ride;

  /// No description provided for @select_passenger_to_rate.
  ///
  /// In en, this message translates to:
  /// **'Select passenger to rate'**
  String get select_passenger_to_rate;

  /// No description provided for @comment_optional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get comment_optional;

  /// No description provided for @passenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passenger;

  /// No description provided for @message_passenger.
  ///
  /// In en, this message translates to:
  /// **'Message passenger'**
  String get message_passenger;

  /// No description provided for @in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get in_progress;

  /// No description provided for @loading_route.
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get loading_route;

  /// No description provided for @waiting_for_driver.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver'**
  String get waiting_for_driver;

  /// No description provided for @location_access_denied_tap_to_open_settings_and_reenable.
  ///
  /// In en, this message translates to:
  /// **'Location access denied. Tap to open Settings and re-enable.'**
  String get location_access_denied_tap_to_open_settings_and_reenable;

  /// No description provided for @driver_location_unavailable_for_5_min.
  ///
  /// In en, this message translates to:
  /// **'Driver location unavailable for 5+ min'**
  String get driver_location_unavailable_for_5_min;

  /// No description provided for @poor_connection_updates_may_be_delayed.
  ///
  /// In en, this message translates to:
  /// **'Poor connection — updates may be delayed'**
  String get poor_connection_updates_may_be_delayed;

  /// No description provided for @your_pickup_code.
  ///
  /// In en, this message translates to:
  /// **'Your Pickup Code'**
  String get your_pickup_code;

  /// No description provided for @show_this_to_your_driver.
  ///
  /// In en, this message translates to:
  /// **'Show this to your driver'**
  String get show_this_to_your_driver;

  /// No description provided for @show_my_pickup_code.
  ///
  /// In en, this message translates to:
  /// **'Show my pickup code'**
  String get show_my_pickup_code;

  /// No description provided for @your_pickup_confirmation_code.
  ///
  /// In en, this message translates to:
  /// **'Your pickup confirmation code'**
  String get your_pickup_confirmation_code;

  /// No description provided for @trip_is_taking_longer_than_expected_is_everything_okay.
  ///
  /// In en, this message translates to:
  /// **'Trip is taking longer than expected — is everything okay?'**
  String get trip_is_taking_longer_than_expected_is_everything_okay;

  /// No description provided for @complete_payment_to_confirm_your_seat.
  ///
  /// In en, this message translates to:
  /// **'Complete payment to confirm your seat'**
  String get complete_payment_to_confirm_your_seat;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @night_ride_stay_alert_and_share_your_trip_with_someone_you_trust.
  ///
  /// In en, this message translates to:
  /// **'Night ride — stay alert and share your trip with someone you trust'**
  String get night_ride_stay_alert_and_share_your_trip_with_someone_you_trust;

  /// No description provided for @route_deviation_detected.
  ///
  /// In en, this message translates to:
  /// **'Route Deviation Detected'**
  String get route_deviation_detected;

  /// No description provided for @trip_progress.
  ///
  /// In en, this message translates to:
  /// **'Trip Progress'**
  String get trip_progress;

  /// No description provided for @driver_at_pickup.
  ///
  /// In en, this message translates to:
  /// **'Driver at Pickup'**
  String get driver_at_pickup;

  /// No description provided for @price_summary.
  ///
  /// In en, this message translates to:
  /// **'Price summary'**
  String get price_summary;

  /// No description provided for @cancellation_policy.
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get cancellation_policy;

  /// No description provided for @you_can_cancel_before_the_driver_accepts_your_request.
  ///
  /// In en, this message translates to:
  /// **'You can cancel before the driver accepts your request.'**
  String get you_can_cancel_before_the_driver_accepts_your_request;

  /// No description provided for @totaln.
  ///
  /// In en, this message translates to:
  /// **'Total\\n'**
  String get totaln;

  /// No description provided for @complete_booking.
  ///
  /// In en, this message translates to:
  /// **'Complete booking'**
  String get complete_booking;

  /// No description provided for @review_your_ride_before_sending_the_request.
  ///
  /// In en, this message translates to:
  /// **'Review your ride before sending the request'**
  String get review_your_ride_before_sending_the_request;

  /// No description provided for @choose_how_many_seats_you_need.
  ///
  /// In en, this message translates to:
  /// **'Choose how many seats you need'**
  String get choose_how_many_seats_you_need;

  /// No description provided for @booking_request.
  ///
  /// In en, this message translates to:
  /// **'Booking request'**
  String get booking_request;

  /// No description provided for @the_driver_will_approve_your_request.
  ///
  /// In en, this message translates to:
  /// **'The driver will approve your request'**
  String get the_driver_will_approve_your_request;

  /// No description provided for @protected_booking.
  ///
  /// In en, this message translates to:
  /// **'Protected booking'**
  String get protected_booking;

  /// No description provided for @your_request_is_safely_recorded_in_sportconnect.
  ///
  /// In en, this message translates to:
  /// **'Your request is safely recorded in SportConnect'**
  String get your_request_is_safely_recorded_in_sportconnect;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @pickup_point.
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get pickup_point;

  /// No description provided for @dropoff_point.
  ///
  /// In en, this message translates to:
  /// **'Drop-off point'**
  String get dropoff_point;

  /// No description provided for @seat_price.
  ///
  /// In en, this message translates to:
  /// **'Seat price'**
  String get seat_price;

  /// No description provided for @seats_selected.
  ///
  /// In en, this message translates to:
  /// **'Seats selected'**
  String get seats_selected;

  /// No description provided for @service_fee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get service_fee;

  /// No description provided for @booking_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get booking_confirmed;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get price;

  /// No description provided for @are_you_sure_you_want_to_cancel_this_ride.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride?'**
  String get are_you_sure_you_want_to_cancel_this_ride;

  /// No description provided for @frequent_cancellations_may_affect_your_account_rating.
  ///
  /// In en, this message translates to:
  /// **'Frequent cancellations may affect your account rating.'**
  String get frequent_cancellations_may_affect_your_account_rating;

  /// No description provided for @please_let_us_know_why_you.
  ///
  /// In en, this message translates to:
  /// **'Please let us know why you'**
  String get please_let_us_know_why_you;

  /// No description provided for @select_a_reason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get select_a_reason;

  /// No description provided for @additional_comments_optional.
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get additional_comments_optional;

  /// No description provided for @unable_to_load_ride_completion_details.
  ///
  /// In en, this message translates to:
  /// **'Unable to load ride completion details.'**
  String get unable_to_load_ride_completion_details;

  /// No description provided for @trip_completed.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get trip_completed;

  /// No description provided for @thanks_for_riding_with_sportconnect.
  ///
  /// In en, this message translates to:
  /// **'Thanks for riding with SportConnect'**
  String get thanks_for_riding_with_sportconnect;

  /// No description provided for @trip_summary.
  ///
  /// In en, this message translates to:
  /// **'Trip Summary'**
  String get trip_summary;

  /// No description provided for @fare_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Fare Breakdown'**
  String get fare_breakdown;

  /// No description provided for @submitting_ride_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Submitting ride, please wait...'**
  String get submitting_ride_please_wait;

  /// No description provided for @please_set_origin_and_destination_in_step_1.
  ///
  /// In en, this message translates to:
  /// **'Please set origin and destination in Step 1'**
  String get please_set_origin_and_destination_in_step_1;

  /// No description provided for @origin_and_destination_cannot_be_the_same_location.
  ///
  /// In en, this message translates to:
  /// **'Origin and destination cannot be the same location'**
  String get origin_and_destination_cannot_be_the_same_location;

  /// No description provided for @please_set_a_departure_date_and_time_in_step_1.
  ///
  /// In en, this message translates to:
  /// **'Please set a departure date and time in Step 1'**
  String get please_set_a_departure_date_and_time_in_step_1;

  /// No description provided for @departure_time_must_be_in_the_future_go_back_to_step_1.
  ///
  /// In en, this message translates to:
  /// **'Departure time must be in the future — go back to Step 1'**
  String get departure_time_must_be_in_the_future_go_back_to_step_1;

  /// No description provided for @departure_must_be_at_least_15_minutes_from_now.
  ///
  /// In en, this message translates to:
  /// **'Departure must be at least 15 minutes from now'**
  String get departure_must_be_at_least_15_minutes_from_now;

  /// No description provided for @please_select_a_vehicle_in_step_2.
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle in Step 2'**
  String get please_select_a_vehicle_in_step_2;

  /// No description provided for @number_of_seats_must_be_between_1_and_8_go_back_to_step_2.
  ///
  /// In en, this message translates to:
  /// **'Number of seats must be between 1 and 8 — go back to Step 2'**
  String get number_of_seats_must_be_between_1_and_8_go_back_to_step_2;

  /// No description provided for @please_select_at_least_one_recurring_day.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one recurring day'**
  String get please_select_at_least_one_recurring_day;

  /// No description provided for @please_set_a_recurring_end_date.
  ///
  /// In en, this message translates to:
  /// **'Please set a recurring end date'**
  String get please_set_a_recurring_end_date;

  /// No description provided for @please_enter_both_locations.
  ///
  /// In en, this message translates to:
  /// **'Please enter both locations'**
  String get please_enter_both_locations;

  /// No description provided for @pickup_and_destination_cannot_be_the_same_location.
  ///
  /// In en, this message translates to:
  /// **'Pickup and destination cannot be the same location'**
  String get pickup_and_destination_cannot_be_the_same_location;

  /// No description provided for @cannot_search_for_past_dates.
  ///
  /// In en, this message translates to:
  /// **'Cannot search for past dates'**
  String get cannot_search_for_past_dates;

  /// No description provided for @seats_must_be_between_1_and_4.
  ///
  /// In en, this message translates to:
  /// **'Seats must be between 1 and 4'**
  String get seats_must_be_between_1_and_4;

  /// No description provided for @cancelled_by_user.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by user'**
  String get cancelled_by_user;

  /// No description provided for @gasoline.
  ///
  /// In en, this message translates to:
  /// **'Gasoline'**
  String get gasoline;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @plugin_hybrid.
  ///
  /// In en, this message translates to:
  /// **'Plug-in Hybrid'**
  String get plugin_hybrid;

  /// No description provided for @hydrogen.
  ///
  /// In en, this message translates to:
  /// **'Hydrogen'**
  String get hydrogen;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @van.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @bicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get bicycle;

  /// No description provided for @your_fleet.
  ///
  /// In en, this message translates to:
  /// **'Your Fleet'**
  String get your_fleet;

  /// No description provided for @register_a_new_car_for_carpool_rides.
  ///
  /// In en, this message translates to:
  /// **'Register a new car for carpool rides'**
  String get register_a_new_car_for_carpool_rides;

  /// No description provided for @in_use.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get in_use;

  /// No description provided for @riders_see_this_photo_before_booking.
  ///
  /// In en, this message translates to:
  /// **'Riders see this photo before booking'**
  String get riders_see_this_photo_before_booking;

  /// No description provided for @inlineEventChooseEvent.
  ///
  /// In en, this message translates to:
  /// **'Choose an event'**
  String get inlineEventChooseEvent;

  /// No description provided for @inlineEventLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'Link to a sport event (optional)'**
  String get inlineEventLinkOptional;

  /// No description provided for @inlineEventClearSelected.
  ///
  /// In en, this message translates to:
  /// **'Clear selected event'**
  String get inlineEventClearSelected;

  /// No description provided for @inlineEventSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search loaded events by title, place, organizer'**
  String get inlineEventSearchHint;

  /// No description provided for @inlineEventClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get inlineEventClearSearch;

  /// No description provided for @inlineEventAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inlineEventAll;

  /// No description provided for @inlineEventCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load events'**
  String get inlineEventCouldNotLoad;

  /// No description provided for @inlineEventNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching loaded events'**
  String get inlineEventNoMatches;

  /// No description provided for @inlineEventLoadMoreOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Load more events or change the search.'**
  String get inlineEventLoadMoreOrSearch;

  /// No description provided for @inlineEventTryAnotherFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another search or filter.'**
  String get inlineEventTryAnotherFilter;

  /// No description provided for @inlineEventLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get inlineEventLoadMore;

  /// No description provided for @inlineEventRetryLoading.
  ///
  /// In en, this message translates to:
  /// **'Retry loading events'**
  String get inlineEventRetryLoading;

  /// No description provided for @inlineEventAllLoadedShown.
  ///
  /// In en, this message translates to:
  /// **'All loaded events shown'**
  String get inlineEventAllLoadedShown;

  /// No description provided for @inlineEventLoadMoreEvents.
  ///
  /// In en, this message translates to:
  /// **'Load more events'**
  String get inlineEventLoadMoreEvents;

  /// No description provided for @inlineEventShownLoaded.
  ///
  /// In en, this message translates to:
  /// **'{shown} shown - {loaded} loaded'**
  String inlineEventShownLoaded(int shown, int loaded);

  /// No description provided for @inlineEventNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get inlineEventNow;

  /// No description provided for @chatDeleteConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get chatDeleteConversationTitle;

  /// No description provided for @chatClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear chat history?'**
  String get chatClearHistoryTitle;

  /// No description provided for @eventCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Event'**
  String get eventCancelTitle;

  /// No description provided for @eventCancelReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get eventCancelReasonOptional;

  /// No description provided for @eventKeepEvent.
  ///
  /// In en, this message translates to:
  /// **'Keep Event'**
  String get eventKeepEvent;

  /// No description provided for @eventDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get eventDeleteTitle;

  /// No description provided for @eventDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{eventTitle}\"?'**
  String eventDeleteConfirm(String eventTitle);

  /// No description provided for @eventAttendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get eventAttendees;

  /// No description provided for @eventAttendeesCount.
  ///
  /// In en, this message translates to:
  /// **'Attendees ({count})'**
  String eventAttendeesCount(int count);

  /// No description provided for @eventNoAttendeesYet.
  ///
  /// In en, this message translates to:
  /// **'No attendees yet'**
  String get eventNoAttendeesYet;

  /// No description provided for @eventAttendeesFailedOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat. Please try again.'**
  String get eventAttendeesFailedOpenChat;

  /// No description provided for @eventAttendeesFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendees'**
  String get eventAttendeesFailedLoad;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @changeSignInAccount.
  ///
  /// In en, this message translates to:
  /// **'Change sign-in account'**
  String get changeSignInAccount;

  /// No description provided for @changeGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Change Google account'**
  String get changeGoogleAccount;

  /// No description provided for @changeAppleAccount.
  ///
  /// In en, this message translates to:
  /// **'Change Apple account'**
  String get changeAppleAccount;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @clearAddress.
  ///
  /// In en, this message translates to:
  /// **'Clear address'**
  String get clearAddress;

  /// No description provided for @clearPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Clear phone number'**
  String get clearPhoneNumber;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get openInMaps;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SportConnect'**
  String get appTitle;

  /// No description provided for @onboardingRunningEvents.
  ///
  /// In en, this message translates to:
  /// **'Running events'**
  String get onboardingRunningEvents;

  /// No description provided for @onboardingDriveEarn.
  ///
  /// In en, this message translates to:
  /// **'Drive & earn'**
  String get onboardingDriveEarn;

  /// No description provided for @onboardingPickupPlanning.
  ///
  /// In en, this message translates to:
  /// **'Pickup planning'**
  String get onboardingPickupPlanning;

  /// No description provided for @onboardingTrustedRides.
  ///
  /// In en, this message translates to:
  /// **'Trusted rides'**
  String get onboardingTrustedRides;

  /// No description provided for @onboardingFindRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a ride to your race'**
  String get onboardingFindRideTitle;

  /// No description provided for @onboardingOfferSeatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer seats and earn'**
  String get onboardingOfferSeatsTitle;

  /// No description provided for @onboardingPlanRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan the route together'**
  String get onboardingPlanRouteTitle;

  /// No description provided for @onboardingConnectGoTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect safely and go'**
  String get onboardingConnectGoTitle;

  /// No description provided for @onboardingFindRideDescription.
  ///
  /// In en, this message translates to:
  /// **'Join runners heading to the same event and arrive without the stress.'**
  String get onboardingFindRideDescription;

  /// No description provided for @onboardingOfferSeatsDescription.
  ///
  /// In en, this message translates to:
  /// **'Driving to a race? Share your empty seats and earn from the trip.'**
  String get onboardingOfferSeatsDescription;

  /// No description provided for @onboardingPlanRouteDescription.
  ///
  /// In en, this message translates to:
  /// **'Set pickup points, confirm timing, and follow a clear route to the event.'**
  String get onboardingPlanRouteDescription;

  /// No description provided for @onboardingConnectGoDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat with verified runners, confirm the ride, and travel with confidence.'**
  String get onboardingConnectGoDescription;

  /// No description provided for @onboardingFindYourRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your\\nRide'**
  String get onboardingFindYourRideTitle;

  /// No description provided for @onboardingMatchWithRunners.
  ///
  /// In en, this message translates to:
  /// **'Match with Runners'**
  String get onboardingMatchWithRunners;

  /// No description provided for @onboardingFindYourRideDescription.
  ///
  /// In en, this message translates to:
  /// **'Instantly match with runners heading the same direction. Share a car, save money, and arrive at the start-line together.'**
  String get onboardingFindYourRideDescription;

  /// No description provided for @onboardingSmartMatching.
  ///
  /// In en, this message translates to:
  /// **'Smart Matching'**
  String get onboardingSmartMatching;

  /// No description provided for @onboardingNearbyRunners.
  ///
  /// In en, this message translates to:
  /// **'Nearby Runners'**
  String get onboardingNearbyRunners;

  /// No description provided for @onboardingPaceFilters.
  ///
  /// In en, this message translates to:
  /// **'Pace Filters'**
  String get onboardingPaceFilters;

  /// No description provided for @onboardingOfferASeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer a\\nSeat'**
  String get onboardingOfferASeatTitle;

  /// No description provided for @onboardingDriveSplitCosts.
  ///
  /// In en, this message translates to:
  /// **'Drive & Split Costs'**
  String get onboardingDriveSplitCosts;

  /// No description provided for @onboardingOfferASeatDescription.
  ///
  /// In en, this message translates to:
  /// **'Got a car? Offer spare seats to fellow runners. Cover fuel costs and build bonds with your local running community.'**
  String get onboardingOfferASeatDescription;

  /// No description provided for @onboardingCostSplitting.
  ///
  /// In en, this message translates to:
  /// **'Cost Splitting'**
  String get onboardingCostSplitting;

  /// No description provided for @onboardingSeatControl.
  ///
  /// In en, this message translates to:
  /// **'Seat Control'**
  String get onboardingSeatControl;

  /// No description provided for @onboardingDriverRating.
  ///
  /// In en, this message translates to:
  /// **'Driver Rating'**
  String get onboardingDriverRating;

  /// No description provided for @onboardingPlanYourRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Your\\nRoute'**
  String get onboardingPlanYourRouteTitle;

  /// No description provided for @onboardingSmartRouteSync.
  ///
  /// In en, this message translates to:
  /// **'Smart Route Sync'**
  String get onboardingSmartRouteSync;

  /// No description provided for @onboardingPlanYourRouteDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your pickup point, race venue, or training ground. SportConnect syncs detours automatically to keep everyone on schedule.'**
  String get onboardingPlanYourRouteDescription;

  /// No description provided for @onboardingLiveRouting.
  ///
  /// In en, this message translates to:
  /// **'Live Routing'**
  String get onboardingLiveRouting;

  /// No description provided for @onboardingDetourSync.
  ///
  /// In en, this message translates to:
  /// **'Detour Sync'**
  String get onboardingDetourSync;

  /// No description provided for @onboardingEventZones.
  ///
  /// In en, this message translates to:
  /// **'Event Zones'**
  String get onboardingEventZones;

  /// No description provided for @onboardingConnectGoModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect\\n& Go'**
  String get onboardingConnectGoModelTitle;

  /// No description provided for @onboardingCommunityYouTrust.
  ///
  /// In en, this message translates to:
  /// **'Community You Trust'**
  String get onboardingCommunityYouTrust;

  /// No description provided for @onboardingConnectGoModelDescription.
  ///
  /// In en, this message translates to:
  /// **'Verified runner profiles, in-app chat, and real-time tracking keep every carpool safe, social, and on time.'**
  String get onboardingConnectGoModelDescription;

  /// No description provided for @onboardingVerifiedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Verified Profiles'**
  String get onboardingVerifiedProfiles;

  /// No description provided for @onboardingInAppChat.
  ///
  /// In en, this message translates to:
  /// **'In-App Chat'**
  String get onboardingInAppChat;

  /// No description provided for @onboardingLiveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get onboardingLiveTracking;

  /// No description provided for @failedToSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Failed to save progress: {error}'**
  String failedToSaveProgress(Object error);

  /// No description provided for @searchRides.
  ///
  /// In en, this message translates to:
  /// **'Search Rides'**
  String get searchRides;

  /// No description provided for @emptyNoRidesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search for a different route'**
  String get emptyNoRidesSubtitle;

  /// No description provided for @emptyNoEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an event to bring your group together'**
  String get emptyNoEventsSubtitle;

  /// No description provided for @emptyNoMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation by booking a ride or joining an event'**
  String get emptyNoMessagesSubtitle;

  /// No description provided for @emptyNoNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see new notifications here'**
  String get emptyNoNotificationsSubtitle;

  /// No description provided for @emptyNoReviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews will appear after completed rides'**
  String get emptyNoReviewsSubtitle;

  /// No description provided for @emptyNoVehiclesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle to start offering rides'**
  String get emptyNoVehiclesSubtitle;

  /// No description provided for @emptyNoBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ride bookings will appear here'**
  String get emptyNoBookingsSubtitle;

  /// No description provided for @emptyNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different search terms or filters'**
  String get emptyNoResultsSubtitle;

  /// No description provided for @reachedYourDestination.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your destination'**
  String get reachedYourDestination;

  /// No description provided for @notificationRideBookingRequestBody.
  ///
  /// In en, this message translates to:
  /// **'{fromUserName} wants to join your ride \"{rideName}\"'**
  String notificationRideBookingRequestBody(
    String fromUserName,
    String rideName,
  );

  /// No description provided for @notificationRideBookingAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} accepted your request for \"{rideName}\"'**
  String notificationRideBookingAcceptedBody(
    String driverName,
    String rideName,
  );

  /// No description provided for @notificationRideBookingDeclinedWithReasonBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} declined your request for \"{rideName}\": {reason}'**
  String notificationRideBookingDeclinedWithReasonBody(
    String driverName,
    String rideName,
    String reason,
  );

  /// No description provided for @notificationRideBookingDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} declined your request for \"{rideName}\"'**
  String notificationRideBookingDeclinedBody(
    String driverName,
    String rideName,
  );

  /// No description provided for @notificationRideCancelledWithReasonBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} cancelled the ride \"{rideName}\": {reason}'**
  String notificationRideCancelledWithReasonBody(
    String driverName,
    String rideName,
    String reason,
  );

  /// No description provided for @notificationRideCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} cancelled the ride \"{rideName}\"'**
  String notificationRideCancelledBody(String driverName, String rideName);

  /// No description provided for @notificationNewMessageBody.
  ///
  /// In en, this message translates to:
  /// **'{fromUserName}: {messagePreview}'**
  String notificationNewMessageBody(String fromUserName, String messagePreview);

  /// No description provided for @notificationAchievementBody.
  ///
  /// In en, this message translates to:
  /// **'You earned \"{achievementName}\" - {achievementDescription}'**
  String notificationAchievementBody(
    String achievementName,
    String achievementDescription,
  );

  /// No description provided for @notificationLevelUpBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You reached Level {newLevel}. Keep riding!'**
  String notificationLevelUpBody(int newLevel);

  /// No description provided for @notificationDriverArrivedBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} has arrived at your pickup for {rideName}. Head out now!'**
  String notificationDriverArrivedBody(String driverName, String rideName);

  /// No description provided for @notificationDriverArrivingDestinationBody.
  ///
  /// In en, this message translates to:
  /// **'{driverName} is arriving at the destination for {rideName}.'**
  String notificationDriverArrivingDestinationBody(
    String driverName,
    String rideName,
  );

  /// No description provided for @notificationEventCancelledWithReasonBody.
  ///
  /// In en, this message translates to:
  /// **'{organizerName} cancelled \"{eventTitle}\": {reason}'**
  String notificationEventCancelledWithReasonBody(
    String organizerName,
    String eventTitle,
    String reason,
  );

  /// No description provided for @notificationEventCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'{organizerName} cancelled \"{eventTitle}\"'**
  String notificationEventCancelledBody(
    String organizerName,
    String eventTitle,
  );

  /// No description provided for @notificationRideReferenceType.
  ///
  /// In en, this message translates to:
  /// **'ride'**
  String get notificationRideReferenceType;

  /// No description provided for @notificationChatReferenceType.
  ///
  /// In en, this message translates to:
  /// **'chat'**
  String get notificationChatReferenceType;

  /// No description provided for @notificationEventReferenceType.
  ///
  /// In en, this message translates to:
  /// **'event'**
  String get notificationEventReferenceType;

  /// No description provided for @sharedLocation.
  ///
  /// In en, this message translates to:
  /// **'Shared location'**
  String get sharedLocation;

  /// No description provided for @rideAttachment.
  ///
  /// In en, this message translates to:
  /// **'Ride attachment'**
  String get rideAttachment;

  /// No description provided for @systemMessage.
  ///
  /// In en, this message translates to:
  /// **'System message'**
  String get systemMessage;

  /// No description provided for @imageMessage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageMessage;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @waze.
  ///
  /// In en, this message translates to:
  /// **'Waze'**
  String get waze;

  /// No description provided for @appleMaps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get appleMaps;

  /// No description provided for @locationData.
  ///
  /// In en, this message translates to:
  /// **'Location Data'**
  String get locationData;

  /// No description provided for @paymentData.
  ///
  /// In en, this message translates to:
  /// **'Payment Data'**
  String get paymentData;

  /// No description provided for @usageData.
  ///
  /// In en, this message translates to:
  /// **'Usage Data'**
  String get usageData;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @sportconnectDescription.
  ///
  /// In en, this message translates to:
  /// **'SportConnect is a carpooling and rideshare platform designed for sports enthusiasts. Share rides to games, tournaments, and training sessions while saving money, reducing emissions, and connecting with fellow athletes.'**
  String get sportconnectDescription;

  /// No description provided for @nearMe.
  ///
  /// In en, this message translates to:
  /// **'Near me'**
  String get nearMe;

  /// No description provided for @withinValueKm.
  ///
  /// In en, this message translates to:
  /// **'Within {value} km'**
  String withinValueKm(Object value);

  /// No description provided for @purchasesRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully.'**
  String get purchasesRestoredSuccessfully;

  /// No description provided for @couldNotRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases.'**
  String get couldNotRestorePurchases;

  /// No description provided for @personalInformationDescription.
  ///
  /// In en, this message translates to:
  /// **'We collect your name, email, phone number, and profile photo to create and manage your account.'**
  String get personalInformationDescription;

  /// No description provided for @locationDataDescription.
  ///
  /// In en, this message translates to:
  /// **'We process your location to match rides, calculate routes, and show nearby destinations.'**
  String get locationDataDescription;

  /// No description provided for @paymentDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Payment information is processed securely by Stripe. We do not store your full card details.'**
  String get paymentDataDescription;

  /// No description provided for @usageDataDescription.
  ///
  /// In en, this message translates to:
  /// **'We collect crash reports and usage analytics. This data is anonymized.'**
  String get usageDataDescription;

  /// No description provided for @yourRightsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can access, export, correct, or delete your data at any time.'**
  String get yourRightsDescription;

  /// No description provided for @business_days_1_to_2.
  ///
  /// In en, this message translates to:
  /// **'Business Days 1 To 2'**
  String get business_days_1_to_2;

  /// No description provided for @two_days_left.
  ///
  /// In en, this message translates to:
  /// **'Two Days Left'**
  String get two_days_left;

  /// No description provided for @helpCenterGettingStartedCreateAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Getting Started Create Account Question'**
  String get helpCenterGettingStartedCreateAccountQuestion;

  /// No description provided for @helpCenterGettingStartedCreateAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Getting Started Create Account Answer'**
  String get helpCenterGettingStartedCreateAccountAnswer;

  /// No description provided for @helpCenterGettingStartedSwitchRoleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Getting Started Switch Role Question'**
  String get helpCenterGettingStartedSwitchRoleQuestion;

  /// No description provided for @helpCenterGettingStartedSwitchRoleAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Getting Started Switch Role Answer'**
  String get helpCenterGettingStartedSwitchRoleAnswer;

  /// No description provided for @helpCenterGettingStartedFreeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Getting Started Free Question'**
  String get helpCenterGettingStartedFreeQuestion;

  /// No description provided for @helpCenterGettingStartedFreeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Getting Started Free Answer'**
  String get helpCenterGettingStartedFreeAnswer;

  /// No description provided for @helpCenterRidesBookingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Booking Question'**
  String get helpCenterRidesBookingQuestion;

  /// No description provided for @helpCenterRidesBookingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Booking Answer'**
  String get helpCenterRidesBookingAnswer;

  /// No description provided for @helpCenterRidesCancelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Cancel Answer'**
  String get helpCenterRidesCancelAnswer;

  /// No description provided for @helpCenterRidesMatchingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Matching Question'**
  String get helpCenterRidesMatchingQuestion;

  /// No description provided for @helpCenterRidesMatchingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Matching Answer'**
  String get helpCenterRidesMatchingAnswer;

  /// No description provided for @helpCenterRidesLateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Late Question'**
  String get helpCenterRidesLateQuestion;

  /// No description provided for @helpCenterRidesLateAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Late Answer'**
  String get helpCenterRidesLateAnswer;

  /// No description provided for @helpCenterPaymentsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Payments Question'**
  String get helpCenterPaymentsQuestion;

  /// No description provided for @helpCenterPaymentsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Payments Answer'**
  String get helpCenterPaymentsAnswer;

  /// No description provided for @helpCenterPayoutsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Payouts Question'**
  String get helpCenterPayoutsQuestion;

  /// No description provided for @helpCenterPayoutsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Payouts Answer'**
  String get helpCenterPayoutsAnswer;

  /// No description provided for @helpCenterFeesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Fees Question'**
  String get helpCenterFeesQuestion;

  /// No description provided for @helpCenterFeesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Fees Answer'**
  String get helpCenterFeesAnswer;

  /// No description provided for @helpCenterSafetyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Safety Question'**
  String get helpCenterSafetyQuestion;

  /// No description provided for @helpCenterSafetyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Safety Answer'**
  String get helpCenterSafetyAnswer;

  /// No description provided for @helpCenterSafetyReportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Safety Report Question'**
  String get helpCenterSafetyReportQuestion;

  /// No description provided for @helpCenterSafetyReportAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Safety Report Answer'**
  String get helpCenterSafetyReportAnswer;

  /// No description provided for @helpCenterSafetyShareQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Safety Share Question'**
  String get helpCenterSafetyShareQuestion;

  /// No description provided for @helpCenterSafetyShareAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Safety Share Answer'**
  String get helpCenterSafetyShareAnswer;

  /// No description provided for @helpCenterAccountVerifyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Account Verify Question'**
  String get helpCenterAccountVerifyQuestion;

  /// No description provided for @helpCenterAccountVerifyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Account Verify Answer'**
  String get helpCenterAccountVerifyAnswer;

  /// No description provided for @helpCenterAccountDeleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Account Delete Question'**
  String get helpCenterAccountDeleteQuestion;

  /// No description provided for @helpCenterAccountDeleteAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Account Delete Answer'**
  String get helpCenterAccountDeleteAnswer;

  /// No description provided for @helpCenterAccountEmailQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Account Email Question'**
  String get helpCenterAccountEmailQuestion;

  /// No description provided for @helpCenterAccountEmailAnswer.
  ///
  /// In en, this message translates to:
  /// **'Help Center Account Email Answer'**
  String get helpCenterAccountEmailAnswer;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @tryDifferentKeywordsOrContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Try Different Keywords Or Contact Support'**
  String get tryDifferentKeywordsOrContactSupport;

  /// No description provided for @helpCenterRidesCancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Help Center Rides Cancel Question'**
  String get helpCenterRidesCancelQuestion;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin access required'**
  String get adminAccessRequired;

  /// No description provided for @adminAccessCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Access check failed: {error}'**
  String adminAccessCheckFailed(String error);

  /// No description provided for @noRefundRequests.
  ///
  /// In en, this message translates to:
  /// **'No refund requests'**
  String get noRefundRequests;

  /// No description provided for @noDisputes.
  ///
  /// In en, this message translates to:
  /// **'No disputes'**
  String get noDisputes;

  /// No description provided for @noSupportTickets.
  ///
  /// In en, this message translates to:
  /// **'No support tickets'**
  String get noSupportTickets;

  /// No description provided for @refundsTab.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refundsTab;

  /// No description provided for @disputesTab.
  ///
  /// In en, this message translates to:
  /// **'Disputes'**
  String get disputesTab;

  /// No description provided for @supportTab.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTab;

  /// Label for Stripe EUR balance display
  ///
  /// In en, this message translates to:
  /// **'EUR balance'**
  String get stripeEurBalance;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'First Ride'**
  String get badgeFirstRide;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete your first ride'**
  String get badgeFirstRideDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Road Warrior'**
  String get badgeRoadWarrior;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete 10 rides'**
  String get badgeRoadWarriorDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Eco Hero'**
  String get badgeEcoHero;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Save 50 kg of CO₂'**
  String get badgeEcoHeroDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Social Butterfly'**
  String get badgeSocialButterfly;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect with 10 riders'**
  String get badgeSocialButterflyDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Road Tripper'**
  String get badgeRoadTripper;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Travel 50 km total'**
  String get badgeRoadTripperDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get badgeSpeedDemon;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day streak'**
  String get badgeSpeedDemonDesc;

  /// Error message in admin_dashboard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not load issues: {error}'**
  String adminCouldNotLoadIssues(String error);

  /// No description provided for @adminDashboardSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review refunds, disputes, and support tickets'**
  String get adminDashboardSettingsSubtitle;

  /// No description provided for @adminApproveRefund.
  ///
  /// In en, this message translates to:
  /// **'Approve refund'**
  String get adminApproveRefund;

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get adminRefund;

  /// No description provided for @adminResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get adminResolve;

  /// No description provided for @actionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get actionUpdated;

  /// No description provided for @yearlyMonthlyEstimate.
  ///
  /// In en, this message translates to:
  /// **'≈ €4.17/mo'**
  String get yearlyMonthlyEstimate;

  /// No description provided for @premiumSubscribeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to ride smarter, together.'**
  String get premiumSubscribeHeroSubtitle;

  /// No description provided for @alreadyPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re already a member'**
  String get alreadyPremiumTitle;

  /// No description provided for @alreadyPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your SportConnect Premium subscription is active. Enjoy all premium features.'**
  String get alreadyPremiumSubtitle;

  /// No description provided for @backToApp.
  ///
  /// In en, this message translates to:
  /// **'Back to App'**
  String get backToApp;

  /// Quick message chip in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I\'m at pickup'**
  String get chatChipImAtPickup;

  /// Quick message chip in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Running late'**
  String get chatChipRunningLate;

  /// Generic retry message in error_boundary.dart
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get pleaseTryAgainLater;

  /// Fallback label for route distance in ride_booking_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Route distance'**
  String get routeDistanceFallback;

  /// No description provided for @estimatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min estimated'**
  String estimatedMinutes(int minutes);

  /// No description provided for @seatsLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seatsLeftCount(int count);

  /// No description provided for @bookingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Booking...'**
  String get bookingInProgress;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @rideSharedDistanceSummary.
  ///
  /// In en, this message translates to:
  /// **'{distance} km shared together'**
  String rideSharedDistanceSummary(String distance);

  /// No description provided for @rideCarpooledWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Carpooled with 1 person} other{Carpooled with {count} people}}'**
  String rideCarpooledWithCount(int count);

  /// No description provided for @avgSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg Speed'**
  String get avgSpeedLabel;

  /// No description provided for @avgSpeedKmhValue.
  ///
  /// In en, this message translates to:
  /// **'{value} km/h'**
  String avgSpeedKmhValue(String value);

  /// No description provided for @baseFareSeatCount.
  ///
  /// In en, this message translates to:
  /// **'Base Fare ({count} seats)'**
  String baseFareSeatCount(int count);

  /// No description provided for @baseFareSeatsByPrice.
  ///
  /// In en, this message translates to:
  /// **'Base Fare ({count} seats × {price})'**
  String baseFareSeatsByPrice(int count, String price);

  /// No description provided for @serviceFeeWithRate.
  ///
  /// In en, this message translates to:
  /// **'Service Fee ({rate})'**
  String serviceFeeWithRate(String rate);

  /// No description provided for @rideCompletionDriverRating.
  ///
  /// In en, this message translates to:
  /// **'{value} rating'**
  String rideCompletionDriverRating(String value);

  /// No description provided for @billingPeriodMonthShort.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get billingPeriodMonthShort;

  /// No description provided for @billingPeriodYearShort.
  ///
  /// In en, this message translates to:
  /// **'/yr'**
  String get billingPeriodYearShort;

  /// No description provided for @fallbackMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€4.99'**
  String get fallbackMonthlyPrice;

  /// No description provided for @fallbackYearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€49.99'**
  String get fallbackYearlyPrice;

  /// No description provided for @yearlyMonthlyAtPrice.
  ///
  /// In en, this message translates to:
  /// **'≈ {price}/mo'**
  String yearlyMonthlyAtPrice(String price);

  /// No description provided for @premiumRenewsUntilCancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription renews automatically until cancelled. Cancel anytime in App Store Settings.'**
  String get premiumRenewsUntilCancelled;

  /// No description provided for @premiumRenewsEachPeriodAtPrice.
  ///
  /// In en, this message translates to:
  /// **'Automatically renews each {period} at {price} until cancelled. Cancel anytime in App Store Settings.'**
  String premiumRenewsEachPeriodAtPrice(String period, String price);

  /// No description provided for @cancellationReasonBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Please let us know why you\'re cancelling so we can improve our service.'**
  String get cancellationReasonBannerMessage;

  /// No description provided for @cancelReasonChangeOfPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Change of plans'**
  String get cancelReasonChangeOfPlansTitle;

  /// No description provided for @cancelReasonChangeOfPlansDescription.
  ///
  /// In en, this message translates to:
  /// **'My schedule changed and I can no longer make this ride.'**
  String get cancelReasonChangeOfPlansDescription;

  /// No description provided for @cancelReasonFoundAnotherRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Found another ride'**
  String get cancelReasonFoundAnotherRideTitle;

  /// No description provided for @cancelReasonFoundAnotherRideDescription.
  ///
  /// In en, this message translates to:
  /// **'I found a more convenient ride option.'**
  String get cancelReasonFoundAnotherRideDescription;

  /// No description provided for @cancelReasonPriceTooHighTitle.
  ///
  /// In en, this message translates to:
  /// **'Price too high'**
  String get cancelReasonPriceTooHighTitle;

  /// No description provided for @cancelReasonPriceTooHighDescription.
  ///
  /// In en, this message translates to:
  /// **'The ride cost is more than I expected.'**
  String get cancelReasonPriceTooHighDescription;

  /// No description provided for @cancelReasonSafetyConcernTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety concern'**
  String get cancelReasonSafetyConcernTitle;

  /// No description provided for @cancelReasonSafetyConcernDescription.
  ///
  /// In en, this message translates to:
  /// **'I have concerns about the safety of this ride.'**
  String get cancelReasonSafetyConcernDescription;

  /// No description provided for @cancelReasonDriverNotRespondingTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver not responding'**
  String get cancelReasonDriverNotRespondingTitle;

  /// No description provided for @cancelReasonDriverNotRespondingDescription.
  ///
  /// In en, this message translates to:
  /// **'The driver is not responding to messages.'**
  String get cancelReasonDriverNotRespondingDescription;

  /// No description provided for @cancelReasonIncorrectDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incorrect details'**
  String get cancelReasonIncorrectDetailsTitle;

  /// No description provided for @cancelReasonIncorrectDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'The ride details are incorrect or have changed.'**
  String get cancelReasonIncorrectDetailsDescription;

  /// No description provided for @cancelReasonEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get cancelReasonEmergencyTitle;

  /// No description provided for @cancelReasonEmergencyDescription.
  ///
  /// In en, this message translates to:
  /// **'I have an unexpected emergency.'**
  String get cancelReasonEmergencyDescription;

  /// No description provided for @cancelReasonOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelReasonOtherTitle;

  /// No description provided for @cancelReasonOtherDescription.
  ///
  /// In en, this message translates to:
  /// **'Another reason not listed above.'**
  String get cancelReasonOtherDescription;

  /// No description provided for @cancelReasonVehicleIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle issue'**
  String get cancelReasonVehicleIssueTitle;

  /// No description provided for @cancelReasonVehicleIssueDescription.
  ///
  /// In en, this message translates to:
  /// **'My vehicle has a mechanical problem or is unavailable.'**
  String get cancelReasonVehicleIssueDescription;

  /// No description provided for @cancelReasonPassengerNotAtPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Passenger not at pickup'**
  String get cancelReasonPassengerNotAtPickupTitle;

  /// No description provided for @cancelReasonPassengerNotAtPickupDescription.
  ///
  /// In en, this message translates to:
  /// **'The passenger was not at the agreed pickup location.'**
  String get cancelReasonPassengerNotAtPickupDescription;

  /// No description provided for @cancelReasonPassengerNotRespondingTitle.
  ///
  /// In en, this message translates to:
  /// **'Passenger not responding'**
  String get cancelReasonPassengerNotRespondingTitle;

  /// No description provided for @cancelReasonPassengerNotRespondingDescription.
  ///
  /// In en, this message translates to:
  /// **'The passenger is not responding to messages.'**
  String get cancelReasonPassengerNotRespondingDescription;

  /// No description provided for @cancelReasonRouteIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Route issue'**
  String get cancelReasonRouteIssueTitle;

  /// No description provided for @cancelReasonRouteIssueDescription.
  ///
  /// In en, this message translates to:
  /// **'There is a road closure or route problem.'**
  String get cancelReasonRouteIssueDescription;

  /// No description provided for @pleaseFixFields.
  ///
  /// In en, this message translates to:
  /// **'Please fix: {fields}'**
  String pleaseFixFields(String fields);

  /// No description provided for @nameTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get nameTooLongError;

  /// No description provided for @ridingDetails.
  ///
  /// In en, this message translates to:
  /// **'Riding Details'**
  String get ridingDetails;

  /// No description provided for @riderOnboardingFormLabel.
  ///
  /// In en, this message translates to:
  /// **'Rider onboarding form'**
  String get riderOnboardingFormLabel;

  /// No description provided for @payoutStepInitiated.
  ///
  /// In en, this message translates to:
  /// **'Initiated'**
  String get payoutStepInitiated;

  /// No description provided for @payoutStepCouldNotComplete.
  ///
  /// In en, this message translates to:
  /// **'Could not complete'**
  String get payoutStepCouldNotComplete;

  /// No description provided for @payoutStepPreparingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Stripe is preparing your transfer'**
  String get payoutStepPreparingTransfer;

  /// No description provided for @payoutStepExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected {date}'**
  String payoutStepExpected(String date);

  /// No description provided for @payoutStepOnItsWayToYourBank.
  ///
  /// In en, this message translates to:
  /// **'On its way to your bank'**
  String get payoutStepOnItsWayToYourBank;

  /// No description provided for @payoutStepWaitingForProcessing.
  ///
  /// In en, this message translates to:
  /// **'Waiting for processing to complete'**
  String get payoutStepWaitingForProcessing;

  /// No description provided for @payoutStepDepositedToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Deposited to your account'**
  String get payoutStepDepositedToYourAccount;

  /// No description provided for @payoutMethodInstantDescription.
  ///
  /// In en, this message translates to:
  /// **'Instant (usually minutes)'**
  String get payoutMethodInstantDescription;

  /// No description provided for @payoutMethodStandardDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard (1–3 business days)'**
  String get payoutMethodStandardDescription;

  /// No description provided for @payoutDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get payoutDestinationLabel;

  /// No description provided for @onboardingStepCount.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepCount(int current, int total);

  /// No description provided for @onboardingCreateAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create your free account to find rides to your next sporting event.'**
  String get onboardingCreateAccountPrompt;

  /// No description provided for @onboardingRunningEventLabel.
  ///
  /// In en, this message translates to:
  /// **'RUNNING EVENT'**
  String get onboardingRunningEventLabel;

  /// No description provided for @onboardingRideBadgeOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get onboardingRideBadgeOpen;

  /// No description provided for @onboardingRideBadgeSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get onboardingRideBadgeSet;

  /// No description provided for @onboardingSharedLabel.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get onboardingSharedLabel;

  /// No description provided for @onboardingDriverRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver route'**
  String get onboardingDriverRouteLabel;

  /// No description provided for @onboardingSharedArrivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Shared arrival'**
  String get onboardingSharedArrivalLabel;

  /// No description provided for @onboardingEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get onboardingEventLabel;

  /// Signup wizard tablet/step label for identity and role step
  ///
  /// In en, this message translates to:
  /// **'Identity & Role'**
  String get identityAndRoleStep;

  /// Short label for day column in signup date picker
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// Short label for month column in signup date picker
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// Validation message for minimum password length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLengthError;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// Generic validation fallback message
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalidValue;

  /// Validation message when support subject is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get supportSubjectRequired;

  /// Validation message when support subject is too short
  ///
  /// In en, this message translates to:
  /// **'Subject must be at least 3 characters'**
  String get supportSubjectMinLength;

  /// Validation message when support message is empty
  ///
  /// In en, this message translates to:
  /// **'Please describe your issue'**
  String get supportMessageRequired;

  /// Validation message when support message is too short
  ///
  /// In en, this message translates to:
  /// **'Please provide at least 10 characters'**
  String get supportMessageMinLength;

  /// Quick date filter for the coming weekend
  ///
  /// In en, this message translates to:
  /// **'This Weekend'**
  String get thisWeekend;

  /// Sort label for highest price
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get highestPrice;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Perfect Score'**
  String get badgePerfectScore;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Maintain a 5-star rating'**
  String get badgePerfectScoreDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Road Master'**
  String get badgeRoadMaster;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete 100 rides'**
  String get badgeRoadMasterDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get badgeNightOwl;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete 20 night rides'**
  String get badgeNightOwlDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get badgeEarlyBird;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete 20 morning rides'**
  String get badgeEarlyBirdDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Marathon Driver'**
  String get badgeMarathonDriver;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Travel 1000 km total'**
  String get badgeMarathonDriverDesc;

  /// Achievement badge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified Pro'**
  String get badgeVerifiedPro;

  /// Achievement badge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get identity verified'**
  String get badgeVerifiedProDesc;

  /// Challenge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Daily Commuter'**
  String get challengeDailyCommuter;

  /// Challenge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete 1 ride today'**
  String get challengeDailyCommuterDesc;

  /// Challenge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get challengeWeekWarrior;

  /// Challenge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete 5 rides this week'**
  String get challengeWeekWarriorDesc;

  /// Challenge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Streak Keeper'**
  String get challengeStreakKeeper;

  /// Challenge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Maintain a 3-day streak'**
  String get challengeStreakKeeperDesc;

  /// Challenge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get challengeExplorer;

  /// Challenge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try 3 new routes this month'**
  String get challengeExplorerDesc;

  /// Challenge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Social Rider'**
  String get challengeSocialRider;

  /// Challenge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rate 5 drivers this week'**
  String get challengeSocialRiderDesc;

  /// Challenge name in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Eco Warrior'**
  String get challengeEcoWarrior;

  /// Challenge description in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share 3 rides today'**
  String get challengeEcoWarriorDesc;

  /// Challenge timer label in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Resets in {value}h'**
  String challengeResetsInHours(String value);

  /// Challenge timer label in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Resets in {value}d'**
  String challengeResetsInDays(String value);

  /// Challenge encouragement label in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get challengeKeepGoing;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneNumberHint;

  /// No description provided for @phoneNumberSupportNoLeadingZero.
  ///
  /// In en, this message translates to:
  /// **'After +33, enter the number without the leading 0.'**
  String get phoneNumberSupportNoLeadingZero;

  /// No description provided for @phoneNumberDigitsCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} digits after +33'**
  String phoneNumberDigitsCount(int current, int total);

  /// No description provided for @phoneNumberSupportPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Used only for ride coordination and safety.'**
  String get phoneNumberSupportPrivacy;

  /// No description provided for @profilePhotoCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to take a new profile photo.'**
  String get profilePhotoCameraPermission;

  /// No description provided for @profilePhotoLibraryPermission.
  ///
  /// In en, this message translates to:
  /// **'Access to your photo library is needed to update your profile picture.'**
  String get profilePhotoLibraryPermission;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @addressSelected.
  ///
  /// In en, this message translates to:
  /// **'Address selected'**
  String get addressSelected;

  /// No description provided for @noPointSelected.
  ///
  /// In en, this message translates to:
  /// **'No point selected'**
  String get noPointSelected;

  /// No description provided for @tapMapToChoosePoint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to choose a point'**
  String get tapMapToChoosePoint;

  /// No description provided for @locationPreviewReady.
  ///
  /// In en, this message translates to:
  /// **'Location preview is ready below'**
  String get locationPreviewReady;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment Breakdown'**
  String get paymentBreakdown;

  /// No description provided for @baseFare.
  ///
  /// In en, this message translates to:
  /// **'Base Fare'**
  String get baseFare;

  /// No description provided for @processingFee.
  ///
  /// In en, this message translates to:
  /// **'Processing Fee'**
  String get processingFee;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @refundReason.
  ///
  /// In en, this message translates to:
  /// **'Refund Reason'**
  String get refundReason;

  /// No description provided for @distanceKmValue.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKmValue(String value);

  /// No description provided for @withdrawableBalanceInfo.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable Now is the part of your Stripe instant-available balance backed by completed rides.\n\nPaid rides that are not completed yet stay blocked for withdrawal.\n\nProcessing is money that has reached Stripe but is not yet eligible for instant withdrawal.'**
  String get withdrawableBalanceInfo;

  /// No description provided for @withdrawableNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable now'**
  String get withdrawableNowLabel;

  /// No description provided for @completedRideEarningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed ride earnings'**
  String get completedRideEarningsLabel;

  /// No description provided for @payoutsAlreadyRequestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Payouts already requested'**
  String get payoutsAlreadyRequestedLabel;

  /// No description provided for @paidRidesAwaitingCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid rides awaiting completion'**
  String get paidRidesAwaitingCompletionLabel;

  /// No description provided for @stripeInstantAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Stripe instant available'**
  String get stripeInstantAvailableLabel;

  /// No description provided for @stripeBalanceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Stripe balance total'**
  String get stripeBalanceTotalLabel;

  /// No description provided for @tripEarningsRecordedLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip earnings recorded'**
  String get tripEarningsRecordedLabel;

  /// No description provided for @withdrawableNowFootnote.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable Now only includes completed rides. Paid rides still in progress unlock after the driver completes the ride.'**
  String get withdrawableNowFootnote;

  /// No description provided for @rideCompletionPendingAmount.
  ///
  /// In en, this message translates to:
  /// **' €{amount} is waiting for ride completion.'**
  String rideCompletionPendingAmount(String amount);

  /// No description provided for @processingBalancePendingAmount.
  ///
  /// In en, this message translates to:
  /// **' €{amount} is still processing.'**
  String processingBalancePendingAmount(String amount);

  /// No description provided for @noCompletedRideBalanceAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No completed ride balance available yet.'**
  String get noCompletedRideBalanceAvailableYet;

  /// No description provided for @receiptNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt #'**
  String get receiptNumberLabel;

  /// No description provided for @routeDeviationDetected.
  ///
  /// In en, this message translates to:
  /// **'Route Deviation Detected'**
  String get routeDeviationDetected;

  /// No description provided for @driverOffRouteEta.
  ///
  /// In en, this message translates to:
  /// **'Driver is {distance} off route — new ETA ~{minutes} min'**
  String driverOffRouteEta(Object distance, int minutes);

  /// No description provided for @driverOffPlannedRoute.
  ///
  /// In en, this message translates to:
  /// **'Driver is {distance} off the planned route'**
  String driverOffPlannedRoute(Object distance);

  /// No description provided for @relativeMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one {{minutes} min} other {{minutes} min}}'**
  String relativeMinutesShort(int minutes);

  /// No description provided for @relativeHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, one {{hours}h} other {{hours}h}}'**
  String relativeHoursShort(int hours);

  /// No description provided for @relativeDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one {{days}d} other {{days}d}}'**
  String relativeDaysShort(int days);

  /// No description provided for @refundReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Refund review'**
  String get refundReviewLabel;

  /// No description provided for @refundIfEligibleLineOne.
  ///
  /// In en, this message translates to:
  /// **'If'**
  String get refundIfEligibleLineOne;

  /// No description provided for @refundIfEligibleLineTwo.
  ///
  /// In en, this message translates to:
  /// **'eligible'**
  String get refundIfEligibleLineTwo;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @setEndDate.
  ///
  /// In en, this message translates to:
  /// **'Set end date'**
  String get setEndDate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
