import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../data/app_database.dart';
import 'app_navigation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 100;
  static const int _sessionCompleteId = 101;

  bool _openFocusOnLaunch = false;

  // --------------------------------------------------
  // INITIALIZE NOTIFICATIONS
  // --------------------------------------------------

  Future<void> initialize() async {
    // Initialize timezone database.
    tz_data.initializeTimeZones();

    // Set the device's local timezone.
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      // flutter_timezone versions may return either a String
      // or an object containing the timezone name.
      final dynamic info = timezoneInfo;
      final String timezoneName = info is String ? info : info.name as String;

      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      debugPrint('Timezone initialization failed: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Request notification permission on Android 13+.
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();

    // Check whether the app was opened by tapping a notification
    // while it was completely closed.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;

      if (payload == 'open_focus') {
        _openFocusOnLaunch = true;
      }
    }
  }

  // --------------------------------------------------
  // HANDLE NOTIFICATION TAPS
  // --------------------------------------------------

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload == 'open_focus') {
      _openFocusScreen();
    }
  }

  void _openFocusScreen() {
    final navigator = appNavigatorKey.currentState;

    if (navigator == null) {
      _openFocusOnLaunch = true;
      return;
    }

    _openFocusOnLaunch = false;

    navigator.pushNamed('/focus');
  }

  // Call this after the app's first frame when handling
  // a notification that launched the app from a closed state.
  void handleInitialNotification() {
    if (_openFocusOnLaunch) {
      _openFocusScreen();
    }
  }

  // --------------------------------------------------
  // SESSION COMPLETION NOTIFICATION
  // --------------------------------------------------

  Future<void> showSessionComplete() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'focus_session_channel',
          'Focus Sessions',
          channelDescription: 'Notifications when focus sessions finish.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      _sessionCompleteId,
      'Focus session complete!',
      'Great work. Take a short break before your next session.',
      details,
    );
  }

  // --------------------------------------------------
  // GET DAILY REMINDER SETTINGS
  // --------------------------------------------------

  Future<Map<String, dynamic>> getDailyReminderSettings() async {
    final Database db = await AppDatabase.instance.database;

    final result = await db.query(
      'daily_reminder_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return {'enabled': 0, 'hour': 18, 'minute': 0};
    }

    return result.first;
  }

  // --------------------------------------------------
  // SAVE AND UPDATE DAILY REMINDER
  // --------------------------------------------------

  Future<void> setDailyReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid reminder time.');
    }

    final Database db = await AppDatabase.instance.database;

    await db.insert('daily_reminder_settings', {
      'id': 1,
      'enabled': enabled ? 1 : 0,
      'hour': hour,
      'minute': minute,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    if (enabled) {
      await _scheduleDailyReminder(hour: hour, minute: minute);
    } else {
      await cancelDailyReminder();
    }
  }

  // --------------------------------------------------
  // SCHEDULE DAILY RECURRING REMINDER
  // --------------------------------------------------

  Future<void> _scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's reminder time has already passed,
    // schedule it for tomorrow.
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_learning_reminder_channel',
          'Daily Learning Reminders',
          channelDescription:
              'Reminders to continue your daily learning routine.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.cancel(_dailyReminderId);

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Time to focus!',
      'Your daily learning session is waiting. Tap to start focusing.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'open_focus',
    );
  }

  // --------------------------------------------------
  // RESTORE REMINDER AFTER APP RESTART
  // --------------------------------------------------

  Future<void> restoreDailyReminder() async {
    final settings = await getDailyReminderSettings();

    final bool enabled =
        settings['enabled'] == 1 || settings['enabled'] == true;

    if (!enabled) {
      await cancelDailyReminder();
      return;
    }

    final int hour = settings['hour'] as int;
    final int minute = settings['minute'] as int;

    await _scheduleDailyReminder(hour: hour, minute: minute);
  }

  // --------------------------------------------------
  // CANCEL DAILY REMINDER
  // --------------------------------------------------

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  // --------------------------------------------------
  // CANCEL ALL NOTIFICATIONS
  // --------------------------------------------------

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:timezone/data/latest_all.dart' as tz_data;
// import 'package:timezone/timezone.dart' as tz;

