import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages local push notifications for weather updates.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'weather_updates';
  static const _channelName = 'Погодні оновлення';
  static const _channelDesc = 'Щоденні сповіщення про погоду';

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    debugPrint('NotificationService: initialized');
  }

  static void _onNotificationTap(NotificationResponse response) {
    // App will open automatically on tap — no extra handling needed
    debugPrint('NotificationService: tapped id=${response.id}');
  }

  // ── Request permission (Android 13+) ──────────────────────────────────────

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  // ── Show weather notification ─────────────────────────────────────────────

  /// Shows a weather update notification.
  /// [city] - city name
  /// [temp] - temperature string (e.g. "18°C")
  /// [condition] - weather condition (e.g. "Хмарно")
  /// [emoji] - weather emoji for the title
  static Future<void> showWeatherNotification({
    required String city,
    required String temp,
    required String condition,
    required String emoji,
    String lang = 'uk',
    int id = 0,
  }) async {
    if (!_initialized) await init();

    final title = '$emoji $city — $temp';
    final body = lang == 'uk'
        ? '$condition · Торкніться щоб відкрити додаток'
        : '$condition · Tap to open the app';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3D7FFF),
      playSound: false,
      enableVibration: false,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  static Future<void> cancelAll() => _plugin.cancelAll();
}

/// Returns the best emoji for the given OWM weather condition code.
String weatherEmoji(int? conditionCode) {
  if (conditionCode == null) return '🌤️';
  if (conditionCode < 300) return '⛈️';  // Thunderstorm
  if (conditionCode < 400) return '🌧️';  // Drizzle
  if (conditionCode < 600) return '🌧️';  // Rain
  if (conditionCode < 700) return '❄️';  // Snow
  if (conditionCode < 800) return '🌫️';  // Atmosphere
  if (conditionCode == 800) return '☀️'; // Clear
  if (conditionCode <= 802) return '⛅';  // Few/scattered clouds
  return '☁️';                            // Broken/overcast clouds
}
