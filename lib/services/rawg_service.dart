import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/game_model.dart';

class RawgService {
  final Dio _dio = Dio();

  Future<List<GameModel>> getGames() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/games',
        queryParameters: {
          'key': ApiConstants.apiKey,
        },
      );

      final List results = response.data['results'];

      return results
          .map((game) => GameModel.fromJson(game))
          .toList();
    } catch (e) {
      throw Exception('Failed to load games');
    }
  }

  Future<List<GameModel>> searchGames(
    String keyword,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/games',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'search': keyword,
        },
      );

      final List results = response.data['results'];

      return results
          .map((game) => GameModel.fromJson(game))
          .toList();
    } catch (e) {
      throw Exception('Failed to search games');
    }
  }
}