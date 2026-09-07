class WeatherModel {
  final String city;
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

  WeatherModel({
    required this.city,
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
  });

  factory WeatherModel.fromJson(String city, Map<String, dynamic> json) {
    final icon = json['weather'][0]['icon'] as String;
    return WeatherModel(
      city: city,
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
    );
  }

  factory WeatherModel.error(String city) {
    return WeatherModel(
      city: city,
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
}
