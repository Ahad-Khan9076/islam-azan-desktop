# Islam Azan Desktop

A clean Flutter **desktop** Azan (Adhan) reminder app for Windows, macOS, and Linux.

It calculates accurate Islamic prayer times offline and shows desktop notifications when it's time to pray.

## Features

- Accurate prayer times using `adhan_dart` (Karachi method + Hanafi by default)
- Works fully offline after setup
- Local desktop notifications (Windows / macOS / Linux)
- Save your location (latitude, longitude, timezone)
- Simple and modern UI
- Next prayer countdown

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/Ahad-Khan9076/islam-azan-desktop.git
cd islam-azan-desktop
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Enable desktop support (if needed)
```bash
flutter create --platforms=windows,macos,linux .
```

### 4. Run the app
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## How to set your location

1. Open the **Settings** screen from the app
2. Enter your **Latitude** and **Longitude**
3. Choose your **Timezone** (example: `Asia/Karachi`)
4. Select calculation method and madhab if needed
5. Save

You can find coordinates of any city on Google Maps or https://www.latlong.net

## Default Settings

- Calculation Method: Karachi
- Madhab: Hanafi
- Timezone: Asia/Karachi (change it in settings)

## Packages Used

- `adhan_dart` → Prayer time calculation
- `flutter_local_notifications` → Desktop notifications
- `timezone` → Correct timezone handling
- `shared_preferences` → Save user settings
- `intl` → Time formatting

## License

MIT
