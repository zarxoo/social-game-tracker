import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/screens/detail/game_detail_screen.dart';
import 'package:social_game_tracker/widgets/custom_search_bar.dart';
import 'package:social_game_tracker/widgets/game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data representing what Programmer 2 will provide via API
  final List<Map<String, dynamic>> _mockGames = [
    {
      'title': 'Duskmoor: Chronicles & Legends',
      'releaseDate': '11/20/2025',
      'rating': 9.2,
      'platforms': 'PC, Xbox, PS5',
      'imageUrl': '', // Empty for placeholder icon
    },
    {
      'title': 'Mass Effect Legendary Edition',
      'releaseDate': '05/14/2021',
      'rating': 9.5,
      'platforms': 'PC, Xbox, PS5',
      'imageUrl': '',
    },
    {
      'title': 'Mahjong Time (Microsoft)',
      'releaseDate': '11/10/2020',
      'rating': 7.8,
      'platforms': 'PC',
      'imageUrl': '',
    },
    {
      'title': 'Project Gotham Racing 4',
      'releaseDate': '10/02/2007',
      'rating': 8.1,
      'platforms': 'Xbox 360',
      'imageUrl': '',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar equivalent area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.gamepad, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Katalog Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temukan Game\nFavoritmu',
                      style: AppTheme.heading1,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search by name, genre, or platform',
                      style: AppTheme.subtitleText,
                    ),
                    const SizedBox(height: 24),
                    
                    // Search Bar
                    CustomSearchBar(controller: _searchController),
                    
                    const SizedBox(height: 32),
                    
                    // Recommended Game Header
                    Row(
                      children: [
                        const Text(
                          '🔥 Recommended Game',
                          style: AppTheme.heading2,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondaryColor,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Game List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mockGames.length,
                      itemBuilder: (context, index) {
                        final game = _mockGames[index];
                        return GameCard(
                          title: game['title'],
                          releaseDate: game['releaseDate'],
                          rating: game['rating'],
                          platforms: game['platforms'],
                          imageUrl: game['imageUrl'],
                          onDetailPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameDetailScreen(game: game),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
