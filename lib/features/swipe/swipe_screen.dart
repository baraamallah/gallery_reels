import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'swipe_provider.dart';
import 'card_stack.dart';
import '../../shared/models/swipe_models.dart';
import '../../core/theme.dart';
import '../../core/database.dart';
import '../../core/haptics.dart';
import 'dart:ui';

class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoListAsync = ref.watch(photoListProvider);
    final undoStack = ref.watch(undoStackProvider);
    final undoVisible = undoStack.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Main content: Full screen image area
          photoListAsync.when(
            data: (assets) => assets.isEmpty
                ? Center(
                    child: Text('No photos found', style: AppTheme.bodyStyle),
                  )
                : Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
                      child: CardStack(assets: assets),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            error: (e, stack) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
          ),

          // Floating Glass Categorization Panel
          Positioned(
            bottom: 112, // Above the bottom nav
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2025).withValues(alpha: 0.6), // surface-container-high
                    borderRadius: BorderRadius.circular(24),
                    border: Border(
                      top: BorderSide(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gesture Hints
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.keyboard_double_arrow_left, size: 14, color: AppTheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('TRASH', style: AppTheme.headingStyle.copyWith(fontSize: 12, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('KEEP', style: AppTheme.headingStyle.copyWith(fontSize: 12, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5)),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_double_arrow_right, size: 14, color: AppTheme.onSurfaceVariant),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Delete Action
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceContainer,
                              border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.error),
                              onPressed: () async {
                                HapticHelper.medium();
                                final currentAssets = photoListAsync.value ?? [];
                                final currentIndex = ref.read(swipeIndexProvider);
                                if (currentIndex < currentAssets.length) {
                                  final asset = currentAssets[currentIndex];

                                  final action = SwipeAction(asset: asset, direction: SwipeDirection.left, timestamp: DateTime.now());
                                  ref.read(undoStackProvider.notifier).push(action);

                                  final file = await asset.file;
                                  final size = await file?.length() ?? 0;
                                  await DatabaseService.instance.addToTrash(asset.id, asset.title, size);
                                  await DatabaseService.instance.updateStats(deleted: 1, spaceFreed: size, reviewed: 1);

                                  ref.read(swipeIndexProvider.notifier).next();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Quick Album Action
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
                              border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.create_new_folder, color: AppTheme.onSurface, size: 20),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Keep Action (Primary)
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.primary, AppTheme.primaryContainer],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.favorite, color: Color(0xFF004D57), size: 28), // on-primary-container
                              onPressed: () async {
                                HapticHelper.medium();
                                final currentAssets = photoListAsync.value ?? [];
                                final currentIndex = ref.read(swipeIndexProvider);
                                if (currentIndex < currentAssets.length) {
                                  final asset = currentAssets[currentIndex];

                                  final action = SwipeAction(asset: asset, direction: SwipeDirection.right, timestamp: DateTime.now());
                                  ref.read(undoStackProvider.notifier).push(action);

                                  await DatabaseService.instance.updateStats(reviewed: 1);
                                  ref.read(swipeIndexProvider.notifier).next();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Undo Pill (Re-styled)
          AnimatedPositioned(
            bottom: undoVisible ? 250 : -100, // Above the panel
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.undo, color: AppTheme.onSurface, size: 18),
                      const SizedBox(width: 8),
                      Text('Action undone', style: AppTheme.bodyStyle.copyWith(fontSize: 14)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          HapticHelper.light();
                          final action = ref.read(undoStackProvider.notifier).pop();
                          if (action != null) {
                            ref.read(swipeIndexProvider.notifier).previous();

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
                        child: Text(
                          'UNDO',
                          style: AppTheme.labelStyle.copyWith(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
