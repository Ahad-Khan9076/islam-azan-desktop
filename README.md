# Islam Azan (Desktop + Mobile)

A clean Flutter **Azan (Adhan) reminder app** that works on:

- **Desktop** → Windows, macOS, Linux
- **Mobile** → Android & iOS

It calculates accurate Islamic prayer times offline and shows notifications when it's time to pray.

## Features

- Accurate prayer times using `adhan_dart` (Karachi method + Hanafi by default)
- Works fully offline after setup
- Local notifications on all platforms
- Save your location (latitude, longitude, timezone)
- Next prayer countdown
- Simple and modern Material 3 UI
- Works on both mobile and desktop from the same codebase

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

### 3. Generate platform folders (important)
```bash
flutter create --platforms=android,ios,windows,macos,linux .
```

### 4. Run the app

**Mobile:**
```bash
flutter run -d android
# or
flutter run -d ios
```

**Desktop:**
```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## First Time Setup

1. Open the app
2. Go to **Settings**
3. Enter your **Latitude**, **Longitude** and **Timezone**
   - Example for Karachi: `24.8607`, `67.0011`, `Asia/Karachi`
4. Choose calculation method and madhab if needed
5. Save

You can find coordinates of any city on Google Maps or https://www.latlong.net

## Android Notes

- On Android 13+ the app will request notification permission automatically.
- For exact prayer time alarms on Android 12+, the app requests the necessary permissions.

## iOS Notes

- The app will ask for notification permission the first time.
- Make sure you allow notifications for the best experience.

## Default Settings

- Calculation Method: Karachi
- Madhab: Hanafi
- Timezone: Asia/Karachi (change it in settings)

## Packages Used

- `adhan_dart` → Prayer time calculation
- `flutter_local_notifications` → Notifications (all platforms)
- `timezone` → Correct timezone handling
- `shared_preferences` → Save user settings
- `permission_handler` → Request notification permissions on mobile
- `intl` → Time formatting

## License

MIT
