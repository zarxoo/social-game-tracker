import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_model.dart';
import '../detail/game_detail_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final wishlist = userData['wishlist'] ?? [];
    final played = userData['played'] ?? [];
    final favorites = userData['favorites'] ?? [];
    final username = (userData['username'] ?? 'Player').toString();
    final email = (userData['email'] ?? '').toString();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Profile'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
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
                      username.isNotEmpty ? username[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email.isNotEmpty ? email : 'No email provided',
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
                  _buildGameGrid(wishlist, context),
                  _buildGameGrid(played, context),
                  _buildGameGrid(favorites, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGrid(List games, BuildContext context) {
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7, // Aspek rasio untuk box art game
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GestureDetector(
          onTap: () => _navigateToDetail(context, game),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // GAMBAR GAME
                Image.network(
                  game['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.videogame_asset,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                // GRADIENT GELAP DI BAWAH AGAR TEKS TERBACA
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                // JUDUL GAME
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    game['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(game: dummyGame),
      ),
    );
  }
}
