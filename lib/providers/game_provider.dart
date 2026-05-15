import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_model.dart';
import '../services/rawg_service.dart';

final rawgServiceProvider =
    Provider(
  (ref) => RawgService(),
);

class GameNotifier
    extends StateNotifier<
        AsyncValue<List<GameModel>>> {

  final RawgService service;

  GameNotifier(this.service)
      : super(const AsyncLoading()) {

    fetchGames();
  }

  // PAGINATION
  int _currentPage = 1;

  // PREVENT MULTIPLE REQUEST
  bool isLoadingMore = false;

  // ALL GAME DATA
  final List<GameModel> _allGames = [];

  // FETCH GAMES
  Future<void> fetchGames() async {

    try {

      // PREVENT DUPLICATE API CALL
      if (isLoadingMore) return;

      isLoadingMore = true;

      // LOADING ONLY FIRST TIME
      if (_currentPage == 1 &&
          _allGames.isEmpty) {

        state =
            const AsyncLoading();
      }

      final games =
          await service.getGames(
        page: _currentPage,
      );

      // PREVENT DUPLICATE DATA
      final newGames =
          games.where((game) {

        return !_allGames.any(
          (existingGame) =>
              existingGame.id ==
              game.id,
        );
      }).toList();

      // ADD NEW DATA
      _allGames.addAll(newGames);

      // IMPORTANT
      // USE NEW LIST INSTANCE
      state = AsyncData(
        List.from(_allGames),
      );

      // NEXT PAGE
      _currentPage++;

    } catch (
      e,
      stackTrace
    ) {

      state = AsyncError(
        e,
        stackTrace,
      );

    } finally {

      isLoadingMore = false;
    }
  }

  // SEARCH GAME
  Future<void> searchGames(
    String keyword,
  ) async {

    try {

      state =
          const AsyncLoading();

      // RESET
      _currentPage = 1;

      _allGames.clear();

      final games =
          keyword.isEmpty

              ? await service
                  .getGames(
                  page: 1,
                )

              : await service
                  .searchGames(
                  keyword,
                );

      _allGames.addAll(games);

      // IMPORTANT
      state = AsyncData(
        List.from(_allGames),
      );

      // NEXT PAGE
      _currentPage = 2;

    } catch (
      e,
      stackTrace
    ) {

      state = AsyncError(
        e,
        stackTrace,
      );
    }
  }
}

final gameProvider =
    StateNotifierProvider<
  GameNotifier,
  AsyncValue<List<GameModel>>
>(
  (ref) => GameNotifier(
    ref.read(
      rawgServiceProvider,
    ),
  ),
);