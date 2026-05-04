import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/database.dart';
import '../../core/theme.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

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
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

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

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedIds.length} items?'),
        content: const Text('This deletes from your device and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _loading = true);
      try {
        await PhotoManager.editor.deleteWithIds(_selectedIds.toList());
        for (final id in _selectedIds) {
          await DatabaseService.instance.removeFromTrash(id);
        }
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Future<void> _bulkRestore() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _loading = true);
    for (final id in _selectedIds) {
      await DatabaseService.instance.removeFromTrash(id);
    }
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restored ${_selectedIds.length} items')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: _selectionMode ? null : _buildEmptyTrashFab(context),
      appBar: AppBar(
        backgroundColor: _selectionMode 
            ? cs.surfaceContainerHighest 
            : cs.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _selectionMode ? '${_selectedIds.length} selected' : 'Trash',
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
                  setState(() {
                    _selectedIds.addAll(_items.map((r) => r['photo_id'] as String));
                  });
                },
                tooltip: 'Select all',
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: _bulkRestore,
                tooltip: 'Restore selected',
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: _bulkDelete,
                tooltip: 'Delete selected',
              ),
            ]
          : [
              if (_items.isNotEmpty)
                IconButton(
                  icon: PhosphorIcon(PhosphorIcons.broom(), color: Colors.red),
                  onPressed: () => _emptyTrashAction(context),
                  tooltip: 'Empty Trash',
                ),
            ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(PhosphorIcons.trash(), size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      const Text('Trash is empty'),
                    ],
                  ).animate().fadeIn().scale(),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final row = _items[i];
                    final id = row['photo_id'] as String;
                    final filename = (row['filename'] as String?) ?? 'Unknown';
                    final deletedAtMs = row['deleted_at'] as int? ?? 0;
                    final deletedAt = DateTime.fromMillisecondsSinceEpoch(deletedAtMs);
                    final daysLeft = 30 - DateTime.now().difference(deletedAt).inDays;
                    final isSelected = _selectedIds.contains(id);

                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: isSelected ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      color: isSelected ? cs.primaryContainer.withValues(alpha: 0.3) : cs.surfaceContainerLow,
                      child: ListTile(
                        onLongPress: () => _toggleSelection(id),
                        onTap: _selectionMode ? () => _toggleSelection(id) : null,
                        leading: Stack(
                          children: [
                            FutureBuilder<AssetEntity?>(
                              future: AssetEntity.fromId(id),
                              builder: (context, snap) {
                                final entity = snap.data;
                                if (entity == null) return Container(width: 56, height: 56, color: cs.surfaceContainerHighest);
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: AssetEntityImage(
                                      entity,
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize.square(160),
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(color: cs.surfaceContainerHighest);
                                      },
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: cs.errorContainer,
                                        child: const Icon(Icons.error_outline, size: 20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        title: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(daysLeft > 0 ? '$daysLeft days left' : 'Expired', style: TextStyle(color: daysLeft < 5 ? Colors.red : cs.onSurfaceVariant)),
                        trailing: _selectionMode 
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(id),
                            )
                          : PopupMenuButton<String>(
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
    );
  }

  Future<void> _emptyTrashAction(BuildContext context) async {
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
      final ids = _items.map((r) => r['photo_id'] as String).toList();
      if (ids.isEmpty) return;
      
      setState(() => _loading = true);
      try {
        await PhotoManager.editor.deleteWithIds(ids);
        final db = await DatabaseService.instance.database;
        await db.delete('deleted_photos');
        await _load();
        if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Trash emptied')));
      } catch (e) {
        if (mounted) messenger.showSnackBar(SnackBar(content: Text('Failed to empty trash: $e')));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Widget _buildEmptyTrashFab(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () => _emptyTrashAction(context),
      icon: PhosphorIcon(PhosphorIcons.broom()),
      label: const Text('Empty Trash'),
      backgroundColor: Colors.red.shade800,
      foregroundColor: Colors.white,
    );
  }
}
