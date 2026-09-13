<div align="center">

# 🌦️ Ukraine Weather App

**Сучасний погодний додаток на Flutter з мальовничим Glassmorphism дизайном**

**A stunning, modern weather application built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://www.android.com)

</div>

---

<!-- UA -->
<details open>
<summary><b>🇺🇦 Українська</b></summary>

## ✨ Можливості

### 🎨 Візуальне оформлення
- **Glassmorphism UI** — Матові скляні картки, розмитий фон і преміальні темні градієнти.
- **Динамічний фон** — Фон автоматично відповідає реальній погоді: блакитне небо в ясну погоду, темні хмари при дощі, сірувато-білий при снігу.
- **Анімовані частинки** — Плавний, намальований на Canvas дощ, сніг і блискавки, що відображають погоду вашого міста.
- **Рухомі хмари** — Багатошарові анімовані хмари з паралакс-ефектом.

### ⚙️ Налаштовувані ефекти
У розділі **Налаштування → Ефекти погоди** оберіть стиль для кожного типу погоди:

| Погода | Варіант 1 | Варіант 2 |
|--------|-----------|-----------|
| ☀️ Сонце | Класичне | З відблисками (Lens Flare) |
| 🌧️ Дощ | Реалістичний | Матриця (Цифровий) |
| ❄️ Сніг | Легкий сніжок | Хуртовина |
| ☁️ Хмари | Повільні | Швидкі |

> 🔍 **Живий попередній перегляд** — Кожна кнопка вибору є мініатюрним анімованим екраном із реальним ефектом. Обраний варіант анімується, а фон всього екрана одразу змінюється, коли ви у Налаштуваннях.

### 🌍 Погодні дані
- Погода в реальному часі від [OpenWeatherMap API](https://openweathermap.org/api)
- **Погодинний прогноз** — Інтерактивний графік температур (`fl_chart`)
- **Прогноз на 5 днів** — Мін/макс температури з іконками умов
- **Кілька міст** — Додавайте та зберігайте скільки завгодно міст

### 🛠️ Налаштування
- 🌐 **Двомовність**: Українська та Англійська
- 🌡️ **Одиниці**: °C та °F
- 💾 **Збереження**: Всі налаштування та список міст зберігаються між сесіями

</details>

---

<!-- EN -->
<details>
<summary><b>🇬🇧 English</b></summary>

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

</details>

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
