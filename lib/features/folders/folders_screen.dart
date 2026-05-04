import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../shared/widgets/media_viewer.dart';
import '../../core/theme.dart';
import '../swipe/swipe_provider.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);
    final selected = ref.watch(selectedAlbumProvider);
    final assetsAsync = ref.watch(editorAssetListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Library',
          style: AppTheme.headingStyle(context).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: cs.onSurface),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Album: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: albumsAsync.when(
                    data: (albums) {
                      if (albums.isEmpty) return const Text('No albums');
                      final value = selected?.id ?? '';
                      return DropdownButton<String>(
                        isExpanded: true,
                        value: albums.any((a) => a.id == value) ? value : '',
                        underline: const SizedBox.shrink(),
                        onChanged: (id) {
                          if (id == null) return;
                          final album = id == '' ? null : albums.firstWhere((a) => a.id == id);
                          ref.read(selectedAlbumProvider.notifier).setAlbum(album);
                        },
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Included')),
                          ...albums.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                        ],
                      );
                    },
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Error loading albums'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: assetsAsync.when(
              data: (assets) {
                if (assets.isEmpty) {
                  return const Center(child: Text('No media found'));
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
                                  color: cs.surfaceContainerHighest,
                                ).animate(onPlay: (controller) => controller.repeat())
                                 .shimmer(duration: 1200.ms, color: cs.surface);
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: cs.errorContainer,
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

