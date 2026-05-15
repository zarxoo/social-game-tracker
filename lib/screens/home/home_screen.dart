import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/providers/game_provider.dart';
import 'package:social_game_tracker/screens/detail/game_detail_screen.dart';
import 'package:social_game_tracker/widgets/custom_search_bar.dart';
import 'package:social_game_tracker/widgets/game_card.dart';

class HomeScreen
    extends ConsumerStatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen>
      createState() =>
          _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {

  final TextEditingController
      _searchController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    // INFINITE SCROLL
    _scrollController
        .addListener(() async {

      if (_scrollController
              .position
              .pixels >=
          _scrollController
                  .position
                  .maxScrollExtent -
              300) {

        if (_isFetching) return;

        _isFetching = true;

        await ref
            .read(
              gameProvider
                  .notifier,
            )
            .fetchGames();

        _isFetching = false;
      }
    });
  }

  @override
  void dispose() {

    _searchController
        .dispose();

    _scrollController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final gameState =
        ref.watch(
      gameProvider,
    );

    return Scaffold(

      body: SafeArea(

        child: gameState.when(

          // LOADING
          loading: () =>
              const Center(
            child:
                CircularProgressIndicator(),
          ),

          // ERROR
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
                color: Colors.red,
              ),
            ),
          ),

          // SUCCESS
          data: (games) {

            // EMPTY
            if (games.isEmpty) {

              return const Center(
                child: Text(
                  'No Games Found',

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }

            return ListView.builder(

              controller:
                  _scrollController,

              padding:
                  const EdgeInsets.all(
                16,
              ),

              // PERFORMANCE
              cacheExtent: 500,

              itemCount:
                  games.length + 1,

              itemBuilder:
                  (
                    context,
                    index,
                  ) {

                // HEADER
                if (index == 0) {

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // TOP HEADER
                      Row(
                        children: [

                          Container(
                            padding:
                                const EdgeInsets.all(
                              8,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  AppTheme
                                      .primaryColor,

                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),

                            child:
                                const Icon(
                              Icons.gamepad,
                              color:
                                  Colors.white,
                              size: 20,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          const Text(
                            'Katalog Game',

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontSize:
                                  16,

                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // TITLE
                      const Text(
                        'Temukan Game\nFavoritmu',

                        style:
                            AppTheme
                                .heading1,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // SUBTITLE
                      const Text(
                        'Search by name, genre, or platform',

                        style:
                            AppTheme
                                .subtitleText,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

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

                      const SizedBox(
                        height: 32,
                      ),

                      // SECTION HEADER
                      Row(
                        children: [

                          const Text(
                            '🔥 Recommended Game',

                            style:
                                AppTheme
                                    .heading2,
                          ),

                          const Spacer(),

                          TextButton(
                            onPressed:
                                () {},

                            child:
                                const Text(
                              'See All',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  );
                }

                // GAME ITEM
                final game =
                    games[index - 1];

                return GameCard(

                  title:
                      game.name,

                  releaseDate:
                      game.releasedDate,

                  rating:
                      game.rating,

                  platforms: game
                      .platforms
                      .join(', '),

                  imageUrl:
                      game.backgroundImage,

                  onDetailPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) =>
                                GameDetailScreen(
                          game: game,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}