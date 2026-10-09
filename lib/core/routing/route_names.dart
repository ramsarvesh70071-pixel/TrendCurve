/// Type-safe route paths for GoRouter.
class AppRouteNames {
  AppRouteNames._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';

  // Shell Tabs
  static const String dashboard = '/dashboard';
  static const String pdfAnalyzer = '/pdf-analyzer';
  static const String trends = '/trends';
  static const String analytics = '/analytics';
  static const String activity = '/activity';
  static const String profile = '/profile';

  // Trends & Data
  static const String createTrend = '/create-trend';
  static const String editTrend = '/edit-trend/:id';
  static const String trendDetails = '/trend-details/:id';
  static const String addDataPoint = '/add-data-point/:id';
  static const String allDataPoints = '/all-data-points/:id';
  static const String compareTrends = '/compare-trends';

  // Global & Features
  static const String notifications = '/notifications';
  static const String search = '/search';

  // Settings
  static const String settings = '/settings';
  static const String appearance = '/appearance';
  static const String accountSettings = '/account-settings';
  static const String security = '/security';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String helpSupport = '/help-support';
}
