# Ukraine Weather App 🌤️

A beautiful, modern weather application built with Flutter, featuring a stunning **Glassmorphism** UI design. 

## Features 🚀
- **Modern Glassmorphism UI**: Beautiful gradients and blurred glass cards.
- **Real-time Weather**: Powered by OpenWeatherMap API.
- **Hourly Forecast**: Interactive temperature trends chart (`fl_chart`).
- **5-Day Forecast**: Grouped daily min/max temperatures with conditions.
- **Multi-City Support**: Add and save multiple cities (persisted via `shared_preferences`).
- **Localization**: Supports **Ukrainian** and **English** languages.
- **Units Toggle**: Switch between **Celsius (°C)** and **Fahrenheit (°F)** effortlessly.

## Screenshots 📸

*(Add screenshots of your emulator here!)*

| Main Screen | Settings |
| ----------- | -------- |
| ![Main Screen](https://via.placeholder.com/250x500.png?text=Main+Screen) | ![Settings](https://via.placeholder.com/250x500.png?text=Settings) |

## Tech Stack 🛠️
- **Flutter** & **Dart**
- **HTTP**: `http` package for REST API communication.
- **Charts**: `fl_chart` for hourly temperature visualization.
- **Persistence**: `shared_preferences` for saving user cities.
- **Localization**: `intl` for date formatting.

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd weather_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up API Key:**
   Get an API key from [OpenWeatherMap](https://openweathermap.org/api) and run the app with the Dart define flag:
   ```bash
   flutter run --dart-define=OWM_API_KEY=your_api_key_here
   ```
   *Note: By default, the app uses a fallback API key for demonstration purposes.*

4. **Run the app:**
   ```bash
   flutter run
   ```

## Design Inspiration
The design relies on a dark thematic gradient `LinearGradient(colors: [Color(0xFF0D0B2E), Color(0xFF2A1549), Color(0xFF0F0F1A)])` overlaid with `BackdropFilter` (Image blur) to create a premium frosty glass effect.

## License
MIT License
