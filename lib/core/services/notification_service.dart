import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';

class NotificationService {
  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Task Reminders';
  static const String _channelDescription =
      'Reminders for upcoming todo task due times';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    await _configureTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await _requestPermissions();
    await _createNotificationChannel();
  }

  Future<void> scheduleTaskReminder(Task task) async {
    await cancelTaskReminder(task.id);

    if (task.isCompleted) {
      return;
    }

    final now = DateTime.now();
    if (!task.dueDate.isAfter(now)) {
      return;
    }

    final reminderTime = _buildReminderTime(task, now);
    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    await _notifications.zonedSchedule(
      _notificationId(task.id),
      'Task due reminder',
      '${task.title} is due soon',
      tzReminderTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await _notifications.cancel(_notificationId(taskId));
  }

  Future<void> syncAllTaskReminders(List<Task> tasks) async {
    for (final task in tasks) {
      await scheduleTaskReminder(task);
    }
  }

  DateTime _buildReminderTime(Task task, DateTime now) {
    final leadTime = Duration(minutes: task.remindBeforeMinutes);
    final candidate = task.dueDate.subtract(leadTime);
    if (candidate.isAfter(now)) {
      return candidate;
    }

    final fallback = task.dueDate.subtract(const Duration(minutes: 1));
    if (fallback.isAfter(now)) {
      return fallback;
    }

    return task.dueDate;
  }

  int _notificationId(String taskId) => taskId.hashCode & 0x7fffffff;

  Future<void> _configureTimezone() async {
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  }

  Future<void> _requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _createNotificationChannel() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );
  }
}
