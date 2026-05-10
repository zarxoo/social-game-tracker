import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';

class GameDetailScreen extends StatefulWidget {
  final Map<String, dynamic> game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _isWishlisted = false;

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWishlisted ? 'Added to Wishlist' : 'Removed from Wishlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.grey[800]), // Image placeholder
                  if (widget.game['imageUrl'] != null && widget.game['imageUrl'].toString().isNotEmpty)
                    Image.network(
                      widget.game['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                    )
                  else
                    const Center(child: Icon(Icons.videogame_asset, size: 80, color: Colors.grey)),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.backgroundColor.withAlpha(200),
                          AppTheme.backgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                  color: _isWishlisted ? AppTheme.primaryColor : Colors.white,
                ),
                onPressed: _toggleWishlist,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.game['title'] ?? 'Unknown Game',
                    style: AppTheme.heading1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.warningColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.game['rating'] ?? 'N/A'}/10',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, color: AppTheme.textSecondaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.game['releaseDate'] ?? 'Unknown',
                        style: AppTheme.subtitleText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Platforms', style: AppTheme.heading2),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (widget.game['platforms']?.toString().split(', ') ?? []).map((platform) {
                      return Chip(
                        label: Text(platform, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.cardColor,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: AppTheme.heading2),
                  const SizedBox(height: 8),
                  Text(
                    'This is a placeholder description for ${widget.game['title']}. In a real app, this would be fetched from the RAWG API. It would contain details about the gameplay, story, and other interesting facts about the game. \n\nGet ready to experience an epic journey in this critically acclaimed title.',
                    style: AppTheme.bodyText.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleWishlist,
                      icon: Icon(_isWishlisted ? Icons.bookmark_remove : Icons.bookmark_add),
                      label: Text(_isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isWishlisted ? AppTheme.cardColor : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
