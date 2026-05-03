import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/database.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('deleted_photos', orderBy: 'deleted_at DESC');
    if (!mounted) return;
    setState(() {
      _items = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 64;

    return Scaffold(
      floatingActionButton: _buildEmptyTrashFab(context),
      body: Column(
        children: [
        SizedBox(height: topPadding),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text('Trash is empty'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final row = _items[i];
                        final id = row['photo_id'] as String;
                        final filename = (row['filename'] as String?) ?? 'Unknown';
                        final deletedAtMs = row['deleted_at'] as int? ?? 0;
                        final deletedAt = DateTime.fromMillisecondsSinceEpoch(deletedAtMs);
                        final daysLeft = 30 - DateTime.now().difference(deletedAt).inDays;

                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: FutureBuilder<AssetEntity?>(
                              future: AssetEntity.fromId(id),
                              builder: (context, snap) {
                                final entity = snap.data;
                                if (entity == null) return const SizedBox(width: 56, height: 56);
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: AssetEntityImage(
                                      entity,
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize.square(160),
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
                                        child: const Icon(Icons.error_outline, size: 20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            title: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(daysLeft > 0 ? '$daysLeft days left' : 'Expired'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'restore') {
                                  await DatabaseService.instance.removeFromTrash(id);
                                  await _load();
                                } else if (v == 'delete') {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete permanently?'),
                                      content: const Text('This deletes from your device and cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await PhotoManager.editor.deleteWithIds([id]);
                                    await DatabaseService.instance.removeFromTrash(id);
                                    await _load();
                                  }
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'restore', child: Text('Remove from in-app trash')),
                                PopupMenuItem(value: 'delete', child: Text('Delete permanently')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
    );
  }

  Widget _buildEmptyTrashFab(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Empty Trash?'),
            content: const Text('This will permanently delete ALL items in the trash from your device. This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Empty Trash'),
              ),
            ],
          ),
        );

        if (ok == true) {
          // Collect all IDs
          final ids = _items.map((r) => r['photo_id'] as String).toList();
          if (ids.isEmpty) return;
          
          try {
            await PhotoManager.editor.deleteWithIds(ids);
            
            // If successful, remove from DB
            final db = await DatabaseService.instance.database;
            await db.delete('deleted_photos');
            await _load();
            
            if (mounted) {
              messenger.showSnackBar(const SnackBar(content: Text('Trash emptied')));
            }
          } catch (e) {
            if (mounted) {
              messenger.showSnackBar(SnackBar(content: Text('Failed to empty trash: $e')));
            }
          }
        }
      },
      icon: const Icon(Icons.delete_sweep),
      label: const Text('Empty Trash'),
      backgroundColor: Colors.red.shade800,
      foregroundColor: Colors.white,
    );
  }
}
