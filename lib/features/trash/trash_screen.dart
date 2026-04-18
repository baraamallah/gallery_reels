import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedPhotos();
  }

  Future<void> _loadDeletedPhotos() async {
    final db = await DatabaseService.instance.database;
    final photos = await db.query('deleted_photos', orderBy: 'deleted_at DESC');
    setState(() {
      _deletedPhotos = photos;
      _loading = false;
    });
  }

  Future<void> _restorePhoto(Map<String, dynamic> photo) async {
    final photoId = photo['photo_id'] as String;
    final size = photo['file_size'] as int? ?? 0;

    await DatabaseService.instance.removeFromTrash(photoId);
    await DatabaseService.instance.updateStats(
      deleted: -1,
      spaceFreed: -size,
      reviewed: -1,
    );

    await _loadDeletedPhotos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo restored')),
      );
    }
  }

  Future<void> _emptyTrash() async {
    if (_deletedPhotos.isEmpty) return;

    final photoIds = _deletedPhotos.map((p) => p['photo_id'] as String).toList();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Empty Trash?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently delete ${photoIds.length} photos from your device. This action cannot be undone.',
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
      await PhotoManager.editor.deleteWithIds(photoIds);
      final db = await DatabaseService.instance.database;
      await db.delete('deleted_photos');
      await _loadDeletedPhotos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trash emptied successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently Deleted',
                        style: AppTheme.headingStyle.copyWith(fontSize: 28),
                      ),
                      Text(
                        '${_deletedPhotos.length} items to clean',
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                  if (_deletedPhotos.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: AppTheme.deleteColor, size: 28),
                      onPressed: _emptyTrash,
                    ).animate().shake(),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                  : _deletedPhotos.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _deletedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = _deletedPhotos[index];
                            return _TrashGridItem(
                              photo: photo,
                              onRestore: () => _restorePhoto(photo),
                            ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
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
  final VoidCallback onRestore;

  const _TrashGridItem({required this.photo, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final photoId = photo['photo_id'] as String;

    return GlassCard(
      borderRadius: 20,
      opacity: 0.1,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
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
                      return Container(color: Colors.white.withValues(alpha: 0.05));
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRestore,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restore, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
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
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
