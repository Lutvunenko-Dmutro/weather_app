import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import '../widgets/main_bottom_nav_bar.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/background_gradient.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/home_tab_view.dart';
import 'mixins/home_screen_logic.dart';
import 'mixins/weather_data_mixin.dart';
import 'mixins/effects_mixin.dart';
import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WeatherDataMixin, EffectsMixin, HomeScreenLogic {
  @override
  void initState() {
    super.initState();
    initLogic();
  }

  @override
  Widget build(BuildContext context) {
    WeatherType bgType = WeatherType.sunny;
    if (bottomNavIndex == 2 && settingsPreviewWeatherType != null) {
      bgType = settingsPreviewWeatherType!;
    } else if (cities.isNotEmpty && currentTabIndex < cities.length) {
      final currentCity = cities[currentTabIndex];
      if (citiesWeather.containsKey(currentCity)) {
        bgType = citiesWeather[currentCity]!.getWeatherBgType();
      }
    }

    return BackgroundGradient(
      weatherType: bgType,
      sunVariant: sunVariant,
      rainVariant: rainVariant,
      snowVariant: snowVariant,
      cloudVariant: cloudVariant,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: bottomNavIndex == 2 ? Size.zero : const Size.fromHeight(kToolbarHeight + 48.0),
          child: Offstage(
            offstage: bottomNavIndex == 2,
            child: MainAppBar(
              currentLang: currentLang,
              cities: cities,
              citiesWeather: citiesWeather,
              onAddCity: showAddCityDialogMenu,
              onMyLocation: addCurrentLocationCity,
              tabController: tabController,
            ),
          ),
        ),
        body: Stack(
          children: [
            Offstage(
              offstage: bottomNavIndex == 2,
              child: Stack(
                children: [
                  // ALWAYS keep HomeTabView in the tree to prevent unmount crashes
                  HomeTabView(
                    tabController: tabController,
                    cities: cities,
                    citiesWeather: citiesWeather,
                    citiesForecast: citiesForecast,
                    isCelsius: isCelsius,
                    currentLang: currentLang,
                    lastUpdated: lastUpdated,
                    onRefresh: loadAll,
                    onDeleteCity: (city) {
                      setState(() {
                        cities.remove(city);
                        citiesWeather.remove(city);
                        citiesForecast.remove(city);
                        initTabController();
                      });
                      saveCities();
                    },
                  ),
                  
                  // Show Loading Overlay
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: LoadingStateWidget(currentLang: currentLang),
                    ),
                    
                  // Show Error Overlay
                  if (!isLoading && errorMessage.isNotEmpty)
                    Container(
                      color: Colors.black.withValues(alpha: 0.8),
                      child: ErrorStateWidget(
                        errorMessage: errorMessage,
                        currentLang: currentLang,
                        onRetry: loadAll,
                      ),
                    ),
                ],
              ),
            ),
            if (bottomNavIndex == 2)
              SettingsView(
                currentLang: currentLang,
                isCelsius: isCelsius,
                sunVariant: sunVariant,
                rainVariant: rainVariant,
                snowVariant: snowVariant,
                cloudVariant: cloudVariant,
                onLanguageChanged: (val) {
                  setState(() => currentLang = val);
                  loadAll();
                },
                onUnitChanged: (val) {
                  setState(() => isCelsius = val);
                },
                onVariantChanged: (type, variant) {
                  updateVariant(type, variant);
                },
              ),
          ],
        ),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: bottomNavIndex,
          onTap: onBottomNavTapped,
          currentLang: currentLang,
        ),
      ),
    );
  }
}
