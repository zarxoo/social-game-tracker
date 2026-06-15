import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String releaseDate;
  final double rating;
  final String genres;
  final String imageUrl;

  /// Isi ini kalau kamu punya banyak gambar/screenshot.
  /// Kalau kosong, card tetap pakai imageUrl utama.
  final List<String> imageUrls;

  final VoidCallback? onDetailPressed;

  const GameCard({
    super.key,
    required this.title,
    required this.releaseDate,
    required this.rating,
    required this.genres,
    required this.imageUrl,
    this.imageUrls = const [],
    this.onDetailPressed,
  });

  List<String> get displayImages {
    final images = <String>[
      if (imageUrl.trim().isNotEmpty) imageUrl.trim(),
      ...imageUrls.where((image) => image.trim().isNotEmpty),
    ];

    return images.toSet().toList();
  }

  List<String> get genreList {
    if (genres.trim().isEmpty) return [];

    return genres
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .take(3)
        .toList();
  }

  String get formattedRating {
    if (rating <= 0) return '-';
    return rating.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.26),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onDetailPressed,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GameImageSlider(
                imageUrls: displayImages,
                rating: formattedRating,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.heading2.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.55),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            releaseDate.trim().isEmpty || releaseDate == '-'
                                ? 'Release date unknown'
                                : 'Released $releaseDate',
                            style: AppTheme.subtitleText.copyWith(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.58),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          Icons.touch_app_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.42),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap detail',
                          style: AppTheme.subtitleText.copyWith(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.42),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (genreList.isNotEmpty)
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: genreList
                            .map(
                              (genre) => _GenreChip(
                                label: genre,
                              ),
                            )
                            .toList(),
                      )
                    else
                      Text(
                        'Genre information unavailable',
                        style: AppTheme.subtitleText.copyWith(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            genres.trim().isEmpty
                                ? 'Unknown genre'
                                : genres,
                            style: AppTheme.subtitleText.copyWith(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.42),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Colors.white.withOpacity(0.38),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final String rating;

  const _GameImageSlider({
    required this.imageUrls,
    required this.rating,
  });

  @override
  State<_GameImageSlider> createState() => _GameImageSliderState();
}

class _GameImageSliderState extends State<_GameImageSlider> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  bool get hasMultipleImages => widget.imageUrls.length > 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(22),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: widget.imageUrls.isEmpty
                ? const _ImageFallback()
                : PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.cover,
                        memCacheWidth: 700,
                        memCacheHeight: 400,
                        fadeInDuration: const Duration(milliseconds: 250),
                        placeholder: (context, url) => const _ImageLoading(),
                        errorWidget: (context, url, error) {
                          return const _ImageFallback();
                        },
                      );
                    },
                  ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.04),
                      Colors.black.withOpacity(0.78),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: _RatingBadge(
              rating: widget.rating,
            ),
          ),

          Positioned(
            left: 12,
            bottom: 12,
            child: _DiscoverBadge(
              hasMultipleImages: hasMultipleImages,
            ),
          ),

          if (hasMultipleImages)
            Positioned(
              right: 12,
              bottom: 15,
              child: _ImageCounter(
                currentIndex: _currentIndex,
                totalImages: widget.imageUrls.length,
              ),
            ),

          if (hasMultipleImages)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: _SliderIndicator(
                currentIndex: _currentIndex,
                totalImages: widget.imageUrls.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _SliderIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalImages;

  const _SliderIndicator({
    required this.currentIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalImages, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _ImageCounter extends StatelessWidget {
  final int currentIndex;
  final int totalImages;

  const _ImageCounter({
    required this.currentIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.56),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Text(
        '${currentIndex + 1}/$totalImages',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DiscoverBadge extends StatelessWidget {
  final bool hasMultipleImages;

  const _DiscoverBadge({
    required this.hasMultipleImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasMultipleImages
                ? Icons.swipe_rounded
                : Icons.explore_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            hasMultipleImages ? 'Swipe' : 'Discover',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final String rating;

  const _RatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasRating = rating != '-';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.64),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasRating ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppTheme.warningColor,
            size: 15,
          ),
          const SizedBox(width: 4),
          Text(
            hasRating ? rating : 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;

  const _GenreChip({
    required this.label,
  });

  IconData get genreIcon {
    final value = label.toLowerCase();

    if (value.contains('shooter')) {
      return Icons.radio_button_checked_rounded;
    }

    if (value.contains('action')) {
      return Icons.bolt_rounded;
    }

    if (value.contains('rpg') || value.contains('role-playing')) {
      return Icons.person_rounded;
    }

    if (value.contains('adventure')) {
      return Icons.explore_rounded;
    }

    if (value.contains('puzzle')) {
      return Icons.extension_rounded;
    }

    if (value.contains('strategy')) {
      return Icons.checklist_rounded;
    }

    if (value.contains('horror')) {
      return Icons.warning_rounded;
    }

    if (value.contains('fighting')) {
      return Icons.pan_tool_rounded;
    }

    if (value.contains('sports')) {
      return Icons.sports_soccer_rounded;
    }

    if (value.contains('racing')) {
      return Icons.speed_rounded;
    }

    if (value.contains('simulation')) {
      return Icons.settings_rounded;
    }

    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            genreIcon,
            color: Colors.white.withOpacity(0.74),
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTheme.subtitleText.copyWith(
              fontSize: 10,
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.videogame_asset_rounded,
            color: Colors.white.withOpacity(0.38),
            size: 34,
          ),
        ),
      ),
    );
  }
}