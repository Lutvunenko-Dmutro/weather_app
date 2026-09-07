import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // Замініть на власний API-ключ з https://openweathermap.org/
  // Або передайте через змінну середовища при збірці:
  // flutter run --dart-define=OWM_API_KEY=your_key_here
  static const String _apiKey =
      String.fromEnvironment('OWM_API_KEY', defaultValue: 'YOUR_API_KEY_HERE');

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> fetchWeather(String city) async {
    final url = Uri.parse(
        '$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=uk');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(city, data);
      } else {
        return WeatherModel.error(city);
      }
    } catch (_) {
      return WeatherModel.error(city);
    }
  }

  Future<List<WeatherModel>> fetchWeatherForCities(List<String> cities) async {
    final futures = cities.map((city) => fetchWeather(city));
    return Future.wait(futures);
  }

  Future<List<String>> loadUkrainianCities() async {
    final String response =
        await rootBundle.loadString('assets/ukrainian_cities.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }
}
