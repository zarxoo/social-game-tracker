import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';
import 'package:social_game_tracker/features/game/data/models/game_movie_model.dart';
import 'package:social_game_tracker/features/game/data/services/rawg_movie_service.dart';
import 'package:social_game_tracker/features/game/presentation/widgets/game_video_preview_sheet.dart';

class GameCard extends StatefulWidget {
  final int gameId;
  final String title;
  final String releaseDate;
  final double rating;
  final String platforms;
  final String imageUrl;
  final String rawgApiKey;
  final VoidCallback? onDetailPressed;

  const GameCard({
    super.key,
    required this.gameId,
    required this.title,
    required this.releaseDate,
    required this.rating,
    required this.platforms,
    required this.imageUrl,
    required this.rawgApiKey,
    this.onDetailPressed,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  late final RawgMovieService _movieService;

  bool _isLoadingPreview = false;
  List<GameMovieModel>? _cachedMovies;

  @override
  void initState() {
    super.initState();

    _movieService = RawgMovieService(
      dio: Dio(),
    );
  }

  List<String> get platformList {
    if (widget.platforms.trim().isEmpty) return [];

    return widget.platforms
        .split(',')
        .map((platform) => platform.trim())
        .where((platform) => platform.isNotEmpty)
        .take(3)
        .toList();
  }

  Future<void> _handlePreviewPressed() async {
    if (_isLoadingPreview) return;

    setState(() {
      _isLoadingPreview = true;
    });

    try {
      final movies = _cachedMovies ??
          await _movieService.getGameMovies(
            gameId: widget.gameId,
            apiKey: widget.rawgApiKey,
          );

      _cachedMovies = movies;

      if (!mounted) return;

      if (movies.isEmpty) {
        _showSnackBar('Trailer belum tersedia untuk game ini');
        return;
      }

      final selectedMovie = movies.first;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return GameVideoPreviewSheet(
            title: widget.title,
            videoUrl: selectedMovie.videoUrl,
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Gagal membuka preview trailer');
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoadingPreview = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onDetailPressed,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GameImageHeader(
                imageUrl: widget.imageUrl,
                rating: widget.rating,
                isLoadingPreview: _isLoadingPreview,
                onPreviewPressed: _handlePreviewPressed,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTheme.heading2.copyWith(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Colors.white.withOpacity(0.55),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.releaseDate.isNotEmpty
                                ? 'Released ${widget.releaseDate}'
                                : 'Release date unknown',
                            style: AppTheme.subtitleText.copyWith(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (platformList.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: platformList.map((platform) {
                          return _PlatformChip(
                            label: platform,
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'No platform information',
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
                            widget.platforms,
                            style: AppTheme.subtitleText.copyWith(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.45),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 12),

                        _DetailButton(
                          onPressed: widget.onDetailPressed,
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

class _GameImageHeader extends StatelessWidget {
  final String imageUrl;
  final double rating;
  final bool isLoadingPreview;
  final VoidCallback onPreviewPressed;

  const _GameImageHeader({
    required this.imageUrl,
    required this.rating,
    required this.isLoadingPreview,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 700,
                    memCacheHeight: 400,
                    fadeInDuration: const Duration(milliseconds: 250),
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return const _ImageFallback();
                    },
                  )
                : const _ImageFallback(),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.78),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: _RatingBadge(
              rating: rating,
            ),
          ),

          Positioned(
            left: 12,
            bottom: 12,
            child: _PreviewButton(
              isLoading: isLoadingPreview,
              onPressed: onPreviewPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _PreviewButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.62),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 17,
                ),

              const SizedBox(width: 5),

              Text(
                isLoading ? 'Loading' : 'Preview',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppTheme.warningColor,
            size: 15,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
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

class _PlatformChip extends StatelessWidget {
  final String label;

  const _PlatformChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Text(
        label,
        style: AppTheme.subtitleText.copyWith(
          fontSize: 10,
          color: Colors.white.withOpacity(0.78),
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _DetailButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.arrow_forward_rounded,
        size: 14,
      ),
      label: const Text('Detail'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
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
        child: Icon(
          Icons.videogame_asset_rounded,
          color: Colors.white.withOpacity(0.35),
          size: 48,
        ),
      ),
    );
  }
}