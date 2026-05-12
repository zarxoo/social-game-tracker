import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_model.dart';
import '../services/rawg_service.dart';

final rawgServiceProvider =
    Provider((ref) => RawgService());

class GameNotifier
    extends StateNotifier<
      AsyncValue<List<GameModel>>
    > {
  final RawgService service;

  // PAGINATION
  int _currentPage = 1;

  bool isLoadingMore = false;

  final List<GameModel> _allGames = [];

  GameNotifier(this.service)
      : super(const AsyncLoading()) {
    fetchGames();
  }

  // GET GAMES WITH PAGINATION
  Future<void> fetchGames() async {
    try {
      // Prevent duplicate request
      if (isLoadingMore) return;

      isLoadingMore = true;

      // Loading hanya saat awal
      if (_currentPage == 1) {
        state = const AsyncLoading();
      }

      final games =
          await service.getGames(
        page: _currentPage,
      );

      _allGames.addAll(games);

      state = AsyncData(_allGames);

      _currentPage++;
    } catch (e, stackTrace) {
      state = AsyncError(
        e,
        stackTrace,
      );
    } finally {
      isLoadingMore = false;
    }
  }

  // SEARCH GAMES
  Future<void> searchGames(
    String keyword,
  ) async {
    try {
      state = const AsyncLoading();

      // Reset pagination saat search
      _currentPage = 1;

      _allGames.clear();

      final games = keyword.isEmpty
          ? await service.getGames(
              page: 1,
            )
          : await service.searchGames(
              keyword,
            );

      _allGames.addAll(games);

      state = AsyncData(_allGames);
    } catch (e, stackTrace) {
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
    ref.read(rawgServiceProvider),
  ),
);