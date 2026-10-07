/// Global constants for Trend Curve.
class AppConstants {
  AppConstants._();

  static const String appName = 'Trend Curve';
  static const String appTagline = 'Track. Analyze. Grow.';
  static const String appVersion = '1.0.0';

  // Local storage keys
  static const String keyOnboardingComplete = 'tc_onboarding_completed';
  static const String keyAuthToken = 'tc_auth_token';
  static const String keyUserData = 'tc_user_data';
  static const String keyThemeMode = 'tc_theme_mode'; // 'light', 'dark', 'system'
  static const String keyTrends = 'tc_trends_data';
  static const String keyActivities = 'tc_activities_data';
  static const String keyNotifications = 'tc_notifications_data';
  static const String keyDefaultTimeRange = 'tc_default_time_range';
  static const String keyDefaultCurrency = 'tc_default_currency';
  static const String keyNotificationsEnabled = 'tc_notifications_enabled';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Time Filter Options
  static const List<String> timeFilterOptions = ['7D', '30D', '3M', '6M', '1Y', 'All'];

  // Categories
  static const List<String> categories = [
    'Business',
    'Finance',
    'Health',
    'Productivity',
    'Social',
    'Education',
    'Technology',
    'Custom',
  ];

  // Frequency
  static const List<String> frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
    'Custom',
  ];

  // Supported Currencies / Units
  static const List<String> commonUnits = [
    '₹', '\$', '€', '£', '¥', '%', 'kg', 'lbs', 'hrs', 'users', 'visits', 'pts', 'count'
  ];
}
