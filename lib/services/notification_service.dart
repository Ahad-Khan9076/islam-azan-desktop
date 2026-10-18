import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan_dart/adhan_dart.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Islam Azan',
      appUserModelId: 'com.ahad.islam_azan',
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

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      windows: windowsSettings,
      linux: linuxSettings,
      macOS: macOSSettings,
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Request permissions on mobile
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      // Android 13+ notification permission
      final status = await Permission.notification.request();
      if (status.isDenied) {
        debugPrint('Notification permission denied');
      }

      // Exact alarms permission (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await _notifications
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
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
          NotificationDetails(
            windows: const WindowsNotificationDetails(),
            linux: const LinuxNotificationDetails(
              urgency: LinuxNotificationUrgency.normal,
            ),
            macOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
            iOS: const DarwinNotificationDetails(
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
              playSound: true,
              enableVibration: true,
              category: AndroidNotificationCategory.alarm,
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
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
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
    );
  }
}
