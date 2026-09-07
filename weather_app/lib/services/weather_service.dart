import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  // API-ключ з https://openweathermap.org/
  // Для prod-збірки передавайте через: flutter run --dart-define=OWM_API_KEY=your_key
  static const String _apiKey =
      String.fromEnvironment('OWM_API_KEY', defaultValue: '2cb4d4edd671231364e6d681c8465a4c');

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> fetchWeather(String city) async {
    final url = Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=uk');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(city, json.decode(response.body));
      }
      return WeatherModel.error(city);
    } catch (_) {
      return WeatherModel.error(city);
    }
  }

  Future<List<ForecastItem>> fetchForecast(String city) async {
    final url = Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&lang=uk&cnt=40');
    try {
      final response = await http.get(url);
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

  Future<List<WeatherModel>> fetchWeatherForCities(List<String> cities) async {
    return Future.wait(cities.map((city) => fetchWeather(city)));
  }

  Future<List<String>> loadUkrainianCities() async {
    final String response = await rootBundle.loadString('assets/ukrainian_cities.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }
}
