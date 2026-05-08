import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/caregiver_alert.dart';
import '../models/medication.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _setLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    await requestPermissions();
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleMedicationReminders({
    required String elderlyUserId,
    required List<Medication> medications,
  }) async {
    await initialize();

    for (final medication in medications) {
      if (medication.id.isEmpty) continue;

      for (final time in medication.scheduledTimes) {
        final scheduledTime = _nextDailyTime(time);
        if (scheduledTime == null) continue;

        final notificationId = _notificationId(
          elderlyUserId: elderlyUserId,
          medicationId: medication.id,
          time: time,
        );

        await _scheduleReminder(
          id: notificationId,
          medication: medication,
          scheduledTime: scheduledTime,
          time: time,
        );
      }
    }
  }

  Future<void> showCaregiverAlertNotification(CaregiverAlert alert) {
    return showInstantNotification(
      title: 'تنبيه مقدم الرعاية',
      body: alert.message,
      payload: 'alert:${alert.id}',
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    await _plugin.show(
      _instantNotificationId(title, body, payload),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'caregiver_alerts',
          'تنبيهات مقدم الرعاية',
          channelDescription: 'تنبيهات مهمة عند الحاجة إلى متابعة المسن',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> _scheduleReminder({
    required int id,
    required Medication medication,
    required tz.TZDateTime scheduledTime,
    required String time,
  }) async {
    try {
      await _zonedSchedule(
        id: id,
        medication: medication,
        scheduledTime: scheduledTime,
        time: time,
        scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _zonedSchedule(
        id: id,
        medication: medication,
        scheduledTime: scheduledTime,
        time: time,
        scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required Medication medication,
    required tz.TZDateTime scheduledTime,
    required String time,
    required AndroidScheduleMode scheduleMode,
  }) {
    return _plugin.zonedSchedule(
      id,
      'موعد الدواء',
      '${medication.name} - ${medication.dosage}',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'تذكيرات الدواء',
          channelDescription: 'تنبيهات يومية بمواعيد الأدوية',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'medication:${medication.id}:$time',
    );
  }

  tz.TZDateTime? _nextDailyTime(String value) {
    final normalizedValue = _normalizeDigits(value);
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(normalizedValue);
    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _normalizeDigits(String value) {
    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    const easternArabicIndic = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();

    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final arabicIndex = arabicIndic.indexOf(char);
      if (arabicIndex != -1) {
        buffer.write(arabicIndex);
        continue;
      }

      final easternIndex = easternArabicIndic.indexOf(char);
      if (easternIndex != -1) {
        buffer.write(easternIndex);
        continue;
      }

      buffer.write(char);
    }

    return buffer.toString();
  }

  Future<void> _setLocalTimezone() async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  int _notificationId({
    required String elderlyUserId,
    required String medicationId,
    required String time,
  }) {
    final key = '$elderlyUserId|$medicationId|$time';
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  int _instantNotificationId(String title, String body, String? payload) {
    final key =
        '$title|$body|${payload ?? ''}|${DateTime.now().millisecondsSinceEpoch}';
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
