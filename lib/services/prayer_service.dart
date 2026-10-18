import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerService {
  // Default values (user should change these in Settings)
  static const double defaultLat = 24.8607; // Karachi (placeholder)
  static const double defaultLng = 67.0011;
  static const String defaultTimezone = 'Asia/Karachi';

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'latitude': prefs.getDouble('latitude') ?? defaultLat,
      'longitude': prefs.getDouble('longitude') ?? defaultLng,
      'timezone': prefs.getString('timezone') ?? defaultTimezone,
      'method': prefs.getString('method') ?? 'karachi',
      'madhab': prefs.getString('madhab') ?? 'hanafi',
    };
  }

  Future<void> saveSettings({
    required double latitude,
    required double longitude,
    required String timezone,
    required String method,
    required String madhab,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    await prefs.setString('timezone', timezone);
    await prefs.setString('method', method);
    await prefs.setString('madhab', madhab);
  }

  CalculationParameters _getParams(String method, String madhab) {
    CalculationParameters params;

    switch (method.toLowerCase()) {
      case 'muslim_world_league':
        params = CalculationMethodParameters.muslimWorldLeague();
        break;
      case 'egyptian':
        params = CalculationMethodParameters.egyptian();
        break;
      case 'karachi':
        params = CalculationMethodParameters.karachi();
        break;
      case 'umm_al_qura':
        params = CalculationMethodParameters.ummAlQura();
        break;
      case 'dubai':
        params = CalculationMethodParameters.dubai();
        break;
      case 'qatar':
        params = CalculationMethodParameters.qatar();
        break;
      case 'kuwait':
        params = CalculationMethodParameters.kuwait();
        break;
      case 'moonsighting_committee':
        params = CalculationMethodParameters.moonsightingCommittee();
        break;
      case 'singapore':
        params = CalculationMethodParameters.singapore();
        break;
      case 'turkey':
        params = CalculationMethodParameters.turkiye();
        break;
      case 'tehran':
        params = CalculationMethodParameters.tehran();
        break;
      case 'north_america':
        params = CalculationMethodParameters.northAmerica();
        break;
      default:
        params = CalculationMethodParameters.karachi();
    }

    params.madhab = madhab.toLowerCase() == 'shafi' ? Madhab.shafi : Madhab.hanafi;
    return params;
  }

  Future<PrayerTimes> getTodayPrayerTimes() async {
    final settings = await getSettings();
    final lat = settings['latitude'] as double;
    final lng = settings['longitude'] as double;
    final timezone = settings['timezone'] as String;
    final method = settings['method'] as String;
    final madhab = settings['madhab'] as String;

    final location = tz.getLocation(timezone);
    final date = tz.TZDateTime.now(location);

    final coordinates = Coordinates(lat, lng);
    final params = _getParams(method, madhab);

    return PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
    );
  }

  Map<String, DateTime> getPrayerMap(PrayerTimes times) {
    return {
      'Fajr': times.fajr,
      'Sunrise': times.sunrise,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };
  }

  String? getNextPrayerName(PrayerTimes times) {
    final now = DateTime.now();
    final map = getPrayerMap(times);

    for (final entry in map.entries) {
      if (entry.key == 'Sunrise') continue; // skip sunrise for next prayer
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }
    return 'Fajr'; // next day
  }

  DateTime? getNextPrayerTime(PrayerTimes times) {
    final now = DateTime.now();
    final map = getPrayerMap(times);

    for (final entry in map.entries) {
      if (entry.key == 'Sunrise') continue;
      if (entry.value.isAfter(now)) {
        return entry.value;
      }
    }
    // Return tomorrow's Fajr approximately
    return times.fajr.add(const Duration(days: 1));
  }
}
