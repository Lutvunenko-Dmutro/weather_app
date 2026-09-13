import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/widgets.dart' show Locale;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class LocationService {
  static const String _apiKey =
      String.fromEnvironment('OWM_API_KEY', defaultValue: '2cb4d4edd671231364e6d681c8465a4c');

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Служби локації вимкнено.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('У дозволі на локацію відмовлено.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Дозволи на локацію заборонені назавжди.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<WeatherModel> fetchWeatherByLocation(double lat, double lon, {String lang = 'uk'}) async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String city = data['name'] as String;
        String? translatedCity;
        
        // Try reverse geocoding to get localized name using the highly accurate native geocoding package
        try {
          final geocoding = Geocoding();
          final targetLocale = lang == 'uk' ? const Locale('uk', 'UA') : const Locale('en', 'US');
          
          final placemarks = await geocoding.placemarkFromCoordinates(lat, lon, locale: targetLocale);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            if (place.locality != null && place.locality!.isNotEmpty) {
              translatedCity = place.locality;
            } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
              translatedCity = place.subAdministrativeArea;
            } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
              translatedCity = place.administrativeArea;
            }
          }
        } catch (_) {
          print('Reverse geocoding with geocoding package failed.');
        }

        return WeatherModel.fromJson(city, data).copyWith(
          isCurrentLocation: true,
          translatedCity: translatedCity ?? city,
        );
      }
      return WeatherModel.error('Location');
    } catch (_) {
      return WeatherModel.error('Location');
    }
  }

  Future<List<ForecastItem>> fetchForecastByLocation(double lat, double lon, {String lang = 'uk'}) async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'lat': lat.toString(),
      'lon': lon.toString(),
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
      return [];
    } catch (_) {
      return [];
    }
  }
}
