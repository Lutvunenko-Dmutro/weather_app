import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';

class WeatherModel {
  final String city;
  final String? translatedCity;
  final String condition;
  final String conditionId;
  final String iconUrl;
  final int rawTemp;
  final int rawTempMin;
  final int rawTempMax;
  final int rawFeelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final bool isError;
  final bool isCurrentLocation;

  WeatherModel({
    required this.city,
    this.translatedCity,
    required this.condition,
    required this.conditionId,
    required this.iconUrl,
    required this.rawTemp,
    required this.rawTempMin,
    required this.rawTempMax,
    required this.rawFeelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    this.isError = false,
    this.isCurrentLocation = false,
  });

  factory WeatherModel.fromJson(String city, Map<String, dynamic> json) {
    final icon = json['weather'][0]['icon'] as String;
    return WeatherModel(
      city: city,
      translatedCity: null, // Don't use json['name'] because OWM basic /weather API returns English names.
      condition: json['weather'][0]['description'] as String,
      conditionId: json['weather'][0]['id'].toString(),
      iconUrl: 'https://openweathermap.org/img/wn/$icon@2x.png',
      rawTemp: (json['main']['temp'] as num).round(),
      rawTempMin: (json['main']['temp_min'] as num).round(),
      rawTempMax: (json['main']['temp_max'] as num).round(),
      rawFeelsLike: (json['main']['feels_like'] as num).round(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      isCurrentLocation: false, // Default to false, can be overridden via copyWith or set externally
    );
  }

  WeatherModel copyWith({bool? isCurrentLocation, String? translatedCity}) {
    return WeatherModel(
      city: city,
      translatedCity: translatedCity ?? this.translatedCity,
      condition: condition,
      conditionId: conditionId,
      iconUrl: iconUrl,
      rawTemp: rawTemp,
      rawTempMin: rawTempMin,
      rawTempMax: rawTempMax,
      rawFeelsLike: rawFeelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      isError: isError,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  factory WeatherModel.error(String city) {
    return WeatherModel(
      city: city,
      translatedCity: city,
      condition: '',
      conditionId: '',
      iconUrl: '',
      rawTemp: 0,
      rawTempMin: 0,
      rawTempMax: 0,
      rawFeelsLike: 0,
      humidity: 0,
      windSpeed: 0.0,
      pressure: 0,
      isError: true,
    );
  }

  String get tempMin => '${rawTempMin}°';
  String get tempMax => '${rawTempMax}°';

  String displayTemp(bool isCelsius) {
    if (isCelsius) return '$rawTemp°C';
    return '${(rawTemp * 9 / 5 + 32).round()}°F';
  }

  String displayFeelsLike(bool isCelsius) {
    if (isCelsius) return '$rawFeelsLike°C';
    return '${(rawFeelsLike * 9 / 5 + 32).round()}°F';
  }

  WeatherType getWeatherBgType() {
    if (isError) return WeatherType.sunny;
    final id = int.tryParse(conditionId) ?? 800;
    final isNight = iconUrl.contains('n@2x.png');

    if (id >= 200 && id < 300) {
      return WeatherType.thunder;
    } else if (id >= 300 && id < 400) {
      return WeatherType.lightRainy;
    } else if (id >= 500 && id < 600) {
      if (id == 500 || id == 501) return WeatherType.lightRainy;
      if (id == 511) return WeatherType.middleSnow;
      return WeatherType.heavyRainy;
    } else if (id >= 600 && id < 700) {
      if (id == 600 || id == 612 || id == 615 || id == 620) return WeatherType.lightSnow;
      if (id == 602 || id == 622) return WeatherType.heavySnow;
      return WeatherType.middleSnow;
    } else if (id >= 700 && id < 800) {
      if (id == 701 || id == 741) return WeatherType.foggy;
      if (id == 711 || id == 721) return WeatherType.hazy;
      if (id == 731 || id == 751 || id == 761 || id == 762) return WeatherType.dusty;
      if (id == 771 || id == 781) return WeatherType.heavyRainy;
      return WeatherType.foggy;
    } else if (id == 800) {
      return isNight ? WeatherType.sunnyNight : WeatherType.sunny;
    } else if (id == 801 || id == 802) {
      return isNight ? WeatherType.cloudyNight : WeatherType.cloudy;
    } else if (id == 803 || id == 804) {
      return WeatherType.overcast;
    }
    return isNight ? WeatherType.sunnyNight : WeatherType.sunny;
  }
}
