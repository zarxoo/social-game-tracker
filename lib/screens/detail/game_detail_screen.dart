import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/models/game_model.dart';

import '../../services/firestore_service.dart';
import '../../services/rawg_service.dart';
import '../auth/login_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class GameDetailScreen extends StatefulWidget {
  final GameModel game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _isWishlisted = false;
  bool _isPlayed = false;
  bool _isFavorite = false;

  GameModel? gameDetail;
  bool isLoadingDescription = true;
  List<String> screenshots = [];

  @override
  void initState() {
    super.initState();
    _checkGameStatus();
    _loadGameDetails();
  }

  String getEnglishDescription(String text) {
    if (text.contains('Español')) {
      return text.split('Español').first.trim();
    }

    if (text.contains('Spanish')) {
      return text.split('Spanish').first.trim();
    }

    return text;
  }

  Future<void> _checkGameStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isWishlisted = false;
        _isPlayed = false;
        _isFavorite = false;
      });
      return;
    }

    final uid = user.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;

    final wishlist = data['wishlist'] ?? [];
    final played = data['played'] ?? [];
    final favorites = data['favorites'] ?? [];

    final wishlistExists = wishlist.any((game) => game['id'] == widget.game.id);
    final playedExists = played.any((game) => game['id'] == widget.game.id);
    final favoriteExists = favorites.any(
      (game) => game['id'] == widget.game.id,
    );

    setState(() {
      _isWishlisted = wishlistExists;
      _isPlayed = playedExists;
      _isFavorite = favoriteExists;
    });
  }

  Future<void> _loadGameDetails() async {
    try {
      final service = RawgService();

      final results = await Future.wait([
        service.getGameDetails(widget.game.id),
        service.getGameScreenshots(widget.game.id),
      ]);

      setState(() {
        gameDetail = results[0] as GameModel;
        screenshots = results[1] as List<String>;
        isLoadingDescription = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDescription = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    final uid = user.uid;

    try {
      if (!_isWishlisted) {
        await FirestoreService().addWishlist(
          uid: uid,
          gameId: widget.game.id,
          gameName: widget.game.name,
          gameImage: widget.game.backgroundImage,
          gameRating: widget.game.rating,
          gameReleasedDate: widget.game.releasedDate,
          gamePlatforms: widget.game.platforms,
          gameGenres: widget.game.genres,
        );

        setState(() {
          _isWishlisted = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to Wishlist')));
        }
      } else {
        await FirestoreService().removeWishlist(
          uid: uid,
          gameId: widget.game.id,
          gameName: widget.game.name,
          gameImage: widget.game.backgroundImage,
          gameRating: widget.game.rating,
          gameReleasedDate: widget.game.releasedDate,
          gamePlatforms: widget.game.platforms,
        );

        setState(() {
          _isWishlisted = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from Wishlist')),
          );
        }
      }
    } catch (e) {
      debugPrint('ERROR WISHLIST: $e');
    }
  }

  Future<void> _togglePlayed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    final uid = user.uid;

    try {
      if (!_isPlayed) {
        await FirestoreService().addPlayed(
          uid: uid,
          gameId: widget.game.id,
          gameName: widget.game.name,
          gameImage: widget.game.backgroundImage,
          gameRating: widget.game.rating,
          gameReleasedDate: widget.game.releasedDate,
          gamePlatforms: widget.game.platforms,
          gameGenres: widget.game.genres,
        );

        setState(() {
          _isPlayed = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to Played')));
        }
      } else {
        await FirestoreService().removePlayed(
          uid: uid,
          gameId: widget.game.id,
          gameName: widget.game.name,
          gameImage: widget.game.backgroundImage,
          gameRating: widget.game.rating,
          gameReleasedDate: widget.game.releasedDate,
          gamePlatforms: widget.game.platforms,
        );

        setState(() {
          _isPlayed = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Removed from Played')));
        }
      }
    } catch (e) {
      debugPrint('ERROR PLAYED: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    final uid = user.uid;

    try {
      if (!_isFavorite) {
        await FirestoreService().addFavorite(
          uid: uid,
          gameId: widget.game.id,
          gameName: widget.game.name,
          gameImage: widget.game.backgroundImage,
          gameRating: widget.game.rating,
          gameReleasedDate: widget.game.releasedDate,
          gamePlatforms: widget.game.platforms,
          gameGenres: widget.game.genres,
        );

        setState(() {
          _isFavorite = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to Favorite')));
        }
      } else {
        await FirestoreService().removeFavorite(
          uid: uid,
          gameId: widget.game.id,
          gameName: widget.game.name,
          gameImage: widget.game.backgroundImage,
          gameRating: widget.game.rating,
          gameReleasedDate: widget.game.releasedDate,
          gamePlatforms: widget.game.platforms,
        );

        setState(() {
          _isFavorite = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from Favorite')),
          );
        }
      }
    } catch (e) {
      debugPrint('ERROR FAVORITE: $e');
    }
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
                  Container(color: Colors.grey[800]),
                  if (screenshots.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        enlargeCenterPage: false,
                      ),
                      items: screenshots.map((image) {
                        return Builder(
                          builder: (context) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image, size: 80),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  else if (widget.game.backgroundImage.isNotEmpty)
                    Image.network(
                      widget.game.backgroundImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.videogame_asset,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.videogame_asset,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.backgroundColor.withOpacity(0.8),
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
                    widget.game.name,
                    style: AppTheme.heading1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.warningColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.game.rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.textSecondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.game.releasedDate,
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
                    children: widget.game.platforms.map((platform) {
                      return Chip(
                        label: Text(
                          platform,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.cardColor,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: AppTheme.heading2),
                  const SizedBox(height: 8),
                  isLoadingDescription
                      ? const SizedBox(
                          height: 24,
                        ) // Empty space instead of loading spinner
                      : Text(
                          gameDetail?.description.isNotEmpty == true
                              ? getEnglishDescription(gameDetail!.description)
                              : 'No description available.',
                          style: AppTheme.bodyText.copyWith(height: 1.5),
                        ),
                  if (!isLoadingDescription &&
                      gameDetail?.website.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(gameDetail!.website);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch website'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.language),
                        label: const Text('Visit Official Website'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleWishlist,
                      icon: Icon(
                        _isWishlisted
                            ? Icons.bookmark_remove
                            : Icons.bookmark_add,
                      ),
                      label: Text(
                        _isWishlisted
                            ? 'Remove from Wishlist'
                            : 'Add to Wishlist',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isWishlisted
                            ? AppTheme.cardColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _togglePlayed,
                          icon: Icon(
                            _isPlayed
                                ? Icons.videogame_asset_off
                                : Icons.videogame_asset,
                          ),
                          label: Text(_isPlayed ? 'Played' : 'Add to Played'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _isPlayed
                                ? AppTheme.cardColor
                                : Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(_isFavorite ? 'Favorited' : 'Favorite'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _isFavorite
                                ? AppTheme.cardColor
                                : Colors.pink,
                          ),
                        ),
                      ),
                    ],
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
