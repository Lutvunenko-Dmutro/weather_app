import 'package:flutter/material.dart';
import '../../services/preferences_service.dart';
import '../../services/notification_service.dart';
import '../home_screen.dart';
import 'weather_data_mixin.dart';
import 'effects_mixin.dart';

/// Top-level mixin that composes WeatherDataMixin + EffectsMixin and adds
/// nav-bar / init logic. This is the only mixin HomeScreen needs to declare.
mixin HomeScreenLogic on State<HomeScreen>, TickerProviderStateMixin<HomeScreen>,
    WeatherDataMixin, EffectsMixin {
  int bottomNavIndex = 0;

  void onBottomNavTapped(int index) {
    setState(() {
      bottomNavIndex = index;
      if (index != 2) clearSettingsPreview();
    });
  }

  Future<void> initLogic() async {
    await PreferencesService.init(); // singleton init — runs once
    loadVariants();                  // now sync
    loadSavedCities();               // sync read from prefs singleton
    initTabController();
    await loadAll();
  }
}
