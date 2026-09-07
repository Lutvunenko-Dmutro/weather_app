# Flutter Mini-Apps Collection 📱

[🇺🇦 Українська](#українська-версія) | [🇺🇸 English](#english-version)

---

## <a id="українська-версія"></a>🇺🇦 Українська версія

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)

### Огляд
Цей репозиторій містить колекцію кросплатформних міні-додатків, розроблених за допомогою **Flutter** та **Dart**. Проєкти демонструють навички роботи з UI/UX, управлінням станом (state management) та взаємодією з API. Усі додатки можуть компілюватися під Windows, Android, iOS та Web.

### Проєкти в колекції

1. ☀️ **Weather App** (`/weather_app`)
   - Додаток для перегляду погоди.
   - Демонструє роботу з REST API (отримання погодних даних у реальному часі) та обробку JSON.

2. 🎬 **Cinema Go** (`/cinema_go`)
   - Додаток для перегляду афіші кіно та фільмів.
   - Демонструє роботу зі списками (ListView/GridView), навігацією та побудовою чистого інтерфейсу.

3. 📏 **Metrics Converter** (`/km_miles_converter`)
   - Утиліта для швидкої конвертації метричних систем (кілометри в милі тощо).
   - Показує роботу з формами, введенням користувача та миттєвим оновленням стану.

### Запуск локально
Для запуску будь-якого з додатків переконайтеся, що у вас встановлений [Flutter SDK](https://docs.flutter.dev/get-started/install).

```bash
# 1. Перейдіть у папку потрібного проєкту
cd weather_app

# 2. Отримайте залежності
flutter pub get

# 3. Запустіть додаток (наприклад, як нативну програму для Windows)
flutter run -d windows
```

---

## <a id="english-version"></a>🇺🇸 English Version

### Overview
This repository contains a collection of cross-platform mini-applications built with **Flutter** and **Dart**. These projects demonstrate core skills in UI/UX design, state management, and API integration. All applications can be compiled for Windows, Android, iOS, and Web environments.

### Projects Included

1. ☀️ **Weather App** (`/weather_app`)
   - A real-time weather forecasting application.
   - Showcases REST API integration and dynamic JSON parsing.

2. 🎬 **Cinema Go** (`/cinema_go`)
   - A movie discovery and browsing application.
   - Demonstrates list rendering (ListView/GridView), routing, and clean UI implementation.

3. 📏 **Metrics Converter** (`/km_miles_converter`)
   - A utility tool for converting between metric systems (e.g., kilometers to miles).
   - Showcases form handling, user input validation, and real-time state updates.

### Running Locally
To run any of these applications, ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

```bash
# 1. Navigate to the desired project folder
cd weather_app

# 2. Fetch dependencies
flutter pub get

# 3. Run the app (e.g., as a native Windows desktop app)
flutter run -d windows
```