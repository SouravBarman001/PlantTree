# PlantTree 🌳

[![Flutter](https://img.shields.io/badge/Flutter-≥3.19.0-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Flutter SDK Version](#flutter-sdk-version)
- [Installation & Build](#installation--build)
- [Localization (English/Bangla)](#localization-englishbangla)
- [Weather Integration](#weather-integration)
- [Asset Organization](#asset-organization)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

---

## Project Overview
**PlantTree** is a Flutter mobile application that helps farmers and gardeners identify plant diseases from leaf images, provides treatment recommendations, and shows localized weather information. The app supports both English and Bangla languages, offers a smooth and responsive UI with modern glass‑morphism effects, and works offline with cached models.

---

## Features
| Feature | Description |
| --- | --- |
| **Disease Classification** | Capture or select a leaf image, choose a plant type, and get disease prediction using a TensorFlow Lite model. |
| **Treatment Guide** | Auto‑generated step‑by‑step guidance for detected disease. |
| **Weather Info** | Fetches current weather for the device location via OpenWeather API (API key provided). |
| **Localization** | Switch between English and Bangla instantly from Settings (bottom‑sheet). |
| **Responsive UI** | Glass‑morphism cards, shimmer loading skeletons, and adaptive layouts for all screen sizes. |
| **On‑boarding** | Shown only on the first launch using `SharedPreferences`. |
| **Exit Confirmation** | Handles back‑button presses with a custom dialog. |
| **Asset‑Driven UI** | All static strings, icons, and images are stored in assets for easy updates. |

---

## Screenshots
*(Replace the placeholders with real screenshots generated via `generate_image` if desired.)*

![Home Screen](assets/screenshots/home.png)
![Scan Screen](assets/screenshots/scan.png)
![Settings (Language Switch)](assets/screenshots/settings_language.png)

---

## Getting Started
### Prerequisites
- **Flutter SDK** version **3.19.0** or higher.
- **Android SDK** (API 21+ recommended).
- A valid **OpenWeather API key** (provided in the code: `a33e9ca69869689066f9a776a3622a24`).
- **Git** installed and configured with SSH access to the remote repository.

### Clone the Repository
```bash
git clone git@github.com:SouravBarman001/PlantTree.git
cd PlantTree
```

---

## Flutter SDK Version
The project was created with Flutter **3.19.0**. Ensure your environment matches:
```bash
flutter --version
# Expected output: Flutter 3.19.0 • channel stable
```
If you need to upgrade:
```bash
flutter upgrade
```

---

## Installation & Build
1. **Install dependencies**
```bash
flutter pub get
```
2. **Run the app** on a connected device or emulator:
```bash
flutter run
```
3. **Build APK** (optional)
```bash
flutter build apk --release
```

---

## Localization (English/Bangla)
- JSON files are located in `assets/en.json` and `assets/bn.json`.
- The app uses a Riverpod `localeProvider` to switch languages at runtime.
- The selected language is persisted using `SharedPreferences`.

---

## Weather Integration
- Location permission is requested at runtime (`ACCESS_FINE_LOCATION`).
- Weather data is fetched from **OpenWeather** using the API key `a33e9ca69869689066f9a776a3622a24`.
- UI updates automatically when the user taps the **location refresh** icon in the Home app bar.

---

## Asset Organization
```
plant_tree/
├─ assets/
│  ├─ icon/app_icon.png          # Splash & launcher icon
│  ├─ images/…                  # Plant pictures for classification
│  ├─ en.json                    # English key‑value strings
│  ├─ bn.json                    # Bangla translations
│  └─ screenshots/…            # Screenshots for README
├─ lib/
│  └─ … (source code)
└─ pubspec.yaml
```
Make sure to list all assets under the `flutter:` → `assets:` section in `pubspec.yaml`.

---

## Testing
Run the test suite to ensure UI components render correctly:
```bash
flutter test
```
All tests should pass without failures.

---

## Contributing
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes following the **five‑commit** convention described below.
4. Push to your fork and open a Pull Request.

---

## License
This project is licensed under the **MIT License** – see the `LICENSE` file for details.

---

*Feel free to open issues for bugs or feature requests. Happy coding!*
