import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../shared/widgets/media_viewer.dart';
import '../../core/database.dart';
import '../../core/theme.dart';
import '../swipe/swipe_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
        _selectionMode = true;
      }
    });
  }

  Future<void> _bulkUnfavorite() async {
    if (_selectedIds.isEmpty) return;
    for (final id in _selectedIds) {
      await DatabaseService.instance.untagPhoto(id, '2');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${_selectedIds.length} from favorites')),
      );
      setState(() {
        _selectionMode = false;
        _selectedIds.clear();
      });
    }
    ref.invalidate(favoriteAssetListProvider);
  }

  Future<void> _bulkMoveToTrash(List<AssetEntity> allAssets) async {
    if (_selectedIds.isEmpty) return;
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${_selectedIds.length} to trash?'),
        content: const Text('They will be moved to the in-app trash folder.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move to Trash')),
        ],
      ),
    );

    if (ok == true) {
      for (final id in _selectedIds) {
        final asset = allAssets.firstWhere((a) => a.id == id);
        await DatabaseService.instance.addToTrash(id, asset.title, null);
        await DatabaseService.instance.untagPhoto(id, '2');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved ${_selectedIds.length} items to trash')),
        );
        setState(() {
          _selectionMode = false;
          _selectedIds.clear();
        });
      }
      ref.invalidate(favoriteAssetListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(favoriteAssetListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: _selectionMode 
            ? cs.surfaceContainerHighest 
            : cs.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _selectionMode ? '${_selectedIds.length} selected' : 'Favorites',
          style: AppTheme.headingStyle(context).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        leading: _selectionMode 
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _selectionMode = false;
                _selectedIds.clear();
              }),
            )
          : IconButton(
              icon: Icon(Icons.menu, color: cs.onSurface),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        actions: _selectionMode 
          ? [
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: () {
                  assetsAsync.whenData((assets) {
                    setState(() {
                      _selectedIds.addAll(assets.map((a) => a.id));
                    });
                  });
                },
                tooltip: 'Select all',
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: _bulkUnfavorite,
                tooltip: 'Unfavorite selected',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => assetsAsync.whenData((assets) => _bulkMoveToTrash(assets)),
                tooltip: 'Move to trash',
              ),
            ]
          : null,
      ),
      body: Column(
        children: [
          assetsAsync.when(
            data: (assets) => assets.isEmpty 
              ? const SizedBox.shrink()
              : _selectionMode ? const SizedBox.shrink() : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${assets.length} favorites',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
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
                        Icon(Icons.favorite_border, size: 64, color: cs.primary.withValues(alpha: 0.3)),
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
                    final isSelected = _selectedIds.contains(asset.id);
                    return InkWell(
                      onLongPress: () => _toggleSelection(asset.id),
                      onTap: () {
                        if (_selectionMode) {
                          _toggleSelection(asset.id);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MediaViewer(asset: asset)),
                          );
                        }
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
                            if (!_selectionMode)
                              const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.favorite, color: Colors.red, size: 16),
                                ),
                              ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  color: cs.primary.withValues(alpha: 0.4),
                                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (i * 20).ms, duration: 300.ms);
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
