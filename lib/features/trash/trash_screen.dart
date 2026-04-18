import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../core/database.dart';
import '../../core/theme.dart';
import '../../shared/widgets/glass_card.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  List<Map<String, dynamic>> _deletedPhotos = [];
  bool _loading = true;
  final Set<String> _selectedPhotoIds = {};
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
        SnackBar(content: Text('${photos.length} photos restored', style: AppTheme.bodyStyle)),
      );
    }
  }

  Future<void> _deletePermanently(List<String> ids) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Permanently?', style: AppTheme.headingStyle.copyWith(color: AppTheme.onSurface)),
        content: Text(
          'This will delete ${ids.length} items from your device forever.',
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL', style: AppTheme.labelStyle)),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('DELETE', style: AppTheme.labelStyle.copyWith(color: AppTheme.error)),
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

  String _formatTotalSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < suffixes.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    final totalBytes = _deletedPhotos.fold<int>(0, (sum, p) => sum + (p['file_size'] as int? ?? 0));
    final spaceText = _formatTotalSize(totalBytes);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Glassmorphism Banner
            Padding(
              padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      border: Border(top: BorderSide(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1))),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 16)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.errorContainer.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_sweep, color: AppTheme.error, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Items in trash are deleted after 30 days', style: AppTheme.headingStyle.copyWith(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('You have ${_deletedPhotos.length} items taking up $spaceText of space.', style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _deletedPhotos.isEmpty ? null : () => _restorePhotos(_deletedPhotos),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.surfaceVariant.withValues(alpha: 0.3),
                                  foregroundColor: AppTheme.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('Restore All', style: AppTheme.labelStyle),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _deletedPhotos.isEmpty ? null : () => _deletePermanently(_deletedPhotos.map((p) => p['photo_id'] as String).toList()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorContainer,
                                  foregroundColor: AppTheme.errorContainer,
                                  elevation: 8,
                                  shadowColor: AppTheme.errorContainer.withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('Empty Trash', style: AppTheme.labelStyle.copyWith(color: const Color(0xFFFFA8A3))), // on-error-container
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1),

            // Main Grid
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _deletedPhotos.isEmpty
                      ? _buildEmptyState()
                      : MasonryGridView.count(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: _deletedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = _deletedPhotos[index];
                            final id = photo['photo_id'] as String;
                            final isSelected = _selectedPhotoIds.contains(id);

                            // Asymmetric grid: make some items taller
                            final isLarge = index == 0;
                            final isTall = index == 3;

                            return SizedBox(
                              height: isLarge ? 280 : (isTall ? 320 : 160),
                              child: _TrashGridItem(
                                photo: photo,
                                isSelected: isSelected,
                                isSelectionMode: _isSelectionMode,
                                onToggleSelection: () => _toggleSelection(id),
                              ),
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

  Widget _buildBatchActions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 100),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 30,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore, color: AppTheme.onSurface),
              onPressed: () {
                final selected = _deletedPhotos.where((p) => _selectedPhotoIds.contains(p['photo_id'])).toList();
                _restorePhotos(selected);
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: () => _deletePermanently(_selectedPhotoIds.toList()),
            ),
          ],
        ),
      ).animate().scale(curve: Curves.easeOutBack),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 80, color: AppTheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('Trash is empty', style: AppTheme.bodyStyle.copyWith(fontSize: 18)),
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
    // Calculate days left (mock 30 days minus days since deleted)
    final deletedAt = DateTime.parse(photo['deleted_at'] as String? ?? DateTime.now().toIso8601String());
    final daysLeft = 30 - DateTime.now().difference(deletedAt).inDays;

    return GestureDetector(
      onLongPress: onToggleSelection,
      onTap: isSelectionMode ? onToggleSelection : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.surfaceContainerLow,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 4)),
          ],
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.outlineVariant.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              FutureBuilder<AssetEntity?>(
                future: AssetEntity.fromId(photoId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]), // Grayscale
                      child: Opacity(
                        opacity: 0.6,
                        child: AssetEntityImage(
                          snapshot.data!,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize(400, 400),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return Container(color: Colors.white.withValues(alpha: 0.05));
                },
              ),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$daysLeft DAYS LEFT', style: AppTheme.labelStyle.copyWith(fontSize: 10, color: AppTheme.error)),
                          Text(photo['filename'] ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.headingStyle.copyWith(fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restore, size: 14, color: AppTheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),

              // Checkbox indicator
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primary : AppTheme.surface.withValues(alpha: 0.3),
                    border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant.withValues(alpha: 0.5), width: 2),
                  ),
                  child: isSelected ? Icon(Icons.check, size: 16, color: AppTheme.surface) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
