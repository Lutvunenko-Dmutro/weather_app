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
}
