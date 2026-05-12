import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/providers/game_provider.dart';
import 'package:social_game_tracker/screens/detail/game_detail_screen.dart';
import 'package:social_game_tracker/widgets/custom_search_bar.dart';
import 'package:social_game_tracker/widgets/game_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState =
        ref.watch(gameProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding:
                  const EdgeInsets.all(16.0),

              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      8,
                    ),

                    decoration: BoxDecoration(
                      color:
                          AppTheme.primaryColor,

                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),

                    child: const Icon(
                      Icons.gamepad,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    'Katalog Game',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Temukan Game\nFavoritmu',

                      style:
                          AppTheme.heading1,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Search by name, genre, or platform',

                      style: AppTheme
                          .subtitleText,
                    ),

                    const SizedBox(height: 24),

                    // SEARCH BAR
                    CustomSearchBar(
                      controller:
                          _searchController,

                      onSearch: () {
                        ref
                            .read(
                              gameProvider
                                  .notifier,
                            )
                            .searchGames(
                              _searchController
                                  .text,
                            );
                      },
                    ),

                    const SizedBox(height: 32),

                    // HEADER RECOMMENDED
                    Row(
                      children: [
                        const Text(
                          '🔥 Recommended Game',

                          style: AppTheme
                              .heading2,
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: () {},

                          style:
                              TextButton.styleFrom(
                            foregroundColor:
                                AppTheme
                                    .textSecondaryColor,

                            textStyle:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),

                          child:
                              const Text(
                            'See All',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // GAME LIST FROM API
                    gameState.when(
                      loading: () =>
                          const Center(
                        child:
                            CircularProgressIndicator(),
                      ),

                      error:
                          (
                            error,
                            stack,
                          ) =>
                              Center(
                        child: Text(
                          error.toString(),

                          style:
                              const TextStyle(
                            color:
                                Colors.red,
                          ),
                        ),
                      ),

                      data: (games) {
                        if (games.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(
                                24,
                              ),

                              child: Text(
                                'No Games Found',

                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          itemCount:
                              games.length,

                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final game =
                                    games[index];

                                return GameCard(
                                  title:
                                      game.name,

                                  releaseDate:
                                      game
                                          .releasedDate,

                                  rating:
                                      game.rating,

                                  platforms: game
                                      .platforms
                                      .join(
                                        ', ',
                                      ),

                                  imageUrl:
                                      game
                                          .backgroundImage,

                                  onDetailPressed:
                                      () {
                                    Navigator.push(
                                      context,

                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) =>
                                                GameDetailScreen(
                                          game:
                                              game,
                                        ),
                                      ),
                                    );
                                  },
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