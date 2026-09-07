class ForecastItem {
  final String time;
  final String date;
  final String temperature;
  final String condition;
  final String iconUrl;

  ForecastItem({
    required this.time,
    required this.date,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final dt = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    final icon = json['weather'][0]['icon'] as String;
    final temp = (json['main']['temp'] as double).round();

    return ForecastItem(
      time: '${dt.hour.toString().padLeft(2, '0')}:00',
      date: '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}',
      temperature: '$temp°',
      condition: json['weather'][0]['description'],
      iconUrl: 'https://openweathermap.org/img/wn/$icon@2x.png',
    );
  }

  String displayTemp(bool isCelsius) {
    final val = int.tryParse(temperature.replaceAll('°', '')) ?? 0;
    if (isCelsius) return '$val°C';
    return '${(val * 9 / 5 + 32).round()}°F';
  }
}
