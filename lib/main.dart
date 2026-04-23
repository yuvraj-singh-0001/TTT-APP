import 'package:flutter/material.dart';

import 'app_branding.dart';
import 'screens/about_us_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        scaffoldBackgroundColor: kBrandSurface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandGold,
          brightness: Brightness.dark,
          primary: kBrandGold,
          secondary: Colors.white,
          surface: kBrandSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBrandBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const _LaunchShell(),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/about': (context) => const AboutUsPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}

class _LaunchShell extends StatefulWidget {
  const _LaunchShell();

  @override
  State<_LaunchShell> createState() => _LaunchShellState();
}

class _LaunchShellState extends State<_LaunchShell> {
  bool _showSplash = true;

  void _handleSplashFinished() {
    if (!mounted) {
      return;
    }
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onFinished: _handleSplashFinished,
            )
          : const MyHomePage(key: ValueKey('home')),
    );
  }
}
