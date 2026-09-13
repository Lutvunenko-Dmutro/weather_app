import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import '../../services/preferences_service.dart';
import '../home_screen.dart';

/// Manages weather effect variant preferences and the settings preview state.
mixin EffectsMixin on State<HomeScreen> {
  int sunVariant = 0;
  int rainVariant = 0;
  int snowVariant = 0;
  int cloudVariant = 0;

  WeatherType? settingsPreviewWeatherType;

  Future<void> loadVariants() async {
    sunVariant = await PreferencesService.loadVariant('sun');
    rainVariant = await PreferencesService.loadVariant('rain');
    snowVariant = await PreferencesService.loadVariant('snow');
    cloudVariant = await PreferencesService.loadVariant('cloud');
  }

  void updateVariant(String type, int variant) {
    setState(() {
      switch (type) {
        case 'sun':
          sunVariant = variant;
          settingsPreviewWeatherType = WeatherType.sunny;
          break;
        case 'rain':
          rainVariant = variant;
          settingsPreviewWeatherType = WeatherType.heavyRainy;
          break;
        case 'snow':
          snowVariant = variant;
          settingsPreviewWeatherType = WeatherType.heavySnow;
          break;
        case 'cloud':
          cloudVariant = variant;
          settingsPreviewWeatherType = WeatherType.cloudy;
          break;
      }
    });
    PreferencesService.saveVariant(type, variant);
  }

  void clearSettingsPreview() {
    settingsPreviewWeatherType = null;
  }
}
