import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/models/game_model.dart';

import '../../services/firestore_service.dart';

class GameDetailScreen extends StatefulWidget {
  final GameModel game;

  const GameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameDetailScreen> createState() =>
      _GameDetailScreenState();
}

class _GameDetailScreenState
    extends State<GameDetailScreen> {
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();

    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

    if (!snapshot.exists) return;

    final data =
        snapshot.data() as Map<String, dynamic>;

    final wishlist =
        data['wishlist'] ?? [];

    final exists = wishlist.any(
      (game) =>
          game['id'] == widget.game.id,
    );

    setState(() {
      _isWishlisted = exists;
    });
  }

  Future<void> _toggleWishlist() async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    try {
      if (!_isWishlisted) {
        await FirestoreService()
            .addWishlist(
          uid: uid,

          gameId: widget.game.id,

          gameName: widget.game.name,

          gameImage:
              widget.game.backgroundImage,
        );

        setState(() {
          _isWishlisted = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Added to Wishlist',
              ),
            ),
          );
        }
      } else {
        await FirestoreService()
            .removeWishlist(
          uid: uid,

          gameId: widget.game.id,

          gameName: widget.game.name,

          gameImage:
              widget.game.backgroundImage,
        );

        setState(() {
          _isWishlisted = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Removed from Wishlist',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(
        'ERROR WISHLIST: $e',
      );
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
                  Container(
                    color: Colors.grey[800],
                  ),

                  if (widget.game.backgroundImage
                      .isNotEmpty)
                    Image.network(
                      widget.game
                          .backgroundImage,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) =>
                              const Icon(
                        Icons.videogame_asset,
                        size: 80,
                        color: Colors.grey,
                      ),
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
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,

                        colors: [
                          Colors.transparent,

                          AppTheme
                              .backgroundColor
                              .withAlpha(200),

                          AppTheme
                              .backgroundColor,
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
                  _isWishlisted
                      ? Icons.bookmark
                      : Icons.bookmark_border,

                  color: _isWishlisted
                      ? AppTheme
                          .primaryColor
                      : Colors.white,
                ),

                onPressed:
                    _toggleWishlist,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                20.0,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.game.name,

                    style: AppTheme
                        .heading1
                        .copyWith(
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color:
                            AppTheme
                                .warningColor,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${widget.game.rating}/10',

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,

                          fontSize: 14,

                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme
                            .textSecondaryColor,
                        size: 16,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        widget
                            .game
                            .releasedDate,

                        style: AppTheme
                            .subtitleText,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Platforms',
                    style:
                        AppTheme.heading2,
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children: widget
                        .game.platforms
                        .map(
                      (platform) {
                        return Chip(
                          label: Text(
                            platform,

                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),

                          backgroundColor:
                              AppTheme
                                  .cardColor,

                          side:
                              BorderSide.none,
                        );
                      },
                    ).toList(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Description',
                    style:
                        AppTheme.heading2,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'This is a placeholder description for ${widget.game.name}. In a real app, this would be fetched from the RAWG API.',

                    style: AppTheme
                        .bodyText
                        .copyWith(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _toggleWishlist,

                      icon: Icon(
                        _isWishlisted
                            ? Icons
                                .bookmark_remove
                            : Icons
                                .bookmark_add,
                      ),

                      label: Text(
                        _isWishlisted
                            ? 'Remove from Wishlist'
                            : 'Add to Wishlist',
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        backgroundColor:
                            _isWishlisted
                                ? AppTheme
                                    .cardColor
                                : AppTheme
                                    .primaryColor,
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