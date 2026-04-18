import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'swipe_provider.dart';
import 'card_stack.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/models/swipe_models.dart';
import '../../core/theme.dart';
import '../../core/database.dart';

class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoListAsync = ref.watch(photoListProvider);
    final undoStack = ref.watch(undoStackProvider);
    final selectedAlbum = ref.watch(selectedAlbumProvider);
    final undoVisible = undoStack.isNotEmpty;
    final title = selectedAlbum?.name ?? 'All Photos';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Main content
          photoListAsync.when(
            data: (assets) => assets.isEmpty
                ? const Center(child: Text('No photos found', style: TextStyle(color: Colors.white)))
                : Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 120, left: 24, right: 24),
                    child: CardStack(assets: assets),
                  ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
            error: (e, stack) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
          ),

          // Undo Pill
          AnimatedPositioned(
            bottom: undoVisible ? 120 : -100,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: GlassCard(
              borderRadius: 30,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.undo, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  const Text('Action undone', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      final action = ref.read(undoStackProvider.notifier).pop();
                      if (action != null) {
                        ref.read(swipeIndexProvider.notifier).previous();
                        
                        // Handle DB restoration for deletions
                        if (action.direction == SwipeDirection.right) {
                          final file = await action.asset.file;
                          final size = await file?.length() ?? 0;
                          
                          await DatabaseService.instance.removeFromTrash(action.asset.id);
                          await DatabaseService.instance.updateStats(
                            deleted: -1, 
                            spaceFreed: -size,
                            reviewed: -1,
                          );
                        } else {
                          await DatabaseService.instance.updateStats(reviewed: -1);
                        }
                      }
                    },
                    child: const Text(
                      'UNDO',
                      style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Directions indicator (Subtle)
          Positioned(
            top: 60,
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTheme.headingStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swipe to clean',
                  style: AppTheme.captionStyle.copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
