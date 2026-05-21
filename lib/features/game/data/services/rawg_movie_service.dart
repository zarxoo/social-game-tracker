
import '../models/game_movie_model.dart';
import 'package:dio/dio.dart';

class RawgMovieService {
  final Dio dio;

  RawgMovieService({
    required this.dio,
  });

  Future<List<GameMovieModel>> getGameMovies({
    required int gameId,
    required String apiKey,
  }) async {
    try {
      final response = await dio.get(
        'https://api.rawg.io/api/games/$gameId/movies',
        queryParameters: {
          'key': apiKey,
        },
      );

      final results = response.data['results'] as List? ?? [];

      return results
          .map((movie) => GameMovieModel.fromJson(movie))
          .where((movie) => movie.hasVideo)
          .toList();
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['detail'] ??
            'Gagal mengambil trailer game dari RAWG',
      );
    } catch (_) {
      throw Exception('Terjadi kesalahan saat mengambil trailer game');
    }
  }
}