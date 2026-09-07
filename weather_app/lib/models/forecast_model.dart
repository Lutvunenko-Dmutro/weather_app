class ForecastItem {
  final DateTime dateTime;
  final int rawTemp;
  final String condition;
  final String iconUrl;

  ForecastItem({
    required this.dateTime,
    required this.rawTemp,
    required this.condition,
    required this.iconUrl,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final dt = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    final icon = json['weather'][0]['icon'] as String;
    final temp = (json['main']['temp'] as num).round();

    return ForecastItem(
      dateTime: dt,
      rawTemp: temp,
      condition: json['weather'][0]['description'],
      iconUrl: 'https://openweathermap.org/img/wn/$icon@2x.png',
    );
  }

  String get time => '${dateTime.hour.toString().padLeft(2, '0')}:00';
  String get date => '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}';
  String get temperature => '$rawTemp°';

  String displayTemp(bool isCelsius) {
    if (isCelsius) return '$rawTemp°C';
    return '${(rawTemp * 9 / 5 + 32).round()}°F';
  }
}

class DailyForecast {
  final DateTime date;
  final int minTemp;
  final int maxTemp;
  final String condition;
  final String iconUrl;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.iconUrl,
  });

  static List<DailyForecast> fromHourly(List<ForecastItem> items) {
    final Map<int, List<ForecastItem>> grouped = {};
    for (var item in items) {
      final day = DateTime(item.dateTime.year, item.dateTime.month, item.dateTime.day).millisecondsSinceEpoch;
      grouped.putIfAbsent(day, () => []).add(item);
    }

    final List<DailyForecast> daily = [];
    grouped.forEach((dayMs, dayItems) {
      int minT = dayItems.first.rawTemp;
      int maxT = dayItems.first.rawTemp;
      for (var i in dayItems) {
        if (i.rawTemp < minT) minT = i.rawTemp;
        if (i.rawTemp > maxT) maxT = i.rawTemp;
      }
      
      // Select the icon from the middle of the day (usually around noon/15:00)
      final midDayItem = dayItems.firstWhere(
        (i) => i.dateTime.hour >= 11 && i.dateTime.hour <= 15,
        orElse: () => dayItems.first,
      );

      daily.add(DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch(dayMs),
        minTemp: minT,
        maxTemp: maxT,
        condition: midDayItem.condition,
        iconUrl: midDayItem.iconUrl,
      ));
    });

    return daily.take(5).toList();
  }

  String displayMinTemp(bool isCelsius) {
    if (isCelsius) return '$minTemp°';
    return '${(minTemp * 9 / 5 + 32).round()}°';
  }

  String displayMaxTemp(bool isCelsius) {
    if (isCelsius) return '$maxTemp°';
    return '${(maxTemp * 9 / 5 + 32).round()}°';
  }
}
