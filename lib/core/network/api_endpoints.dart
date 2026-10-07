/// Centralized API endpoint routes for future Node.js/Express + MongoDB backend integration.
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL can be configured via environment or settings
  static const String baseUrl = 'https://api.trendcurve.app/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // Trends endpoints
  static const String trends = '/trends';
  static String trendById(String id) => '/trends/$id';
  static String trendDataPoints(String trendId) => '/trends/$trendId/data-points';
  static String trendDataPointById(String trendId, String pointId) =>
      '/trends/$trendId/data-points/$pointId';

  // Analytics
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsCompare = '/analytics/compare';

  // Activity & Notifications
  static const String activities = '/activities';
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // User Profile
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
}
