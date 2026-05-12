import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_model.dart';
import '../services/rawg_service.dart';

final rawgServiceProvider =
    Provider((ref) => RawgService());

class GameNotifier
    extends StateNotifier<AsyncValue<List<GameModel>>> {
  final RawgService service;

  GameNotifier(this.service)
      : super(const AsyncLoading()) {
    fetchGames();
  }

  Future<void> fetchGames() async {
    try {
      state = const AsyncLoading();

      final games = await service.getGames();

      state = AsyncData(games);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> searchGames(String keyword) async {
    try {
      state = const AsyncLoading();

      final games = keyword.isEmpty
          ? await service.getGames()
          : await service.searchGames(keyword);

      state = AsyncData(games);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
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