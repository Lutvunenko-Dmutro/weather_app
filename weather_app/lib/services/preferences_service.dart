import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton wrapper around SharedPreferences to avoid repeated getInstance() calls.
class PreferencesService {
  PreferencesService._();

  static SharedPreferences? _prefs;

  /// Call once at app startup (in main or initLogic) before using other methods.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'PreferencesService.init() must be called before use.');
    return _prefs!;
  }

  // ── Cities ─────────────────────────────────────────────────────────────────

  static List<String>? loadCities() => _instance.getStringList('cities');

  static Future<void> saveCities(List<String> cities) =>
      _instance.setStringList('cities', cities);

  // ── Effect variants ────────────────────────────────────────────────────────

  static int loadVariant(String weatherType) {
    return _instance.getInt('${weatherType}Variant') ?? 0;
  }

  static Future<void> saveVariant(String weatherType, int variant) =>
      _instance.setInt('${weatherType}Variant', variant);

  // ── Notifications ──────────────────────────────────────────────────────────

  static bool loadNotificationsEnabled() {
    return _instance.getBool('notificationsEnabled') ?? false;
  }

  static Future<void> saveNotificationsEnabled(bool enabled) =>
      _instance.setBool('notificationsEnabled', enabled);

  // Custom alert settings
  static bool loadNotifyRegular() => _instance.getBool('notifyRegular') ?? true;
  static Future<void> saveNotifyRegular(bool val) => _instance.setBool('notifyRegular', val);

  static bool loadNotifyRain() => _instance.getBool('notifyRain') ?? true;
  static Future<void> saveNotifyRain(bool val) => _instance.setBool('notifyRain', val);

  static bool loadNotifyFreeze() => _instance.getBool('notifyFreeze') ?? true;
  static Future<void> saveNotifyFreeze(bool val) => _instance.setBool('notifyFreeze', val);

  // Notification History
  // Stores a list of JSON strings: [{"time": 169..., "title": "...", "body": "...", "icon": "..."}]
  static List<Map<String, dynamic>> loadNotificationHistory() {
    final list = _instance.getStringList('notificationHistory') ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> saveNotificationToHistory(Map<String, dynamic> notification) async {
    final history = loadNotificationHistory();
    history.insert(0, notification); // add to top
    if (history.length > 50) {
      history.removeLast(); // keep last 50
    }
    final stringList = history.map((e) => jsonEncode(e)).toList();
    await _instance.setStringList('notificationHistory', stringList);
  }
}
