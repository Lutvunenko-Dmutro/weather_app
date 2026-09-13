import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _apiKey =
      String.fromEnvironment('OWM_API_KEY', defaultValue: '2cb4d4edd671231364e6d681c8465a4c');

  Future<WeatherModel> fetchWeather(String city, {String lang = 'uk'}) async {
    // Uri.https правильно кодує кирилицю та спецсимволи
    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(city, json.decode(response.body));
      }
      return WeatherModel.error(city);
    } catch (_) {
      return WeatherModel.error(city);
    }
  }

  Future<List<ForecastItem>> fetchForecast(String city, {String lang = 'uk'}) async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
      'cnt': '40',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['list'];
        return list.map((item) => ForecastItem.fromJson(item)).toList();
      }
      print('HTTP Error for $city: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e, st) {
      print('FetchForecast Error for $city: $e\n$st');
      return [];
    }
  }

  // Послідовне завантаження з 500ms паузою — надійне уникнення rate limit
  Future<List<WeatherModel>> fetchWeatherForCities(List<String> cities, {String lang = 'uk'}) async {
    final results = <WeatherModel>[];
    for (var i = 0; i < cities.length; i++) {
      results.add(await fetchWeather(cities[i], lang: lang));
      if (i < cities.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return results;
  }

  Future<Map<String, List<ForecastItem>>> fetchForecastForCities(List<String> cities, {String lang = 'uk'}) async {
    final results = <String, List<ForecastItem>>{};
    for (var i = 0; i < cities.length; i++) {
      results[cities[i]] = await fetchForecast(cities[i], lang: lang);
      if (i < cities.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return results;
  }

  Future<List<String>> fetchCitySuggestions(String query, {String lang = 'uk'}) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': query.trim(),
      'limit': '5',
      'appid': _apiKey,
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) {
          final localNames = item['local_names'];
          print('DEBUG: localNames type = ${localNames.runtimeType}, value = $localNames');
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

}
