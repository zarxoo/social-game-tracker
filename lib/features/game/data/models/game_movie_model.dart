class GameMovieModel {
  final int id;
  final String name;
  final String preview;
  final String videoUrl;

  const GameMovieModel({
    required this.id,
    required this.name,
    required this.preview,
    required this.videoUrl,
  });

  factory GameMovieModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return GameMovieModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Game Trailer',
      preview: json['preview'] ?? '',
      videoUrl: data?['max'] ?? data?['480'] ?? '',
    );
  }

  bool get hasVideo => videoUrl.isNotEmpty;
}