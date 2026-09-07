class WeatherModel {
  final String city;
  final String temperature;
  final String feelsLike;
  final String tempMin;
  final String tempMax;
  final String condition;
  final String conditionId;
  final String iconUrl;
  final int humidity;
  final double windSpeed;
  final bool isError;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.conditionId,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    this.isError = false,
  });

  factory WeatherModel.fromJson(String city, Map<String, dynamic> json) {
    final icon = json['weather'][0]['icon'] as String;
    final condId = json['weather'][0]['id'].toString();

    return WeatherModel(
      city: city,
      temperature: '${(json['main']['temp'] as double).round()}°',
      feelsLike: '${(json['main']['feels_like'] as double).round()}°',
      tempMin: '${(json['main']['temp_min'] as double).round()}°',
      tempMax: '${(json['main']['temp_max'] as double).round()}°',
      condition: json['weather'][0]['description'],
      conditionId: condId,
      iconUrl: 'https://openweathermap.org/img/wn/$icon@2x.png',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  // Повертає температуру у Fahrenheit якщо потрібно
  String displayTemp(bool isCelsius) {
    final val = int.tryParse(temperature.replaceAll('°', '')) ?? 0;
    if (isCelsius) return '$val°C';
    return '${(val * 9 / 5 + 32).round()}°F';
  }

  String displayFeelsLike(bool isCelsius) {
    final val = int.tryParse(feelsLike.replaceAll('°', '')) ?? 0;
    if (isCelsius) return '$val°C';
    return '${(val * 9 / 5 + 32).round()}°F';
  }

  static WeatherModel error(String city) {
    return WeatherModel(
      city: city,
      temperature: 'N/A',
      feelsLike: 'N/A',
      tempMin: 'N/A',
      tempMax: 'N/A',
      condition: 'Не вдалося отримати дані',
      conditionId: '0',
      iconUrl: '',
      humidity: 0,
      windSpeed: 0,
      isError: true,
    );
  }
}
