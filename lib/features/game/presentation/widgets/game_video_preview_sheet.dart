import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';

class GameVideoPreviewSheet extends StatefulWidget {
  final String title;
  final String videoUrl;

  const GameVideoPreviewSheet({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<GameVideoPreviewSheet> createState() => _GameVideoPreviewSheetState();
}

class _GameVideoPreviewSheetState extends State<GameVideoPreviewSheet> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: true,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Video preview tidak bisa diputar';
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTheme.heading2.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  color: Colors.black,
                  child: _buildVideoContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTheme.subtitleText.copyWith(
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return Center(
        child: Text(
          'Preview tidak tersedia',
          style: AppTheme.subtitleText.copyWith(
            color: Colors.white70,
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _videoController.value.size.width,
        height: _videoController.value.size.height,
        child: Chewie(
          controller: _chewieController!,
        ),
      ),
    );
  }
}