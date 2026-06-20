# 🌿 PlantTree

[![Flutter](https://img.shields.io/badge/Flutter-3.38.8-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.7-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-brightgreen?logo=android)](https://developer.android.com)

**PlantTree** is an AI-powered Flutter mobile application that helps farmers and gardeners identify plant diseases from leaf images, receive expert treatment recommendations, and get real-time weather-based spraying advice — all in English or Bangla.

---

## 📋 Table of Contents

- [Features](#-features)
- [App Screens](#-app-screens)
- [Flutter & Environment](#-flutter--environment)
- [Getting Started](#-getting-started)
- [Environment Variables (API Key Setup)](#-environment-variables-api-key-setup)
- [Project Structure](#-project-structure)
- [Localization](#-localization-englishbangla)
- [Weather Integration](#-weather-integration)
- [Disease Detection Model](#-disease-detection-model)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🔬 AI Plant Disease Detection
- Capture a leaf image directly from the **camera** or pick from the **gallery**.
- Choose the **crop type** (Apple, Tomato, Corn, Grape, Peach, Pepper, Strawberry) from a dropdown.
- The app runs the selected image through an on-device **TensorFlow Lite (TFLite)** model to classify the leaf.
- Supports **38 disease classes** + a Background/Unknown class.
- Detection results include:
  - **Disease name** (translated in selected language)
  - **Confidence score** with a visual indicator
  - **Severity level** (High / Moderate / None)
  - **Symptoms description**
  - **Step-by-step management/prevention guide**

### 🌦️ Real-Time Weather & Spraying Advice
- Requests device **GPS location** to fetch current weather from OpenWeather API.
- Displays **temperature**, **weather condition**, and **wind speed**.
- Automatically calculates **spraying conditions**:
  - ✅ **Excellent** — calm, dry weather
  - ⚠️ **Moderate** — slightly windy (8–15 km/h)
  - ❌ **Poor (Rain)** — active rain/drizzle/thunderstorm
  - ❌ **Poor (Windy)** — wind speed above 15 km/h
- One-tap **location refresh** icon in the Home app bar to re-fetch weather.
- **Shimmer skeleton** shown while weather loads.
- **No-internet banner** displayed when the device is offline.

### 💊 Interactive Spray Guide
- Bottom-sheet dialog with crop selection and **growth stage** (Seedling, Flowering, Fruiting/Harvest).
- Generates a specific **spray recommendation** for the selected crop and stage.
- Includes a **Verify Safety** button that checks real-time weather before recommending spraying.

### 🌱 Fertilizer Calculator
- Select **target crop** and **fertilizer type** (NPK 10-10-10, Urea, Organic Compost).
- Enter the **garden area size** and get a **calculated dosage**.
- Provides a full **application guide** for each fertilizer type.

### 📚 Explore Crops
- Browse all supported crops with a **search bar**.
- Each crop card expands to show:
  - **Planting guide**: soil type, watering needs, sunlight, temperature range
  - **Common diseases & diagnosis**: symptoms and management guide for each disease

### 🌐 Bilingual Support (English & Bangla)
- Full app UI in **English** and **বাংলা (Bangla)**.
- Language selection via a **bottom-sheet** in Settings.
- **Instantly switches** all text including disease names, guides, and alerts.
- Selected language is **persisted** using `SharedPreferences`.

### 🎨 Modern UI & UX
- **Glassmorphism** cards and blurred backgrounds throughout the app.
- **Shimmer loading** skeletons for weather and content placeholders.
- **Smooth animated transitions** between screens.
- **Custom splash screen** featuring the app logo from assets.
- **Onboarding flow** displayed only on first launch (three illustrated screens: Welcome, Scan, Notify).
- **Exit confirmation dialog** when the user presses back on root screens.
- Fully **responsive layout** adapting to different screen sizes.

### ⚙️ Settings & Diagnostics
- View **TFLite model status** (Loaded / Standby / Demo Mode).
- See **model metadata**: input shape, output classes, mean/std, threshold.
- Switch **app language** from Settings.

---

## 📱 App Screens

| Screen | Description |
|---|---|
| **Splash** | Animated logo screen shown on launch |
| **Onboarding** | 3-step illustrated guide (first launch only) |
| **Home** | Weather card, spraying condition, quick-scan shortcut, tools |
| **Scan** | Camera/gallery image picker + crop selector + TFLite inference |
| **Results** | Disease name, confidence, severity, symptoms, prevention steps |
| **Explore** | Searchable crop library with planting guides and disease info |
| **Settings** | Language switcher, model diagnostics |

---

## 🛠️ Flutter & Environment

This project was developed and tested with the following environment:

```
Flutter 3.38.8 • channel stable
https://github.com/flutter/flutter.git
Framework  • revision bd7a4a6b55 (2026-01-26 15:21:03 -0800)
Engine     • revision db373eb85a (2026-01-26 18:17:44.000Z)
Tools      • Dart 3.10.7 • DevTools 2.51.1
```

> ⚠️ Make sure your Flutter SDK matches **3.38.8** (stable channel) to avoid compatibility issues.

To check your version:
```bash
flutter --version
```

To switch to the exact version using FVM:
```bash
fvm install 3.38.8
fvm use 3.38.8
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** `3.38.8` (stable channel)
- **Dart** `3.10.7`
- **Android SDK** API level 21+ (Android 5.0 Lollipop or higher)
- **Git** with SSH access to GitHub
- A valid **OpenWeather API key** (stored in `.env` — see below)

### Clone the Repository

```bash
git clone git@github.com:SouravBarman001/PlantTree.git
cd PlantTree
```

### Install Dependencies

```bash
flutter pub get
```

### Run on Device / Emulator

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

---

## 🔐 Environment Variables (API Key Setup)

The OpenWeather API key is **not** committed to version control. You must create a `.env` file in the project root:

1. Create the file:
```bash
touch .env
```

2. Add your API key:
```env
OPENWEATHER_API_KEY=your_openweather_api_key_here
```

3. The `.env` file is already listed in `.gitignore` so it will **never be pushed** to GitHub.

> 🔑 Get a free API key at [openweathermap.org/api](https://openweathermap.org/api)

---

## 📁 Project Structure

```
plant_tree/
├── .env                          # API keys (NOT committed to git)
├── .gitignore
├── pubspec.yaml
├── assets/
│   ├── icon/
│   │   ├── app_icon.png          # Splash & launcher icon
│   │   ├── apple.png
│   │   ├── tomato.png
│   │   └── ...                   # Per-crop icons
│   ├── model.tflite              # TFLite plant disease model
│   ├── labels.txt                # 39 class labels
│   ├── data.json                 # Crop planting & disease data
│   ├── en.json                   # English translations
│   └── bn.json                   # Bangla translations
└── lib/
    ├── main.dart                 # App entry point (loads .env)
    ├── app/
    │   └── app.dart              # Root MaterialApp + theming
    ├── core/
    │   └── utils/
    │       ├── app_settings.dart
    │       ├── fonts.dart
    │       ├── locale_provider.dart   # Language state (Riverpod)
    │       ├── theme.dart
    │       └── weather_service.dart   # OpenWeather API client
    └── features/
        ├── splash/               # Splash screen
        ├── onboarding/           # 3-step onboarding flow
        └── disease_detection/
            ├── data/             # TFLite datasource, models, repository
            ├── domain/           # Entities, use cases, repository interfaces
            └── presentation/
                ├── providers/    # Riverpod state providers
                ├── screens/      # Home, Scan, Results
                └── widgets/      # Confidence indicator, severity badge, etc.
```

---

## 🌐 Localization (English/Bangla)

All UI strings live in JSON files under `assets/`:

| File | Language |
|---|---|
| `assets/en.json` | English |
| `assets/bn.json` | বাংলা (Bangla) |

The `localeProvider` (Riverpod `StateNotifier`) manages the active locale. To add a new language:
1. Create a new JSON file, e.g., `assets/hi.json`.
2. Add the asset path to `pubspec.yaml`.
3. Extend `localeProvider` to accept the new locale code.

---

## 🌦️ Weather Integration

| Detail | Value |
|---|---|
| API Provider | [OpenWeatherMap](https://openweathermap.org) — Current Weather Data |
| Endpoint | `GET /data/2.5/weather?lat={lat}&lon={lon}&appid={key}&units=metric` |
| Key Storage | `.env` file via `flutter_dotenv` |
| Permissions | `ACCESS_FINE_LOCATION` (Android) |
| Refresh | Tapping the 🔄 icon in the Home app bar |
| Offline State | Banner shown if no internet connectivity |

Wind speed thresholds for spraying:

| Wind (km/h) | Condition |
|---|---|
| < 8 | ✅ Excellent |
| 8 – 15 | ⚠️ Moderate |
| > 15 | ❌ Poor (Windy) |
| Rain/Drizzle | ❌ Poor (Rain) |

---

## 🤖 Disease Detection Model

| Detail | Value |
|---|---|
| Framework | TensorFlow Lite (`tflite_flutter ^0.12.1`) |
| Model file | `assets/model.tflite` |
| Input | 224 × 224 × 3 RGB image |
| Output | 39-class softmax vector |
| Inference | On-device (no internet needed) |
| Supported crops | Apple, Blueberry, Cherry, Corn, Grape, Orange, Peach, Pepper, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato |

---

## 🧪 Testing

```bash
flutter test
```

Widget tests are located in `test/widget_test.dart`.

---

## 🤝 Contributing

1. Fork this repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit with a clear message:
   ```bash
   git commit -m "Add: your feature description"
   ```
4. Push to your fork and open a **Pull Request**.

---

## 📄 License

This project is licensed under the **MIT License** — see the [`LICENSE`](LICENSE) file for details.

---

*Built with 💚 using Flutter & TensorFlow Lite. Happy farming!*
