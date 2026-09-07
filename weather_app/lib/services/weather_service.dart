import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _apiKey =
      String.fromEnvironment('OWM_API_KEY', defaultValue: '2cb4d4edd671231364e6d681c8465a4c');

  Future<WeatherModel> fetchWeather(String city) async {
    // Uri.https правильно кодує кирилицю та спецсимволи
    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'uk',
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

  Future<List<ForecastItem>> fetchForecast(String city) async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'uk',
      'cnt': '40',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['list'];
        return list.map((item) => ForecastItem.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Послідовне завантаження з 500ms паузою — надійне уникнення rate limit
  Future<List<WeatherModel>> fetchWeatherForCities(List<String> cities) async {
    final results = <WeatherModel>[];
    for (var i = 0; i < cities.length; i++) {
      results.add(await fetchWeather(cities[i]));
      if (i < cities.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return results;
  }

  Future<Map<String, List<ForecastItem>>> fetchForecastForCities(List<String> cities) async {
    final results = <String, List<ForecastItem>>{};
    for (var i = 0; i < cities.length; i++) {
      results[cities[i]] = await fetchForecast(cities[i]);
      if (i < cities.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return results;
  }

  Future<List<String>> loadUkrainianCities() async {
    final String response =
        await rootBundle.loadString('assets/ukrainian_cities.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }
}
