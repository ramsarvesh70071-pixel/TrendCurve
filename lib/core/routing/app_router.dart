import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/analytics/compare_trends_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/global_search_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/settings/about_screen.dart';
import '../../features/settings/appearance_screen.dart';
import '../../features/settings/help_support_screen.dart';
import '../../features/settings/privacy_policy_screen.dart';
import '../../features/settings/security_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/terms_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/trends/add_data_point_dialog.dart';
import '../../features/trends/all_data_points_screen.dart';
import '../../features/trends/create_trend_screen.dart';
import '../../features/trends/edit_trend_screen.dart';
import '../../features/trends/trend_details_screen.dart';
import '../../features/trends/trends_screen.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/responsive_scaffold.dart';
import '../providers/app_providers.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(localStorageServiceProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouteNames.splash,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page Not Found: ${state.uri}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppButton(
                text: storage.hasAuthTokenSync() ? 'Go to Dashboard' : 'Go to Login',
                onPressed: () => context.go(storage.hasAuthTokenSync() ? '/dashboard' : '/login'),
              ),
            ],
          ),
        ),
      ),
    ),
    redirect: (context, state) {
      final path = state.uri.path;
      final isOnboarded = storage.isOnboardingComplete();
      final hasToken = storage.hasAuthTokenSync();

      // 1. Splash is always allowed
      if (path == AppRouteNames.splash) return null;

      // 2. If onboarding is not completed yet:
      if (!isOnboarded) {
        return path == AppRouteNames.onboarding ? null : AppRouteNames.onboarding;
      }

      // 3. If onboarding is already completed and user tries to access onboarding again:
      if (path == AppRouteNames.onboarding) {
        return hasToken ? AppRouteNames.dashboard : AppRouteNames.login;
      }

      // 4. Auth routes: login, register, forgotPassword, otpVerification, resetPassword
      final isAuthRoute = path == AppRouteNames.login ||
          path == AppRouteNames.register ||
          path == AppRouteNames.forgotPassword ||
          path == AppRouteNames.otpVerification ||
          path == AppRouteNames.resetPassword;

      // If already logged in, redirect away from auth routes to dashboard
      if (hasToken && isAuthRoute) {
        return AppRouteNames.dashboard;
      }

      // If NOT logged in and trying to access protected routes, redirect to login
      if (!hasToken && !isAuthRoute) {
        return AppRouteNames.login;
      }

      // Otherwise allow current route
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRouteNames.otpVerification,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRouteNames.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            email: extra['email'] as String? ?? '',
            otp: extra['otp'] as String? ?? '',
          );
        },
      ),

      // App Shell with Stateful Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Trends
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trends,
                builder: (context, state) => const TrendsScreen(),
              ),
            ],
          ),

          // Branch 2: Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.analytics,
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),

          // Branch 3: Activity
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.activity,
                builder: (context, state) => const ActivityScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Global Features & Actions
      GoRoute(
        path: AppRouteNames.createTrend,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateTrendScreen(),
      ),
      GoRoute(
        path: AppRouteNames.editTrend,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EditTrendScreen(trendId: id);
        },
      ),
      GoRoute(
        path: AppRouteNames.trendDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TrendDetailsScreen(trendId: id);
        },
      ),
      GoRoute(
        path: AppRouteNames.allDataPoints,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AllDataPointsScreen(trendId: id);
        },
      ),
      GoRoute(
        path: AppRouteNames.addDataPoint,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DialogPage(
            builder: (_) => AddDataPointDialog(trendId: id),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.compareTrends,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CompareTrendsScreen(),
      ),
      GoRoute(
        path: AppRouteNames.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: AppRouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Settings sub-routes
      GoRoute(
        path: AppRouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRouteNames.appearance,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: AppRouteNames.accountSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRouteNames.security,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: AppRouteNames.about,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRouteNames.privacyPolicy,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRouteNames.terms,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRouteNames.helpSupport,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpSupportScreen(),
      ),
    ],
  );
});

class DialogPage<T> extends Page<T> {
  final WidgetBuilder builder;

  const DialogPage({required this.builder});

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
    );
  }
}
