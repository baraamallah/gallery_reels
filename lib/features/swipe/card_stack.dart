import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'swipe_provider.dart';
import 'swipe_card.dart';
import '../../shared/models/swipe_models.dart';
import '../../core/haptics.dart';
import '../../core/database.dart';

class CardStack extends ConsumerWidget {
  final List<AssetEntity> assets;

  const CardStack({super.key, required this.assets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(swipeIndexProvider);
    
    if (currentIndex >= assets.length) {
      return const Center(
        child: Text('All caught up!', style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    // Get the next 3 assets
    final visibleAssets = assets.skip(currentIndex).take(3).toList();

    return Stack(
      children: visibleAssets.asMap().entries.map((entry) {
        final index = entry.key; // 0 is top, 1 is middle, 2 is back
        final asset = entry.value;

        return _buildStackedCard(
          context: context,
          ref: ref,
          asset: asset,
          position: index,
          total: visibleAssets.length,
        );
      }).toList().reversed.toList(), // Reverse so index 0 (top) is drawn last
    );
  }

  Widget _buildStackedCard({
    required BuildContext context,
    required WidgetRef ref,
    required AssetEntity asset,
    required int position,
    required int total,
  }) {
    // position 0: Top card (draggable)
    // position 1: Middle card
    // position 2: Back card

    if (position == 0) {
      return SwipeCard(
        key: ValueKey(asset.id),
        asset: asset,
        onSwiped: (direction) => _handleSwipe(ref, asset, direction),
      );
    }

    // Static background cards
    final scale = 1.0 - (position * 0.02);
    // don't offset y heavily, just scale down behind
    final opacity = 1.0 - (position * 0.3);

    return Align(
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 60,
                  spreadRadius: -15,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize(500, 500),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSwipe(WidgetRef ref, AssetEntity asset, SwipeDirection direction) async {
    HapticHelper.medium();

    // Log action to undo stack
    final action = SwipeAction(
      asset: asset,
      direction: direction,
      timestamp: DateTime.now(),
    );
    ref.read(undoStackProvider.notifier).push(action);

    // Perform native action
    switch (direction) {
      case SwipeDirection.left: // Trash
        HapticHelper.heavy();
        
        final file = await asset.file;
        final size = await file?.length() ?? 0;
        
        await DatabaseService.instance.addToTrash(asset.id, asset.title, size);
        await DatabaseService.instance.updateStats(deleted: 1, spaceFreed: size);
        break;
      case SwipeDirection.right: // Keep
        break;
      case SwipeDirection.up: // Tag
        break;
      case SwipeDirection.down: // Share
        HapticHelper.medium();
        final file = await asset.file;
        if (file != null) {
          await Share.shareXFiles([XFile(file.path)]);
        }
        break;
    }

    // Update stats
    await DatabaseService.instance.updateStats(reviewed: 1);

    // Move to next card
    ref.read(swipeIndexProvider.notifier).next();
  }
}
