import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/mainpage.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/player_service.dart';

void main() async {
  // Bắt tất cả lỗi không xử lý được để app không crash
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Bắt lỗi Flutter framework (widget, rendering, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      // Chỉ in log, không crash app
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    // Bắt lỗi platform channel (audioplayers native crashes)
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher Error: $error');
      return true; // Đã xử lý, không crash
    };

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized successfully.");
      // Pre-warm PlayerService to trigger loadProfile() and database seeding
      PlayerService();
    } catch (e) {
      debugPrint("Firebase initialization failed: $e. Running in offline/local fallback mode.");
    }
    
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('current_uid') != null;

    runApp(MainApp(isLoggedIn: isLoggedIn));
  }, (error, stackTrace) {
    // Bắt mọi lỗi uncaught trong zone này
    debugPrint('Uncaught Zone Error: $error');
  });
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1ED760),
          surface: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF242424),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white60),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
        ),
      ),
      home: isLoggedIn ? const MainPage() : const WelcomePage(),
    );
  }
}