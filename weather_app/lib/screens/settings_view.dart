import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import '../widgets/background_gradient.dart';
import '../models/weather_model.dart';

class SettingsView extends StatelessWidget {
  final String currentLang;
  final bool isCelsius;
  final int sunVariant;
  final int rainVariant;
  final int snowVariant;
  final int cloudVariant;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onUnitChanged;
  final Function(String, int) onVariantChanged;

  const SettingsView({
    super.key,
    required this.currentLang,
    required this.isCelsius,
    required this.sunVariant,
    required this.rainVariant,
    required this.snowVariant,
    required this.cloudVariant,
    required this.onLanguageChanged,
    required this.onUnitChanged,
    required this.onVariantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              currentLang == 'uk' ? 'Налаштування' : 'Settings',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildGlassCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentLang == 'uk' ? 'Мова' : 'Language',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        _buildToggle(
                          option1: 'Укр',
                          option2: 'Eng',
                          isSelected1: currentLang == 'uk',
                          onTap1: () => onLanguageChanged('uk'),
                          onTap2: () => onLanguageChanged('en'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentLang == 'uk' ? 'Одиниці виміру' : 'Temperature Unit',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        _buildToggle(
                          option1: '°C',
                          option2: '°F',
                          isSelected1: isCelsius,
                          onTap1: () => onUnitChanged(true),
                          onTap2: () => onUnitChanged(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              currentLang == 'uk' ? 'Ефекти погоди' : 'Weather Effects',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentLang == 'uk'
                  ? 'Оберіть стиль анімацій для кожного типу погоди.'
                  : 'Select animation style for each weather type.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildVariantSection(
                      title: currentLang == 'uk' ? 'Сонце' : 'Sun',
                      icon: Icons.wb_sunny_rounded,
                      type: 'sun',
                      currentVariant: sunVariant,
                      options: currentLang == 'uk' 
                          ? ['Класичне', 'З відблисками (Lens Flare)'] 
                          : ['Classic', 'Lens Flare'],
                    ),
                    const SizedBox(height: 16),
                    _buildVariantSection(
                      title: currentLang == 'uk' ? 'Хмари' : 'Clouds',
                      icon: Icons.cloud_rounded,
                      type: 'cloud',
                      currentVariant: cloudVariant,
                      options: currentLang == 'uk'
                          ? ['Повільні', 'Швидкі']
                          : ['Slow', 'Fast'],
                    ),
                    const SizedBox(height: 16),
                    _buildVariantSection(
                      title: currentLang == 'uk' ? 'Дощ' : 'Rain',
                      icon: Icons.water_drop_rounded,
                      type: 'rain',
                      currentVariant: rainVariant,
                      options: currentLang == 'uk'
                          ? ['Реалістичний', 'Матриця (Цифровий)']
                          : ['Realistic', 'Matrix (Digital)'],
                    ),
                    const SizedBox(height: 16),
                    _buildVariantSection(
                      title: currentLang == 'uk' ? 'Сніг' : 'Snow',
                      icon: Icons.ac_unit_rounded,
                      type: 'snow',
                      currentVariant: snowVariant,
                      options: currentLang == 'uk'
                          ? ['Легкий сніжок', 'Хуртовина']
                          : ['Light Snow', 'Blizzard'],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildVariantSection({
    required String title,
    required IconData icon,
    required String type,
    required int currentVariant,
    required List<String> options,
  }) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(options.length, (index) {
                final isSelected = currentVariant == index;
                
                WeatherType bgWeatherType = WeatherType.sunny;
                int sunVar = 0, rainVar = 0, snowVar = 0, cloudVar = 0;
                
                if (type == 'sun') {
                  bgWeatherType = WeatherType.sunny;
                  sunVar = index;
                } else if (type == 'cloud') {
                  bgWeatherType = WeatherType.cloudy;
                  cloudVar = index;
                } else if (type == 'rain') {
                  bgWeatherType = WeatherType.heavyRainy;
                  rainVar = index;
                } else if (type == 'snow') {
                  bgWeatherType = WeatherType.heavySnow;
                  snowVar = index;
                }

                Widget button = GestureDetector(
                  onTap: () => onVariantChanged(type, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blueAccent : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected 
                        ? [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 10)]
                        : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackgroundGradient(
                        weatherType: bgWeatherType,
                        sunVariant: sunVar,
                        rainVariant: rainVar,
                        snowVariant: snowVar,
                        cloudVariant: cloudVar,
                        isPaused: !isSelected,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            options[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < options.length - 1 ? 12.0 : 0),
                    child: button,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required String option1,
    required String option2,
    required bool isSelected1,
    required VoidCallback onTap1,
    required VoidCallback onTap2,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected1 ? Colors.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                option1,
                style: TextStyle(
                  color: isSelected1 ? Colors.white : Colors.white70,
                  fontWeight: isSelected1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !isSelected1 ? Colors.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                option2,
                style: TextStyle(
                  color: !isSelected1 ? Colors.white : Colors.white70,
                  fontWeight: !isSelected1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
