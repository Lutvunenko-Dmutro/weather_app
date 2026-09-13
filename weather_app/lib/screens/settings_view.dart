import 'package:flutter/material.dart';
import '../widgets/settings/settings_glass_card.dart';
import '../widgets/settings/weather_variant_section.dart';

/// Full-screen Settings view. Delegates all visual sub-components to dedicated
/// widgets to keep this file focused solely on layout and data wiring.
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

  // ── l10n helpers ────────────────────────────────────────────────────────
  String _t(String uk, String en) => currentLang == 'uk' ? uk : en;

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
              _t('Налаштування', 'Settings'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // ── General preferences ──────────────────────────────────────
            SettingsGlassCard(
              child: Column(
                children: [
                  _SettingsRow(
                    label: _t('Мова', 'Language'),
                    trailing: SettingsToggle(
                      option1: 'Укр',
                      option2: 'Eng',
                      isSelected1: currentLang == 'uk',
                      onTap1: () => onLanguageChanged('uk'),
                      onTap2: () => onLanguageChanged('en'),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _SettingsRow(
                    label: _t('Одиниці виміру', 'Temperature Unit'),
                    trailing: SettingsToggle(
                      option1: '°C',
                      option2: '°F',
                      isSelected1: isCelsius,
                      onTap1: () => onUnitChanged(true),
                      onTap2: () => onUnitChanged(false),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text(
              _t('Ефекти погоди', 'Weather Effects'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                'Оберіть стиль анімацій для кожного типу погоди.',
                'Select animation style for each weather type.',
              ),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // ── Effect variant sections ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    WeatherVariantSection(
                      title: _t('Сонце', 'Sun'),
                      icon: Icons.wb_sunny_rounded,
                      type: 'sun',
                      currentVariant: sunVariant,
                      options: [_t('Класичне', 'Classic'), _t('З відблисками (Lens Flare)', 'Lens Flare')],
                      onVariantChanged: onVariantChanged,
                    ),
                    const SizedBox(height: 16),
                    WeatherVariantSection(
                      title: _t('Хмари', 'Clouds'),
                      icon: Icons.cloud_rounded,
                      type: 'cloud',
                      currentVariant: cloudVariant,
                      options: [_t('Повільні', 'Slow'), _t('Швидкі', 'Fast')],
                      onVariantChanged: onVariantChanged,
                    ),
                    const SizedBox(height: 16),
                    WeatherVariantSection(
                      title: _t('Дощ', 'Rain'),
                      icon: Icons.water_drop_rounded,
                      type: 'rain',
                      currentVariant: rainVariant,
                      options: [_t('Реалістичний', 'Realistic'), _t('Матриця (Цифровий)', 'Matrix (Digital)')],
                      onVariantChanged: onVariantChanged,
                    ),
                    const SizedBox(height: 16),
                    WeatherVariantSection(
                      title: _t('Сніг', 'Snow'),
                      icon: Icons.ac_unit_rounded,
                      type: 'snow',
                      currentVariant: snowVariant,
                      options: [_t('Легкий сніжок', 'Light Snow'), _t('Хуртовина', 'Blizzard')],
                      onVariantChanged: onVariantChanged,
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
}

/// A simple row used inside the general-preferences glass card.
class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingsRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          trailing,
        ],
      ),
    );
  }
}
