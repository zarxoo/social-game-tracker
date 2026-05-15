import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/game_model.dart';

class RawgService {

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout:
          const Duration(seconds: 10),

      receiveTimeout:
          const Duration(seconds: 10),
    ),
  );

  // GET GAMES
  Future<List<GameModel>>
      getGames({
    int page = 1,
  }) async {

    try {

      final response =
          await _dio.get(

        '${ApiConstants.baseUrl}/games',

        queryParameters: {

          'key':
              ApiConstants.apiKey,

          'page': page,

          // SMALLER = SMOOTHER
          'page_size': 10,
        },
      );

      final List results =
          response.data['results'];

      return results
          .map(
            (game) =>
                GameModel.fromJson(
              game,
            ),
          )
          .toList();

    } catch (e) {

      throw Exception(
        'Failed to load games',
      );
    }
  }

  // SEARCH GAMES
  Future<List<GameModel>>
      searchGames(
    String keyword,
  ) async {

    try {

      final response =
          await _dio.get(

        '${ApiConstants.baseUrl}/games',

        queryParameters: {

          'key':
              ApiConstants.apiKey,

          'search': keyword,

          'page_size': 10,
        },
      );

      final List results =
          response.data['results'];

      return results
          .map(
            (game) =>
                GameModel.fromJson(
              game,
            ),
          )
          .toList();

    } catch (e) {

      throw Exception(
        'Failed to search games',
      );
    }
  }
}