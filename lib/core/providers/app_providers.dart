import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/filter_criteria.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/sort_option.dart';
import '../../data/models/trend_data_point_model.dart';
import '../../data/models/trend_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/trend_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/trend_service.dart';
import '../../data/services/user_service.dart';

// --- Storage Provider ---
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be initialized');
});

// --- Services & Repositories ---
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalAuthService(storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthRepository(service);
});

final trendServiceProvider = Provider<TrendService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalTrendService(storage: storage);
});

final trendRepositoryProvider = Provider<TrendRepository>((ref) {
  final service = ref.watch(trendServiceProvider);
  return TrendRepository(service);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return LocalAnalyticsService();
});

final userServiceProvider = Provider<UserService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalUserService(storage: storage);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalNotificationService(storage: storage);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationRepository(service);
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ActivityRepository(storage);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsRepository(storage);
});

// --- Theme Mode State ---
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final settings = ref.watch(settingsRepositoryProvider);
    final mode = settings.getThemeMode();
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    await ref.read(settingsRepositoryProvider).setThemeMode(str);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// --- Auth State ---
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(checkAuthStatus);
    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final repo = ref.read(authRepositoryProvider);
    final isAuth = await repo.isAuthenticated();
    if (isAuth) {
      final user = await repo.getCurrentUser();
      state = state.copyWith(user: user, isAuthenticated: true);
    } else {
      state = state.copyWith(user: null, isAuthenticated: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state =
          state.copyWith(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      state =
          state.copyWith(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}

final authStateProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// --- Trends Notifier ---
class TrendsNotifier extends AsyncNotifier<List<TrendModel>> {
  @override
  Future<List<TrendModel>> build() async {
    final repo = ref.watch(trendRepositoryProvider);
    return repo.getTrends(includeArchived: true);
  }

  Future<void> loadTrends() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(trendRepositoryProvider).getTrends(includeArchived: true);
    });
  }

  Future<TrendModel> createTrend(TrendModel trend) async {
    final created = await ref.read(trendRepositoryProvider).createTrend(trend);
    await ref.read(activityRepositoryProvider).logActivity(
      title: 'Created "${trend.name}" trend',
      description: 'Initialized tracking with target ${trend.targetValue}',
      iconName: 'add_chart',
      trendId: created.id,
    );
    await loadTrends();
    return created;
  }

  Future<TrendModel> updateTrend(TrendModel trend) async {
    final updated = await ref.read(trendRepositoryProvider).updateTrend(trend);
    await ref.read(activityRepositoryProvider).logActivity(
      title: 'Updated "${trend.name}"',
      description: 'Modified trend configuration or goal',
      iconName: 'timeline',
      trendId: updated.id,
    );
    await loadTrends();
    return updated;
  }

  Future<void> deleteTrend(String id) async {
    final current = state.value?.where((t) => t.id == id).firstOrNull;
    final name = current?.name ?? 'trend';
    await ref.read(trendRepositoryProvider).deleteTrend(id);
    await ref.read(activityRepositoryProvider).logActivity(
      title: 'Deleted "$name"',
      description: 'Removed trend and all historical data points',
      iconName: 'delete',
    );
    await loadTrends();
  }

  Future<TrendModel> duplicateTrend(String id) async {
    final duplicated =
        await ref.read(trendRepositoryProvider).duplicateTrend(id);
    await ref.read(activityRepositoryProvider).logActivity(
      title: 'Duplicated "${duplicated.name}"',
      description: 'Created a new copy with existing data points',
      iconName: 'add_chart',
      trendId: duplicated.id,
    );
    await loadTrends();
    return duplicated;
  }

  Future<TrendModel> toggleArchive(String id) async {
    final toggled = await ref.read(trendRepositoryProvider).toggleArchive(id);
    await ref.read(activityRepositoryProvider).logActivity(
      title: toggled.isArchived
          ? 'Archived "${toggled.name}"'
          : 'Restored "${toggled.name}"',
      description: toggled.isArchived
          ? 'Hidden from active views'
          : 'Returned to active trends',
      iconName: 'timeline',
      trendId: toggled.id,
    );
    await loadTrends();
    return toggled;
  }

  Future<TrendModel> addDataPoint(
      String trendId, TrendDataPointModel point) async {
    final updated =
        await ref.read(trendRepositoryProvider).addDataPoint(trendId, point);
    await ref.read(activityRepositoryProvider).logActivity(
      title: 'Added data point for "${updated.name}"',
      description:
          'Value logged: ${point.value}${point.note != null ? ' (${point.note})' : ''}',
      iconName: 'trending_up',
      trendId: trendId,
    );
    await loadTrends();
    return updated;
  }

  Future<void> updateDataPoint(
      String trendId, TrendDataPointModel point) async {
    await ref.read(trendRepositoryProvider).updateDataPoint(trendId, point);
    await loadTrends();
  }

  Future<void> deleteDataPoint(String trendId, String pointId) async {
    await ref.read(trendRepositoryProvider).deleteDataPoint(trendId, pointId);
    await ref.read(activityRepositoryProvider).logActivity(
      title: 'Deleted data point',
      description: 'Removed historical data point entry',
      iconName: 'delete',
      trendId: trendId,
    );
    await loadTrends();
  }
}

