import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/screens/auth/login_screen.dart';

void main() {
  runApp(const SocialGameTrackerApp());
}

class SocialGameTrackerApp extends StatelessWidget {
  const SocialGameTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Game Tracker',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
