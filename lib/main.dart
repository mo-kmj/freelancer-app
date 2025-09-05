import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Import your existing pages
import 'freelan/home_page.dart';
import 'login_page.dart';
import 'client/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Test Firebase connection
  try {
    // Simple test: print Firebase app name
    print('Firebase initialized: ${Firebase.app().name}');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(FreelanceHubApp());
}


class FreelanceHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreelanceHub',
      debugShowCheckedModeBanner: false,
      
      // Combined theme with dark mode support
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1E1A3C),
        cardColor: Color(0xFF1B1737),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B1737),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      
      // Light theme for login page and other light screens
      // You can switch between themes based on user preference
      // theme: ThemeData(
      //   fontFamily: 'Inter',
      //   primarySwatch: Colors.purple,
      //   scaffoldBackgroundColor: Colors.white,
      // ),
      
      // Define all routes
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => DashboardScreen(),
        '/home': (context) => HomePage(), // Alternative route to home
      },
      
      // Fallback to login page
      home: const LoginPage(),
      
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      },
    );
  }
}