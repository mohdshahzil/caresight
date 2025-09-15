import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/name_entry_screen.dart';
import 'screens/main_dashboard.dart';
import 'utils/performance_utils.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  // Performance optimizations
  PerformanceUtils.warmupShaders();
  PerformanceUtils.optimizeFrameRate();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CareSightApp());
}

class CareSightApp extends StatelessWidget {
  const CareSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareSight',
      theme: AppTheme.lightTheme,
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Splash delay

    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');

    if (mounted) {
      if (userName != null && userName.isNotEmpty) {
        // User exists, go to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      } else {
        // New user, go to name entry
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NameEntryScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LandingScreen(); // Shows briefly as splash
  }
}
