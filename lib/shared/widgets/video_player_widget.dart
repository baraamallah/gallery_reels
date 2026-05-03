import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/log_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  final AssetEntity asset;

  const VideoPlayerWidget({super.key, required this.asset});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final file = await widget.asset.file;
    if (file == null) {
      LogService.instance.error(
          'Video file is null for asset ${widget.asset.id}');
      if (mounted) setState(() => _hasError = true);
      return;
    }

    _controller = VideoPlayerController.file(file);
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();
      LogService.instance
          .log('Video initialized and playing: ${widget.asset.id}');
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e, s) {
      LogService.instance.error(
          'Error initializing video player for asset ${widget.asset.id}', e, s);
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Error state
    if (_hasError) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            widget.asset,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize(800, 800),
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child.animate().fadeIn(duration: 400.ms);
              }
              return Container(
                color: Colors.white10,
              ).animate(onPlay: (controller) => controller.repeat())
               .shimmer(duration: 1200.ms, color: Colors.white24);
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
            ),
          ),
          const Center(
            child: Icon(Icons.error_outline_rounded,
                color: Colors.white54, size: 48),
          ),
        ],
      );
    }

    // Loading state: show thumbnail with a play icon overlay
    if (!_isInitialized || _controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            widget.asset,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize(800, 800),
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child.animate().fadeIn(duration: 400.ms);
              }
              return Container(
                color: Colors.white10,
              ).animate(onPlay: (controller) => controller.repeat())
               .shimmer(duration: 1200.ms, color: Colors.white24);
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
            ),
          ),
          // Subtle dark veil
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x33000000)),
          ),
          // Loading indicator with play overlay
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white70,
                    ),
                  ),
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Initialized — show actual video player
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            colors: VideoProgressColors(
              playedColor: Theme.of(context).colorScheme.primary,
              bufferedColor: Colors.white.withValues(alpha: 0.2),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
