import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan_dart/adhan_dart.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Islam Azan Desktop',
      appUserModelId: 'com.ahad.islam_azan_desktop',
      guid: 'd7b1e8c2-4f3a-4e9b-9c1d-2a5f6b7c8d9e',
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      windows: windowsSettings,
      linux: linuxSettings,
      macOS: macOSSettings,
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    // Cancel previous notifications
    await _notifications.cancelAll();

    final prayers = {
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };

    int id = 0;
    final now = DateTime.now();

    for (final entry in prayers.entries) {
      final prayerTime = entry.value;

      if (prayerTime.isAfter(now)) {
        final scheduledTime = tz.TZDateTime.from(prayerTime, tz.local);

        await _notifications.zonedSchedule(
          id++,
          '${entry.key} Azan',
          'It is time for ${entry.key} prayer. May Allah accept it.',
          scheduledTime,
          const NotificationDetails(
            windows: WindowsNotificationDetails(),
            linux: LinuxNotificationDetails(
              urgency: LinuxNotificationUrgency.normal,
            ),
            macOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
            android: AndroidNotificationDetails(
              'prayer_channel',
              'Prayer Times',
              channelDescription: 'Notifications for Islamic prayer times',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Azan Notification',
      'Notifications are working correctly!',
      const NotificationDetails(
        windows: WindowsNotificationDetails(),
        linux: LinuxNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }
}
