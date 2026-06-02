class GameModel {
  final int id;
  final String name;
  final String backgroundImage;
  final double rating;
  final String releasedDate;
  final List<String> platforms;
  final String description;

  GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
    required this.releasedDate,
    required this.platforms,
    required this.description,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      backgroundImage: json['background_image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      releasedDate: json['released'] ?? '-',
      platforms: (json['platforms'] as List?)
              ?.map(
                (platform) =>
                    platform['platform']['name'].toString(),
              )
              .toList() ??
          [],
      description: json['description_raw'] ?? '',
    );
  }
}