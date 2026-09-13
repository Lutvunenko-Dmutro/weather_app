<div align="center">

# 🌦️ Ukraine Weather App

**A stunning, modern weather application built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://www.android.com)

🌐 [Українська версія →](README.md)

</div>

---

## ✨ Features

### 🎨 Visual Experience
- **Glassmorphism UI** — Stunning frosted-glass cards, blurred backgrounds, and premium dark gradients.
- **Dynamic Weather Backgrounds** — The app's background automatically reflects real weather conditions: clear blue skies for sunny days, dark stormy gradients for rain, white-grey palettes for snow.
- **Animated Particles** — Smooth, canvas-drawn rain, snow, and lightning particle effects that match the weather of your currently selected city.
- **Moving Clouds** — Layered, parallax-style animated cloud overlays.

### ⚙️ Customizable Effects
Choose different visual styles for each weather condition in the **Settings → Weather Effects** section:

| Weather | Option 1 | Option 2 |
|---------|----------|----------|
| ☀️ Sun | Classic | Lens Flare |
| 🌧️ Rain | Realistic | Matrix (Digital) |
| ❄️ Snow | Light Snowflakes | Blizzard |
| ☁️ Clouds | Slow Drift | Fast Wind |

> 🔍 **Live Preview** — Every button shows a real animated mini-preview of the effect. The selected button stays animated while others are paused. The full-screen background also instantly previews your choice while you're in Settings!

### 🌍 Weather Data
- **Real-time weather** powered by [OpenWeatherMap API](https://openweathermap.org/api)
- **Hourly Forecast** — Interactive temperature trend chart (`fl_chart`)
- **5-Day Forecast** — Daily min/max temperatures with condition icons
- **Multi-City Support** — Add and manage multiple cities, all persisted locally

### 🛠️ User Settings
- 🌐 **Bilingual**: Ukrainian & English
- 🌡️ **Units**: Switch between °C and °F
- 💾 **Persistent**: All settings and city lists are saved between sessions

---

## 📸 Screenshots

> *(GIFs and screenshots of the animated weather effects are coming soon!)*

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter / Dart |
| API | OpenWeatherMap REST API (`http`) |
| Charts | `fl_chart` |
| Persistence | `shared_preferences` |
| Date Formatting | `intl` |
| Sound | `audioplayers` |
| Animations | Custom `Canvas` / `AnimationController` |

---

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone <repository_url>
cd weather_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure API Key
Get a free API key from [OpenWeatherMap](https://openweathermap.org/api) and run:
```bash
flutter run --dart-define=OWM_API_KEY=your_api_key_here
```
> **Note:** A fallback demo key is included for quick testing.

### 4. Run on your device
```bash
flutter run
```

---

## 🏗️ Architecture

```
lib/
├── models/          # Data models (WeatherModel, ForecastItem)
├── screens/         # Full-screen views (HomeScreen, SettingsView)
├── services/        # API, Location, Sound, Preferences
└── widgets/         # Reusable components
    ├── background_gradient.dart        # Dynamic weather background
    ├── weather_particles_overlay.dart  # Rain / Snow / Thunder canvas
    ├── moving_clouds_overlay.dart      # Animated cloud layers
    ├── weather_card.dart               # City weather card
    ├── temperature_chart.dart          # Hourly chart
    └── ...
```

---

## 📄 License

This project is licensed under the **MIT License**.

---

<div align="center">
Made with ❤️ and Flutter
</div>
