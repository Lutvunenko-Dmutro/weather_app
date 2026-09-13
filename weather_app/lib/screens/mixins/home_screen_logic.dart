import 'package:flutter/material.dart';
import '../home_screen.dart';
import 'weather_data_mixin.dart';
import 'effects_mixin.dart';

/// Top-level mixin that composes WeatherDataMixin + EffectsMixin and adds
/// nav-bar / init logic. This is the only mixin HomeScreen needs to declare.
mixin HomeScreenLogic on State<HomeScreen>, TickerProviderStateMixin<HomeScreen>,
    WeatherDataMixin, EffectsMixin {
  int bottomNavIndex = 0;

  void onBottomNavTapped(int index) {
    if (index == 0 || index == 2) {
      setState(() {
        bottomNavIndex = index;
        if (index != 2) clearSettingsPreview();
      });
    } else if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentLang == 'uk'
                ? 'Немає активних штормових попереджень ☀️'
                : 'No active storm warnings ☀️',
          ),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> initLogic() async {
    await loadVariants();
    await loadSavedCities();
    initTabController();
    await loadAll();
  }
}
