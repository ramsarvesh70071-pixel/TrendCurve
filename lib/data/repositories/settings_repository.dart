import '../local/local_storage_service.dart';

class SettingsRepository {
  final LocalStorageService _storage;

  SettingsRepository(this._storage);

  String getThemeMode() => _storage.getThemeMode();
  Future<void> setThemeMode(String mode) => _storage.setThemeMode(mode);

  String getDefaultCurrency() => _storage.getDefaultCurrency();
  Future<void> setDefaultCurrency(String currency) =>
      _storage.setDefaultCurrency(currency);

  String getDefaultTimeRange() => _storage.getDefaultTimeRange();
  Future<void> setDefaultTimeRange(String range) =>
      _storage.setDefaultTimeRange(range);

  bool getNotificationsEnabled() => _storage.getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled) =>
      _storage.setNotificationsEnabled(enabled);

  String exportJson() => _storage.exportAsJson();
  String exportCsv() => _storage.exportAsCsv();
  Future<bool> importJson(String jsonStr) => _storage.importFromJson(jsonStr);

  Future<void> clearAllData() => _storage.clearAllData();
  Future<void> resetToSeedData() => _storage.resetToSeedData();
}
