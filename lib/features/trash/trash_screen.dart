import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme.dart';
import '../../core/database.dart';
import '../../shared/widgets/glass_card.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  List<Map<String, dynamic>> _deletedPhotos = [];
  final Set<String> _selectedPhotoIds = {};
  bool _loading = true;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadDeletedPhotos();
  }

  Future<void> _loadDeletedPhotos() async {
    final db = await DatabaseService.instance.database;
    final photos = await db.query('deleted_photos', orderBy: 'deleted_at DESC');
    if (mounted) {
      setState(() {
        _deletedPhotos = photos;
        _loading = false;
      });
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedPhotoIds.contains(id)) {
        _selectedPhotoIds.remove(id);
        if (_selectedPhotoIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedPhotoIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _restorePhotos(List<Map<String, dynamic>> photos) async {
    for (final photo in photos) {
      final photoId = photo['photo_id'] as String;
      final size = photo['file_size'] as int? ?? 0;
      await DatabaseService.instance.removeFromTrash(photoId);
      await DatabaseService.instance.updateStats(
        deleted: -1,
        spaceFreed: -size,
        reviewed: -1,
      );
    }

    await _loadDeletedPhotos();
    setState(() {
      _selectedPhotoIds.clear();
      _isSelectionMode = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${photos.length} photos restored')),
      );
    }
  }

  Future<void> _deletePermanently(List<String> ids) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Permanently?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will delete ${ids.length} items from your device forever.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PhotoManager.editor.deleteWithIds(ids);
      final db = await DatabaseService.instance.database;
      for (final id in ids) {
        await db.delete('deleted_photos', where: 'photo_id = ?', whereArgs: [id]);
      }
      await _loadDeletedPhotos();
      setState(() {
        _selectedPhotoIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                  : _deletedPhotos.isEmpty
                      ? _buildEmptyState()
                      : MasonryGridView.count(
                          padding: const EdgeInsets.all(16),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: _deletedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = _deletedPhotos[index];
                            final id = photo['photo_id'] as String;
                            final isSelected = _selectedPhotoIds.contains(id);

                            return _TrashGridItem(
                              photo: photo,
                              isSelected: isSelected,
                              isSelectionMode: _isSelectionMode,
                              onToggleSelection: () => _toggleSelection(id),
                            ).animate().fadeIn(delay: (index % 10 * 50).ms).slideY(begin: 0.1);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode ? _buildBatchActions() : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSelectionMode ? '${_selectedPhotoIds.length} Selected' : 'Recently Deleted',
                style: AppTheme.headingStyle.copyWith(fontSize: 28),
              ),
              Text(
                '${_deletedPhotos.length} items to clean',
                style: AppTheme.captionStyle,
              ),
            ],
          ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() {
                _selectedPhotoIds.clear();
                _isSelectionMode = false;
              }),
            )
          else if (_deletedPhotos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppTheme.deleteColor, size: 28),
              onPressed: () => _deletePermanently(_deletedPhotos.map((p) => p['photo_id'] as String).toList()),
            ).animate().shake(),
        ],
      ),
    );
  }

  Widget _buildBatchActions() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white),
            onPressed: () {
              final selected = _deletedPhotos.where((p) => _selectedPhotoIds.contains(p['photo_id'])).toList();
              _restorePhotos(selected);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.deleteColor),
            onPressed: () => _deletePermanently(_selectedPhotoIds.toList()),
          ),
        ],
      ),
    ).animate().scale(curve: Curves.easeOutBack);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'Trash is empty',
            style: AppTheme.bodyStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Marked photos will appear here.',
            style: AppTheme.captionStyle,
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _TrashGridItem extends StatelessWidget {
  final Map<String, dynamic> photo;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onToggleSelection;

  const _TrashGridItem({
    required this.photo,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final photoId = photo['photo_id'] as String;

    return GestureDetector(
      onLongPress: onToggleSelection,
      onTap: isSelectionMode ? onToggleSelection : null,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: EdgeInsets.all(isSelected ? 8 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.3) : Colors.transparent,
        ),
        child: GlassCard(
          borderRadius: 20,
          opacity: 0.1,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FutureBuilder<AssetEntity?>(
                      future: AssetEntity.fromId(photoId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return AssetEntityImage(
                            snapshot.data!,
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize(400, 400),
                            fit: BoxFit.cover,
                          );
                        }
                        return Container(height: 150, color: Colors.white.withValues(alpha: 0.05));
                      },
                    ),
                    if (isSelected)
                      Container(
                        color: AppTheme.accentColor.withValues(alpha: 0.4),
                        child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
                      ).animate().scale(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        photo['filename'] ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                    if (!isSelectionMode)
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
