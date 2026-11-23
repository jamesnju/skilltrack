import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    await _plugin.initialize(settings);
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> showSessionComplete() async {
    const details = NotificationDetails(android: AndroidNotificationDetails(
      'study_sessions', 'Study sessions', channelDescription: 'FocusTech study session reminders', importance: Importance.defaultImportance, priority: Priority.defaultPriority));
    await _plugin.show(1, 'FocusTech', 'Session complete. Take a short break and record what you learned.', details);
  }
}
