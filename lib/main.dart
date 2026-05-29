import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: SocialGameTrackerApp(),
    ),
  );
}

class SocialGameTrackerApp extends StatelessWidget {
  const SocialGameTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Social Game Tracker',

      theme: AppTheme.darkTheme,

      // LANGSUNG KE MAIN SCREEN
      home: const MainScreen(),
    );
  }
}