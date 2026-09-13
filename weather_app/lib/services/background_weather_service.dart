import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'weather_service.dart';
import 'notification_service.dart';
import 'preferences_service.dart';

/// Unique task name used by Workmanager
const _kWeatherTaskName = 'weatherDailyUpdate';
const _kWeatherTaskTag = 'weather_bg_update';

/// Called by Workmanager in the background isolate.
/// Must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('BackgroundWeatherService: task=$taskName');
    try {
      await PreferencesService.init();
      final cities = PreferencesService.loadCities() ?? ['Київ'];
      final lang = inputData?['lang'] as String? ?? 'uk';
      final isCelsius = (inputData?['isCelsius'] as bool?) ?? true;

      await NotificationService.init();

      final notifyRegular = PreferencesService.loadNotifyRegular();
      final notifyRain = PreferencesService.loadNotifyRain();
      final notifyFreeze = PreferencesService.loadNotifyFreeze();

      // If user disabled everything, just return
      if (!notifyRegular && !notifyRain && !notifyFreeze) return Future.value(true);

      final service = WeatherService();
      // Only fetch the first city to save battery
      final weather = await service.fetchWeather(cities.first, lang: lang);
      if (!weather.isError) {
        final tempStr = weather.displayTemp(isCelsius);
        final emoji = weatherEmoji(weather.conditionCode);
        
        bool shouldNotify = notifyRegular;
        String extraTitle = '';
        
        if (notifyFreeze && weather.rawTemp < 0) {
          shouldNotify = true;
          extraTitle = lang == 'uk' ? '❄️ Заморозки! ' : '❄️ Freeze Alert! ';
        }
        
        final code = weather.conditionCode ?? 0;
        final isRain = (code >= 200 && code <= 622); // Thunderstorm, Drizzle, Rain, Snow
        if (notifyRain && isRain) {
          shouldNotify = true;
          extraTitle = lang == 'uk' ? '☔ Опади! ' : '☔ Precipitation! ';
        }

        if (shouldNotify) {
          final cityName = weather.translatedCity ?? weather.city;
          final finalTitle = '$extraTitle$cityName — $tempStr';
          final finalBody = weather.condition;
          
          await NotificationService.showWeatherNotification(
            city: cityName,
            temp: tempStr,
            condition: weather.condition,
            emoji: emoji,
            lang: lang,
          );

          // Save to history
          await PreferencesService.saveNotificationToHistory({
            'time': DateTime.now().millisecondsSinceEpoch,
            'title': finalTitle,
            'body': finalBody,
            'emoji': emoji,
          });
        }
      }
      return Future.value(true);
    } catch (e) {
      debugPrint('BackgroundWeatherService: error $e');
      return Future.value(false);
    }
  });
}

/// Manages scheduling and cancelling of the periodic background weather update.
class BackgroundWeatherService {
  BackgroundWeatherService._();

  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Schedule a repeating task that fires every [hours] hours.
  static Future<void> schedule({
    required String lang,
    required bool isCelsius,
    int hours = 3,
  }) async {
    // Cancel any existing task first
    await Workmanager().cancelByUniqueName(_kWeatherTaskName);

    await Workmanager().registerPeriodicTask(
      _kWeatherTaskName,
      _kWeatherTaskTag,
      frequency: Duration(hours: hours),
      initialDelay: const Duration(minutes: 1),
      inputData: {'lang': lang, 'isCelsius': isCelsius},
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint('BackgroundWeatherService: scheduled every $hours hours');
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_kWeatherTaskName);
    debugPrint('BackgroundWeatherService: cancelled');
  }
}
