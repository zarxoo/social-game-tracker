import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/game_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import '../main_screen.dart';
import '../detail/game_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () async {
                // LOGOUT
                await AuthService().logout();

                // KEMBALI KE MAIN SCREEN
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            // LOADING
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // USER TIDAK DITEMUKAN
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('User tidak ditemukan'),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final wishlist = data['wishlist'] ?? [];
            final played = data['played'] ?? [];
            final favorites = data['favorites'] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER PROFILE
                Container(
                  padding: const EdgeInsets.only(top: 100, bottom: 32, left: 16, right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.8),
                        AppTheme.backgroundColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.cardColor,
                        child: Text(
                          data['username'][0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data['username'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['email'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB BAR
                const TabBar(
                  tabs: [
                    Tab(text: 'Wishlist'),
                    Tab(text: 'Played'),
                    Tab(text: 'Favorites'),
                  ],
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                ),

                // TAB BAR VIEW (GRID GAME)
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildGameGrid(wishlist, context, uid, 'wishlist'),
                      _buildGameGrid(played, context, uid, 'played'),
                      _buildGameGrid(favorites, context, uid, 'favorites'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameGrid(List games, BuildContext context, String uid, String listType) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset_off, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada game.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        
        IconData tabIcon;
        Color tabColor;
        String tabText;
        if (listType == 'wishlist') {
          tabIcon = Icons.favorite;
          tabColor = Colors.amber;
          tabText = 'Wishlist';
        } else if (listType == 'played') {
          tabIcon = Icons.videogame_asset;
          tabColor = Colors.teal;
          tabText = 'Played';
        } else {
          tabIcon = Icons.star;
          tabColor = Colors.pink;
          tabText = 'Favorite';
        }

        return GestureDetector(
          onTap: () => _navigateToDetail(context, game),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          game['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.videogame_asset,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tabIcon, color: tabColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              tabText,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Game spotlight',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Disimpan ke $tabText komunitas',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2A4A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tabIcon, color: const Color(0xFF8A82E2), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Community $tabText pick',
                              style: const TextStyle(
                                color: Color(0xFF8A82E2),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> gameData) {
    // Bangun GameModel dari data Firestore (Instan)
    final dummyGame = GameModel(
      id: gameData['id'],
      name: gameData['name'],
      backgroundImage: gameData['image'],
      rating: (gameData['rating'] ?? 0).toDouble(),
      releasedDate: gameData['releasedDate'] ?? '-',
      platforms: List<String>.from(gameData['platforms'] ?? []),
      description: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(game: dummyGame),
      ),
    );
  }
}