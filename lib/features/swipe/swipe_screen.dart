import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_settings.dart';
import '../../core/theme.dart';
import 'clean_reel_screen.dart';
import 'swipe_provider.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  final bool folderSelectOnly;

  const SwipeScreen({super.key, this.folderSelectOnly = false});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final Set<String> _selectedAlbumIds = {};

  @override
  void initState() {
    super.initState();
    final existing = ref.read(appSettingsProvider).includedAlbumIds;
    _selectedAlbumIds.addAll(existing);
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final settings = ref.watch(appSettingsProvider);
    final topPadding = MediaQuery.of(context).padding.top + 64;

    return Column(
      children: [
        SizedBox(height: topPadding),
        Expanded(
          child: albumsAsync.when(
            data: (albums) {
              if (albums.isEmpty) {
                return _PermissionOrEmpty();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filters',
                          style: AppTheme.headingStyle(context).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _FilterChip(
                              label: 'Photos',
                              selected: settings.mediaMode == MediaMode.photosOnly,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setMediaMode(MediaMode.photosOnly),
                            ),
                            _FilterChip(
                              label: 'Videos',
                              selected: settings.mediaMode == MediaMode.videosOnly,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setMediaMode(MediaMode.videosOnly),
                            ),
                            _FilterChip(
                              label: 'Both',
                              selected: settings.mediaMode == MediaMode.photosAndVideos,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setMediaMode(MediaMode.photosAndVideos),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sort',
                          style: AppTheme.headingStyle(context).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _FilterChip(
                              label: 'Newest First',
                              selected: settings.sortMode == SortMode.newestFirst,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.newestFirst),
                            ),
                            _FilterChip(
                              label: 'Oldest First',
                              selected: settings.sortMode == SortMode.oldestFirst,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.oldestFirst),
                            ),
                            _FilterChip(
                              label: 'Largest First',
                              selected: settings.sortMode == SortMode.largestFirst,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.largestFirst),
                            ),
                            _FilterChip(
                              label: 'Smallest First',
                              selected: settings.sortMode == SortMode.smallestFirst,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.smallestFirst),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Min Size',
                          style: AppTheme.headingStyle(context).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _FilterChip(
                              label: 'All Sizes',
                              selected: settings.minSizeEditor == null,
                              onSelected: (_) => ref.read(appSettingsProvider.notifier).setMinSizeEditor(null),
                            ),
                            _FilterChip(
                              label: '> 5MB',
                              selected: settings.minSizeEditor == 5 * 1024 * 1024,
                              onSelected: (s) => ref.read(appSettingsProvider.notifier).setMinSizeEditor(s ? 5 * 1024 * 1024 : null),
                            ),
                            _FilterChip(
                              label: '> 20MB',
                              selected: settings.minSizeEditor == 20 * 1024 * 1024,
                              onSelected: (s) => ref.read(appSettingsProvider.notifier).setMinSizeEditor(s ? 20 * 1024 * 1024 : null),
                            ),
                            _FilterChip(
                              label: '> 100MB',
                              selected: settings.minSizeEditor == 100 * 1024 * 1024,
                              onSelected: (s) => ref.read(appSettingsProvider.notifier).setMinSizeEditor(s ? 100 * 1024 * 1024 : null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Folders',
                              style: AppTheme.headingStyle(context).copyWith(fontSize: 18),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _selectedAlbumIds.clear()),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                        Text(
                          'Choose folders to include. Leave empty to include everything.',
                          style: AppTheme.bodyStyle(context).copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: albums.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final selected = _selectedAlbumIds.contains(album.id);
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: Icon(selected ? Icons.check_circle : Icons.folder_outlined, color: selected ? Theme.of(context).colorScheme.primary : null),
                            title: Text(album.name),
                            subtitle: FutureBuilder<int>(
                              future: album.assetCountAsync,
                              builder: (context, snapshot) {
                                final c = snapshot.data;
                                return Text(c == null ? 'Loading…' : '$c items');
                              },
                            ),
                            trailing: Checkbox(
                              value: selected,
                              onChanged: (_) => _toggle(album.id),
                            ),
                            onTap: () => _toggle(album.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 84), // Extra padding for floating nav
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ref.watch(editorAssetListProvider).when(
                  data: (assets) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${assets.length} items matching filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ).animate(key: ValueKey(assets.length)).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  ),
                  loading: () => const SizedBox(height: 32),
                  error: (_, __) => const SizedBox(height: 32),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () async {
                      await ref.read(appSettingsProvider.notifier).setIncludedAlbums(_selectedAlbumIds.toList());
                      if (widget.folderSelectOnly) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CleanReelScreen(
                            deleteMode: settings.deleteMode,
                          ),
                        ),
                      );
                    },
                    child: Text(widget.folderSelectOnly ? 'Save' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedAlbumIds.contains(id)) {
        _selectedAlbumIds.remove(id);
      } else {
        _selectedAlbumIds.add(id);
      }
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _PermissionOrEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: cs.primary, size: 40),
            const SizedBox(height: 12),
            Text('No media found', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Grant photo/video permission to start.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => PhotoManager.openSetting(),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open settings'),
            ),
          ],
        ),
      ),
    );
  }
}