final trendsProvider =
    AsyncNotifierProvider<TrendsNotifier, List<TrendModel>>(TrendsNotifier.new);

// --- FilterCriteria State ---
class FilterCriteriaNotifier extends Notifier<FilterCriteria> {
  @override
  FilterCriteria build() => FilterCriteria.empty;

  void setFilter(FilterCriteria criteria) => state = criteria;
}

final trendFilterCriteriaProvider =
    NotifierProvider<FilterCriteriaNotifier, FilterCriteria>(
        FilterCriteriaNotifier.new);

// --- SortOption State ---
class TrendSortNotifier extends Notifier<TrendSortOption> {
  @override
  TrendSortOption build() => TrendSortOption.recentlyUpdated;

  void setSort(TrendSortOption option) => state = option;
}

final trendSortOptionProvider =
    NotifierProvider<TrendSortNotifier, TrendSortOption>(
        TrendSortNotifier.new);

// --- SearchQuery State ---
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final trendSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// --- Filtered Trends Provider ---
final filteredTrendsProvider = Provider<List<TrendModel>>((ref) {
  final trendsAsync = ref.watch(trendsProvider);
  final filter = ref.watch(trendFilterCriteriaProvider);
  final sort = ref.watch(trendSortOptionProvider);
  final search = ref.watch(trendSearchQueryProvider);

  return trendsAsync.maybeWhen(
    data: (trends) {
      var list = trends.where((t) {
        if (t.isArchived) return false;
        if (search.trim().isNotEmpty) {
          final q = search.trim().toLowerCase();
          final matchesName = t.name.toLowerCase().contains(q);
          final matchesCat = t.category.toLowerCase().contains(q);
          final matchesDesc = t.description.toLowerCase().contains(q);
          if (!matchesName && !matchesCat && !matchesDesc) return false;
        }
        if (filter.category != null && filter.category!.isNotEmpty) {
          if (t.category.toLowerCase() != filter.category!.toLowerCase()) {
            return false;
          }
        }
        if (filter.direction != null) {
          if (t.direction != filter.direction) return false;
        }
        if (filter.frequency != null && filter.frequency!.isNotEmpty) {
          if (t.frequency.toLowerCase() != filter.frequency!.toLowerCase()) {
            return false;
          }
        }
        if (filter.minValue != null && t.currentValue < filter.minValue!) {
          return false;
        }
        if (filter.maxValue != null && t.currentValue > filter.maxValue!) {
          return false;
        }
        if (filter.dateRange != null) {
          if (t.startDate.isBefore(filter.dateRange!.start) ||
              t.startDate.isAfter(filter.dateRange!.end)) {
            return false;
          }
        }
        return true;
      }).toList();

      switch (sort) {
        case TrendSortOption.recentlyUpdated:
          list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
        case TrendSortOption.nameAsc:
          list.sort((a, b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case TrendSortOption.highestGrowth:
          list.sort((a, b) => b.percentageGrowth.compareTo(a.percentageGrowth));
          break;
        case TrendSortOption.lowestGrowth:
          list.sort((a, b) => a.percentageGrowth.compareTo(b.percentageGrowth));
          break;
        case TrendSortOption.highestValue:
          list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
          break;
        case TrendSortOption.lowestValue:
          list.sort((a, b) => a.currentValue.compareTo(b.currentValue));
          break;
      }
      return list;
    },
    orElse: () => [],
  );
});

// Single Trend by ID provider
final trendDetailsProvider = Provider.family<TrendModel?, String>((ref, id) {
  final trends = ref.watch(trendsProvider).value ?? [];
  return trends.where((t) => t.id == id).firstOrNull;
});

// Analytics Summary Provider
final analyticsSummaryProvider = Provider<OverallAnalyticsSummary>((ref) {
  final trends = ref.watch(trendsProvider).value ?? [];
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.computeOverallSummary(trends);
});

// Notifications Notifier
class NotificationsNotifier extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    Future.microtask(loadNotifications);
    return [];
  }

  Future<void> loadNotifications() async {
    final repo = ref.read(notificationRepositoryProvider);
    state = await repo.getNotifications();
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();
    await loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.deleteNotification(id);
    await loadNotifications();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<NotificationModel>>(
        NotificationsNotifier.new);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider);
  return list.where((n) => !n.isRead).length;
});

// Activity Timeline Notifier
class ActivityNotifier extends Notifier<List<ActivityModel>> {
  @override
  List<ActivityModel> build() {
    Future.microtask(loadActivities);
    return [];
  }

  Future<void> loadActivities({String? query}) async {
    final repo = ref.read(activityRepositoryProvider);
    state = await repo.getActivities(searchQuery: query);
  }

  Future<void> clearActivities() async {
    final repo = ref.read(activityRepositoryProvider);
    await repo.clearAll();
    state = [];
  }
}

final activityProvider =
    NotifierProvider<ActivityNotifier, List<ActivityModel>>(
        ActivityNotifier.new);
