import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentLang;
  final List<String> cities;
  final Map<String, WeatherModel> citiesWeather;
  final VoidCallback onAddCity;
  final VoidCallback onMyLocation;
  final TabController? tabController;

  const MainAppBar({
    super.key,
    required this.currentLang,
    required this.cities,
    required this.citiesWeather,
    required this.onAddCity,
    required this.onMyLocation,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        currentLang == 'uk' ? 'Погода в Україні' : 'Ukraine Weather',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: 20,
          letterSpacing: 1.5,
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 1,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white30,
        labelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        tabs: cities.map((city) {
          final weather = citiesWeather[city];
          final displayName = weather?.translatedCity ?? city;
          return Tab(text: displayName);
        }).toList(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.my_location_rounded, color: Colors.white70),
          onPressed: onMyLocation,
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white38),
          onPressed: onAddCity,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48.0);
}
