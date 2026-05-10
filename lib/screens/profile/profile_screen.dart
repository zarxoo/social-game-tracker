import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/widgets/empty_state_widget.dart';
import 'package:social_game_tracker/screens/auth/login_screen.dart';
import 'package:social_game_tracker/widgets/game_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for Sprint 2 profile wishlist
    bool hasWishlist = DateTime.now().year > 2000; 
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Text('JD', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('John Doe', style: AppTheme.heading2),
                      const SizedBox(height: 4),
                      Text('Level 12 Gamer', style: AppTheme.subtitleText.copyWith(color: AppTheme.textSecondaryColor)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor, size: 18),
                label: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                _buildStatCard('Games', '24'),
                const SizedBox(width: 12),
                _buildStatCard('Hours', '250'),
                const SizedBox(width: 12),
                _buildStatCard('Wishlist', '12'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Wishlist Section
            Row(
              children: [
                const Icon(Icons.bookmark, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text('Wishlist', style: AppTheme.heading2),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: AppTheme.textSecondaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            hasWishlist 
              ? Column(
                  children: [
                    GameCard(
                      title: 'Mahjong Time (Microsoft)',
                      releaseDate: '11/10/2020',
                      rating: 7.8,
                      platforms: 'PC',
                      imageUrl: '',
                      onDetailPressed: () {},
                    ),
                    GameCard(
                      title: 'Project Gotham Racing 4',
                      releaseDate: '10/02/2007',
                      rating: 8.1,
                      platforms: 'Xbox 360',
                      imageUrl: '',
                      onDetailPressed: () {},
                    ),
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const EmptyStateWidget(
                    icon: Icons.bookmark_border,
                    title: 'No wishlist games yet',
                    message: 'Add games from detail page',
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: AppTheme.subtitleText),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.heading2.copyWith(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