// import '../data/app_database.dart';

// class NotificationService {
//   NotificationService._();

//   static final instance = NotificationService._();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   static const int _dailyReminderId = 100;
//   static const int _sessionCompleteId = 101;

//   bool _initialized = false;

//   Future<void> initialize() async {
//     if (_initialized) return;

//     tz_data.initializeTimeZones();

//     try {
//       final timezoneName = await FlutterTimezone.getLocalTimezone();
//       tz.setLocalLocation(tz.getLocation(timezoneName));
//     } catch (_) {
//       // Fallback if the device timezone cannot be read.
//       tz.setLocalLocation(tz.getLocation('UTC'));
//     }

//     const settings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     );

//     await _plugin.initialize(settings);

//     await _plugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();

//     _initialized = true;
//   }

//   Future<void> showSessionComplete() async {
//     await initialize();

//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'study_sessions',
//         'Study sessions',
//         channelDescription: 'FocusTech study session reminders',
//         importance: Importance.defaultImportance,
//         priority: Priority.defaultPriority,
//       ),
//     );

//     await _plugin.show(
//       _sessionCompleteId,
//       'FocusTech',
//       'Session complete. Take a short break and record what you learned.',
//       details,
//     );
//   }

//   Future<Map<String, Object?>> getDailyReminderSettings() async {
//     final db = await AppDatabase.instance.database;

//     final result = await db.query(
//       'daily_reminder_settings',
//       where: 'id = ?',
//       whereArgs: [1],
//       limit: 1,
//     );

//     if (result.isEmpty) {
//       return {
//         'enabled': 0,
//         'hour': 18,
//         'minute': 0,
//       };
//     }

//     return result.first;
//   }

//   Future<void> setDailyReminder({
//     required bool enabled,
//     required int hour,
//     required int minute,
//   }) async {
//     await initialize();

//     if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
//       throw ArgumentError('Invalid reminder time.');
//     }

//     final db = await AppDatabase.instance.database;

//     await db.insert(
//       'daily_reminder_settings',
//       {
//         'id': 1,
//         'enabled': enabled ? 1 : 0,
//         'hour': hour,
//         'minute': minute,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     if (enabled) {
//       await _scheduleDailyReminder(hour: hour, minute: minute);
//     } else {
//       await _plugin.cancel(_dailyReminderId);
//     }
//   }

//   Future<void> _scheduleDailyReminder({
//     required int hour,
//     required int minute,
//   }) async {
//     final now = tz.TZDateTime.now(tz.local);

//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );

//     // If today's reminder time has passed, schedule for tomorrow.
//     if (!scheduledDate.isAfter(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }

//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'daily_study_reminders',
//         'Daily study reminders',
//         channelDescription: 'Your daily FocusTech learning reminder',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//     );

//     await _plugin.cancel(_dailyReminderId);

//     await _plugin.zonedSchedule(
//       _dailyReminderId,
//       'Time to learn with FocusTech!',
//       'Your daily learning session is waiting. Take one step towards your goals.',
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   Future<void> restoreDailyReminder() async {
//     await initialize();

//     final settings = await getDailyReminderSettings();

//     final enabled = settings['enabled'] == 1;
//     final hour = settings['hour'] as int;
//     final minute = settings['minute'] as int;

//     if (enabled) {
//       await _scheduleDailyReminder(
//         hour: hour,
//         minute: minute,
//       );
//     } else {
//       await _plugin.cancel(_dailyReminderId);
//     }
//   }

//   Future<void> cancelDailyReminder() async {
//     await initialize();

//     await _plugin.cancel(_dailyReminderId);

//     final db = await AppDatabase.instance.database;

//     await db.update(
//       'daily_reminder_settings',
//       {'enabled': 0},
//       where: 'id = ?',
//       whereArgs: [1],
//     );
//   }
// }
