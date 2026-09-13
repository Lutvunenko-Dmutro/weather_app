import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:flutter/services.dart';

class WeatherSoundService {
  static AudioPlayer? _audioPlayer;
  static WeatherType? _currentWeatherType;

  static Future<void> playSoundForWeather(WeatherType type) async {
    if (_currentWeatherType == type) return; // Already playing this sound
    _currentWeatherType = type;

    await stopSound();

    String? soundAsset;

    // Map weather types to sound files
    switch (type) {
      case WeatherType.heavyRainy:
      case WeatherType.middleRainy:
      case WeatherType.lightRainy:
        soundAsset = 'sounds/rain.mp3';
        break;
      case WeatherType.thunder:
        soundAsset = 'sounds/thunder.mp3';
        break;
      case WeatherType.sunny:
      case WeatherType.sunnyNight:
        soundAsset = 'sounds/birds.mp3';
        break;
      case WeatherType.heavySnow:
      case WeatherType.middleSnow:
      case WeatherType.lightSnow:
        soundAsset = 'sounds/snow_wind.mp3';
        break;
      case WeatherType.cloudy:
      case WeatherType.cloudyNight:
      case WeatherType.overcast:
        soundAsset = 'sounds/wind.mp3';
        break;
      default:
        soundAsset = null;
    }

    if (soundAsset != null) {
      try {
        // Check if the file has actual content (not a dummy placeholder)
        final data = await rootBundle.load('assets/$soundAsset');
        if (data.lengthInBytes < 100) {
          // Skip tiny/empty placeholder files silently
          return;
        }

        _audioPlayer ??= AudioPlayer();
        await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer!.play(AssetSource(soundAsset));
      } catch (_) {
        // Silently fail if plugin not available yet (needs full rebuild)
        // or if file is missing/invalid.
      }
    }
  }

  static Future<void> stopSound() async {
    try {
      await _audioPlayer?.stop();
    } catch (_) {
      // Silently ignore errors (e.g., MissingPluginException on first run)
    }
  }

  static Future<void> dispose() async {
    await stopSound();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
    _currentWeatherType = null;
  }
}
