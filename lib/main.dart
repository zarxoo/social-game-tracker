import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

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

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance
            .authStateChanges(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          // SUDAH LOGIN
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // BELUM LOGIN
          return const LoginScreen();
        },
      ),
    );
  }
}