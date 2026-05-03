import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'video_player_widget.dart';

class MediaViewer extends StatelessWidget {
  final AssetEntity asset;

  const MediaViewer({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final isVideo = asset.type == AssetType.video;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          asset.title ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: isVideo
            ? VideoPlayerWidget(asset: asset)
            : InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: AssetEntityImage(
                  asset,
                  isOriginal: true,
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
              ),
      ),
    );
  }
}
