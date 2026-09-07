class WeatherModel {
  final String city;
  final String temperature;
  final String condition;
  final String iconUrl;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory WeatherModel.fromJson(String city, Map<String, dynamic> json) {
    final double temp = json['main']['temp'];
    final int roundedTemp = temp.round();
    final icon = json['weather'][0]['icon'];

    return WeatherModel(
      city: city,
      temperature: '$roundedTemp°C',
      condition: json['weather'][0]['description'],
      iconUrl: 'https://openweathermap.org/img/wn/$icon@2x.png',
    );
  }

  static WeatherModel error(String city) {
    return WeatherModel(
      city: city,
      temperature: 'N/A',
      condition: 'Не вдалося отримати дані',
      iconUrl: '',
    );
  }
}
