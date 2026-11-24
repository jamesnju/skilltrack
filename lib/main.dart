
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'screens/home_shell.dart';
import 'screens/focus_screen.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'services/app_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local database.
  await AppDatabase.instance.database;

  // Initialize notifications.
  await NotificationService.instance.initialize();

  // Restore the daily reminder if it is enabled.
  await NotificationService.instance.restoreDailyReminder();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const FocusTechApp(),
    ),
  );

  // Handle notification taps that launched the app
  // when it was completely closed.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.handleInitialNotification();
  });
}

class FocusTechApp extends StatelessWidget {
  const FocusTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16845B);

    return MaterialApp(
      title: 'FocusTech',
      debugShowCheckedModeBanner: false,

      // Allows NotificationService to navigate to FocusScreen.
      navigatorKey: appNavigatorKey,

      // Open FocusScreen when the daily reminder is tapped.
      routes: {
        '/focus': (context) => const FocusScreen(),
      },

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      home: const HomeShell(),
    );
  }
}
