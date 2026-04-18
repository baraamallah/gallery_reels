import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../swipe/swipe_provider.dart'; // To get photoList based on album
import '../../core/theme.dart';

// Represents "Album Details" or inside an album/tag
class FoldersScreen extends ConsumerStatefulWidget {
  const FoldersScreen({super.key});

  @override
  ConsumerState<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends ConsumerState<FoldersScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedAlbum = ref.watch(selectedAlbumProvider);
    final photoSource = ref.watch(photoListProvider);

    // We mock a title if none is selected
    final title = selectedAlbum?.name ?? 'Neon Nights';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Minimal Header (suppressing global nav technically, but we keep it inside scrollview for effect)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ALBUM', style: AppTheme.labelStyle),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        // Metadata pills
                        Row(
                          children: [
                            _buildMetaPill(Icons.photo_library, photoSource.value?.length.toString() ?? '...'),
                            const SizedBox(width: 12),
                            _buildMetaPill(Icons.calendar_month, 'Oct 2023'),
                          ],
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 32),

                        // Contextual Actions
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.share, size: 18, color: AppTheme.onSurface),
                                  const SizedBox(width: 8),
                                  Text('Share', style: AppTheme.bodyStyle.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow, size: 18, color: AppTheme.onSurface),
                                  const SizedBox(width: 8),
                                  Text('Slideshow', style: AppTheme.bodyStyle.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ),

                // Asymmetrical Gallery Grid
                photoSource.when(
                  data: (assets) {
                    if (assets.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text('No photos found', style: AppTheme.bodyStyle),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        itemBuilder: (context, index) {
                          // Create asymmetric layout by varying heights
                          final isFeatured = index == 0;
                          final isTall = index % 3 == 0 && index != 0;

                          double height = isFeatured ? 250 : (isTall ? 300 : 180);

                          return SizedBox(
                            height: height,
                            child: _GalleryItem(asset: assets[index], isFeatured: isFeatured),
                          ).animate().fadeIn(delay: (index % 10 * 50).ms).slideY(begin: 0.1);
                        },
                        childCount: assets.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                  ),
                  error: (e, s) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e', style: AppTheme.bodyStyle)),
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.checklist, color: AppTheme.primary),
            ).animate().scale(delay: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final AssetEntity asset;
  final bool isFeatured;

  const _GalleryItem({required this.asset, this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.surfaceContainerLow,
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AssetEntityImage(
              asset,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize(500, 500),
              fit: BoxFit.cover,
            ),
            if (isFeatured)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Featured', style: AppTheme.headingStyle.copyWith(fontSize: 16)),
                          Text('Oct 12, 2023', style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.favorite, color: AppTheme.onSurface, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
