import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _citiesKey = 'cities';
  static const _sunVariantKey = 'sunVariant';
  static const _rainVariantKey = 'rainVariant';
  static const _snowVariantKey = 'snowVariant';
  static const _cloudVariantKey = 'cloudVariant';

  static Future<List<String>?> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_citiesKey);
  }

  static Future<void> saveCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_citiesKey, cities);
  }

  static Future<int> loadVariant(String weatherType) async {
    final prefs = await SharedPreferences.getInstance();
    switch (weatherType) {
      case 'sun': return prefs.getInt(_sunVariantKey) ?? 0;
      case 'rain': return prefs.getInt(_rainVariantKey) ?? 0;
      case 'snow': return prefs.getInt(_snowVariantKey) ?? 0;
      case 'cloud': return prefs.getInt(_cloudVariantKey) ?? 0;
      default: return 0;
    }
  }

  static Future<void> saveVariant(String weatherType, int variant) async {
    final prefs = await SharedPreferences.getInstance();
    switch (weatherType) {
      case 'sun': await prefs.setInt(_sunVariantKey, variant); break;
      case 'rain': await prefs.setInt(_rainVariantKey, variant); break;
      case 'snow': await prefs.setInt(_snowVariantKey, variant); break;
      case 'cloud': await prefs.setInt(_cloudVariantKey, variant); break;
    }
  }
}
