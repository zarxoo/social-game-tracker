import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/screens/home/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SocialGameTrackerApp(),
    ),
  );
}

class SocialGameTrackerApp
    extends StatelessWidget {
  const SocialGameTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title: 'Social Game Tracker',

      theme: AppTheme.darkTheme,

      home: const HomeScreen(),
    );
  }
}