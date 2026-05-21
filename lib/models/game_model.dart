class GameModel {
  final int id;
  final String name;
  final String backgroundImage;
  final double rating;
  final String releasedDate;
  final List<String> platforms;

  GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
    required this.releasedDate,
    required this.platforms,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      backgroundImage: json['background_image'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      releasedDate: json['released'] ?? '-',
      platforms: (json['platforms'] as List?)
              ?.map(
                (platform) =>
                    platform['platform']?['name']?.toString() ?? '',
              )
              .where((platform) => platform.isNotEmpty)
              .toList() ??
          [],
    );
  }

  String get platformText {
    if (platforms.isEmpty) return 'Unknown Platform';
    return platforms.join(', ');
  }
}