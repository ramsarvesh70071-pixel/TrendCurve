import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/trend_model.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'sample_data.dart';

/// Central local data persistence service.
/// Guarantees that changes persist across app reloads, while remaining completely offline-capable.
class LocalStorageService {
  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  LocalStorageService({
    required this.prefs,
    this.secureStorage = const FlutterSecureStorage(),
  });

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs: prefs);
    await service._ensureInitialDataSeeded();
    return service;
  }

  Future<void> _ensureInitialDataSeeded() async {
    if (!prefs.containsKey(AppConstants.keyTrends)) {
      await saveTrends(SampleData.initialTrends);
    }
    if (!prefs.containsKey(AppConstants.keyActivities)) {
      await saveActivities(SampleData.initialActivities);
    }
    if (!prefs.containsKey(AppConstants.keyNotifications)) {
      await saveNotifications(SampleData.initialNotifications);
    }
    if (!prefs.containsKey(AppConstants.keyUserData)) {
      await saveUser(SampleData.user);
    }
  }

  // --- Onboarding & Auth State ---
  bool isOnboardingComplete() {
    return prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await prefs.setBool(AppConstants.keyOnboardingComplete, value);
  }

  bool hasAuthTokenSync() {
    return prefs.containsKey(AppConstants.keyAuthToken);
  }

  String? getAuthTokenSync() {
    return prefs.getString(AppConstants.keyAuthToken);
  }

  Future<String?> getAuthToken() async {
    try {
      return await secureStorage.read(key: AppConstants.keyAuthToken);
    } catch (_) {
      return prefs.getString(AppConstants.keyAuthToken);
    }
  }

  Future<void> setAuthToken(String? token) async {
    if (token == null) {
      try {
        await secureStorage.delete(key: AppConstants.keyAuthToken);
      } catch (_) {}
      await prefs.remove(AppConstants.keyAuthToken);
    } else {
      try {
        await secureStorage.write(key: AppConstants.keyAuthToken, value: token);
      } catch (_) {}
      await prefs.setString(AppConstants.keyAuthToken, token);
    }
  }

  UserModel? getUser() {
    final raw = prefs.getString(AppConstants.keyUserData);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  Future<void> removeUser() async {
    await prefs.remove(AppConstants.keyUserData);
  }

  // --- Trends CRUD ---
  List<TrendModel> getTrends() {
    final raw = prefs.getString(AppConstants.keyTrends);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => TrendModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTrends(List<TrendModel> trends) async {
    final jsonList = trends.map((t) => t.toJson()).toList();
    await prefs.setString(AppConstants.keyTrends, jsonEncode(jsonList));
  }

  // --- Activities ---
  List<ActivityModel> getActivities() {
    final raw = prefs.getString(AppConstants.keyActivities);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ActivityModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActivities(List<ActivityModel> activities) async {
    final jsonList = activities.map((a) => a.toJson()).toList();
    await prefs.setString(AppConstants.keyActivities, jsonEncode(jsonList));
  }

  // --- Notifications ---
  List<NotificationModel> getNotifications() {
    final raw = prefs.getString(AppConstants.keyNotifications);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(AppConstants.keyNotifications, jsonEncode(jsonList));
  }

  // --- Preferences ---
  String getThemeMode() {
    return prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await prefs.setString(AppConstants.keyThemeMode, mode);
  }

  String getDefaultCurrency() {
    return prefs.getString(AppConstants.keyDefaultCurrency) ?? '₹';
  }

  Future<void> setDefaultCurrency(String currency) async {
    await prefs.setString(AppConstants.keyDefaultCurrency, currency);
  }

  String getDefaultTimeRange() {
    return prefs.getString(AppConstants.keyDefaultTimeRange) ?? '30D';
  }

  Future<void> setDefaultTimeRange(String range) async {
    await prefs.setString(AppConstants.keyDefaultTimeRange, range);
  }

  bool getNotificationsEnabled() {
    return prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
  }

  // --- Export & Import ---
  String exportAsJson() {
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
      'trends': getTrends().map((t) => t.toJson()).toList(),
      'activities': getActivities().map((a) => a.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  String exportAsCsv() {
    final trends = getTrends();
    final buffer = StringBuffer();
    buffer.writeln('TrendID,TrendName,Category,Unit,Date,Value,Note');
    for (final t in trends) {
      for (final dp in t.dataPoints) {
        final sanitizedNote = (dp.note ?? '').replaceAll('"', '""');
        buffer.writeln(
            '"${t.id}","${t.name}","${t.category}","${t.unit}","${dp.date.toIso8601String()}",${dp.value},"$sanitizedNote"');
      }
    }
    return buffer.toString();
  }

  Future<bool> importFromJson(String jsonContent) async {
    try {
      final decoded = jsonDecode(jsonContent) as Map<String, dynamic>;
      if (decoded.containsKey('trends')) {
        final rawTrends = decoded['trends'] as List<dynamic>;
        final importedTrends = rawTrends
            .map((item) => TrendModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await saveTrends(importedTrends);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAllData() async {
    await prefs.remove(AppConstants.keyTrends);
    await prefs.remove(AppConstants.keyActivities);
    await prefs.remove(AppConstants.keyNotifications);
    // Reset with empty list so empty state is displayed properly
    await saveTrends([]);
    await saveActivities([]);
    await saveNotifications([]);
  }

  Future<void> resetToSeedData() async {
    await saveTrends(SampleData.initialTrends);
    await saveActivities(SampleData.initialActivities);
    await saveNotifications(SampleData.initialNotifications);
  }
}
