import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:social_game_tracker/screens/auth/login_screen.dart';
import 'package:social_game_tracker/screens/community/community_screen.dart';
import 'package:social_game_tracker/screens/home/home_screen.dart';
import 'package:social_game_tracker/screens/profile/profile_screen.dart';
import 'package:social_game_tracker/widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // CEK APAKAH USER SUDAH LOGIN
    final isLoggedIn =
        FirebaseAuth.instance.currentUser != null;

    final List<Widget> pages = [
      const HomeScreen(),
      const CommunityScreen(),

      // JIKA SUDAH LOGIN
      isLoggedIn
          ? const ProfileScreen()

          // JIKA BELUM LOGIN
          : const LoginScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}