import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_database.dart';
import 'screens/home_shell.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  await NotificationService.instance.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const FocusTechApp(),
    ),
  );
}

class FocusTechApp extends StatelessWidget {
  const FocusTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16845B);
    return MaterialApp(
      title: 'FocusTech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const HomeShell(),
    );
  }
}
