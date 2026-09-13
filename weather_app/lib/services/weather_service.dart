import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

// ── In-memory cache entry ─────────────────────────────────────────────────────
class _CacheEntry<T> {
  final T data;
  final DateTime fetchedAt;
  _CacheEntry(this.data) : fetchedAt = DateTime.now();

  bool get isStale => DateTime.now().difference(fetchedAt) > const Duration(minutes: 10);
}

class WeatherService {
  static const String _apiKey =
      String.fromEnvironment('OWM_API_KEY', defaultValue: '2cb4d4edd671231364e6d681c8465a4c');

  // Shared HTTP client for connection reuse (keep-alive)
  static final http.Client _client = http.Client();

  // In-memory cache: key = "$city|$lang"
  final _weatherCache = <String, _CacheEntry<WeatherModel>>{};
  final _forecastCache = <String, _CacheEntry<List<ForecastItem>>>{};

  // ── Single city ────────────────────────────────────────────────────────────

  Future<WeatherModel> fetchWeather(String city, {String lang = 'uk', bool forceRefresh = false}) async {
    final key = '$city|$lang';
    if (!forceRefresh) {
      final cached = _weatherCache[key];
      if (cached != null && !cached.isStale) return cached.data;
    }

    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
    });

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final model = WeatherModel.fromJson(city, json.decode(response.body));
        _weatherCache[key] = _CacheEntry(model);
        return model;
      }
      return WeatherModel.error(city);
    } catch (_) {
      // Return stale data if available rather than an error
      final stale = _weatherCache[key];
      return stale?.data ?? WeatherModel.error(city);
    }
  }

  Future<List<ForecastItem>> fetchForecast(String city, {String lang = 'uk', bool forceRefresh = false}) async {
    final key = '$city|$lang';
    if (!forceRefresh) {
      final cached = _forecastCache[key];
      if (cached != null && !cached.isStale) return cached.data;
    }

    final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
      'cnt': '40',
    });

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['list'] as List)
            .map((item) => ForecastItem.fromJson(item))
            .toList();
        _forecastCache[key] = _CacheEntry(items);
        return items;
      }
      debugPrint('WeatherService: HTTP ${response.statusCode} for $city forecast');
      return _forecastCache[key]?.data ?? [];
    } catch (e) {
      debugPrint('WeatherService: fetchForecast error for $city: $e');
      return _forecastCache[key]?.data ?? [];
    }
  }

  // ── Multi-city — PARALLEL ─────────────────────────────────────────────────

  Future<List<WeatherModel>> fetchWeatherForCities(
    List<String> cities, {
    String lang = 'uk',
    bool forceRefresh = false,
  }) {
    return Future.wait(
      cities.map((c) => fetchWeather(c, lang: lang, forceRefresh: forceRefresh)),
    );
  }

  Future<Map<String, List<ForecastItem>>> fetchForecastForCities(
    List<String> cities, {
    String lang = 'uk',
    bool forceRefresh = false,
  }) async {
    final results = await Future.wait(
      cities.map((c) => fetchForecast(c, lang: lang, forceRefresh: forceRefresh)),
    );
    return {for (var i = 0; i < cities.length; i++) cities[i]: results[i]};
  }

  // ── City geo-search ───────────────────────────────────────────────────────

  Future<List<String>> fetchCitySuggestions(String query, {String lang = 'uk'}) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': query.trim(),
      'limit': '5',
      'appid': _apiKey,
    });

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) {
          final localNames = item['local_names'];
          String name = item['name'] as String;
          if (localNames is Map) {
            if (localNames.containsKey(lang)) {
              name = localNames[lang].toString();
            } else if (lang == 'uk' && localNames.containsKey('ru')) {
              name = localNames['ru'].toString();
            }
          }
          final state = item['state'] != null ? ', ${item['state']}' : '';
          final country = item['country'] != null ? ', ${item['country']}' : '';
          return '$name$state$country';
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void dispose() => _client.close();
}
