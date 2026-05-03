import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../shared/widgets/media_viewer.dart';
import '../swipe/swipe_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(favoriteAssetListProvider);
    final topPadding = MediaQuery.of(context).padding.top + 64;

    return Column(
      children: [
        SizedBox(height: topPadding),
        assetsAsync.when(
          data: (assets) => assets.isEmpty 
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${assets.length} favorites',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ).animate(key: ValueKey(assets.length)).fadeIn().scale(begin: const Offset(0.8, 0.8)),
              ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: assetsAsync.when(
            data: (assets) {
              if (assets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('No favorites yet'),
                    ],
                  ).animate().fadeIn().scale(),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: assets.length,
                itemBuilder: (context, i) {
                  final asset = assets[i];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MediaViewer(asset: asset)),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AssetEntityImage(
                            asset,
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize.square(350),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) {
                                return child.animate().fadeIn(duration: 400.ms);
                              }
                              return Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ).animate(onPlay: (controller) => controller.repeat())
                               .shimmer(duration: 1200.ms, color: Theme.of(context).colorScheme.surface);
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Theme.of(context).colorScheme.errorContainer,
                              child: const Icon(Icons.error_outline),
                            ),
                          ),
                          if (asset.type == AssetType.video)
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.favorite, color: Colors.red, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (i * 50).ms, duration: 300.ms).moveY(begin: 20, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
