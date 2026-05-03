import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../core/app_settings.dart';
import '../../core/database.dart';
import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../core/log_service.dart';
import '../../shared/widgets/video_player_widget.dart';
import '../swipe/swipe_provider.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(reelsAssetListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          assetsAsync.when(
            data: (assets) {
              if (assets.isEmpty) {
                return const Center(
                  child: Text(
                    'No media matches your Reels filters',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                itemCount: assets.length,
                itemBuilder: (context, i) {
                  final asset = assets[i];
                  return _ReelItem(asset: asset);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),

          // Settings button for Reels
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReelsSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              tooltip: 'Reels Filters',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reels Settings Screen
// ─────────────────────────────────────────────────────────────────────────────

class _ReelItem extends ConsumerStatefulWidget {
  final AssetEntity asset;
  const _ReelItem({required this.asset});

  @override
  ConsumerState<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends ConsumerState<_ReelItem> {
  bool _showBigHeart = false;
  final GlobalKey<_LikeButtonState> _likeButtonKey = GlobalKey<_LikeButtonState>();

  void _handleDoubleTap() {
    setState(() => _showBigHeart = true);
    _likeButtonKey.currentState?.toggleLike(forceLike: true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showBigHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (asset.type == AssetType.video)
            VideoPlayerWidget(asset: asset)
          else
            AssetEntityImage(
              asset,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize(1200, 1200),
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child.animate().fadeIn(duration: 400.ms);
                }
                return Container(
                  color: Colors.white10,
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 1200.ms, color: Colors.white24);
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
                stops: [0, 0.2, 0.7, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      asset.type == AssetType.video
                          ? Icons.videocam_rounded
                          : Icons.image_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        asset.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${asset.createDateTime.day}/${asset.createDateTime.month}/${asset.createDateTime.year}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
              ],
            ),
          ),
          
          // Action Buttons (Like & Share)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 160,
            child: Column(
              children: [
                _LikeButton(key: _likeButtonKey, asset: asset),
                const SizedBox(height: 24),
                IconButton(
                  onPressed: () async {
                    final file = await asset.file;
                    if (file != null) {
                      LogService.instance.info('Sharing asset: ${asset.id}');
                      // ignore: deprecated_member_use
                      await Share.shareXFiles([XFile(file.path)]);
                    } else {
                      LogService.instance.warn('Could not share asset: file is null');
                    }
                  },
                  icon: Icon(PhosphorIcons.shareNetwork(), color: Colors.white, size: 32),
                ).animate().fadeIn(delay: 200.ms).scale(),              ],
            ),
          ),

          // Big Heart Overlay
          if (_showBigHeart)
            Center(
              child: Icon(
                PhosphorIcons.heart(PhosphorIconsStyle.fill),
                color: Colors.white.withValues(alpha: 0.8),
                size: 120,
              )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.2, 1.2),
                duration: 200.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1.0, 1.0),
                duration: 100.ms,
              )
              .fadeOut(delay: 500.ms, duration: 300.ms),
            ),
        ],
      ),
    );
  }
}

class _LikeButton extends ConsumerStatefulWidget {
  final AssetEntity asset;
  const _LikeButton({super.key, required this.asset});

  @override
  ConsumerState<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<_LikeButton> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    final tags = await DatabaseService.instance.getPhotoTags(widget.asset.id);
    if (mounted) {
      setState(() => _isLiked = tags.contains('2') || widget.asset.isFavorite);
    }
  }

  Future<void> toggleLike({bool forceLike = false}) async {
    LogService.instance.verbose('toggleLike called for ${widget.asset.id} (forceLike: $forceLike)');
    HapticHelper.medium();
    if (forceLike && _isLiked) return; // Already liked

    final newStatus = forceLike ? true : !_isLiked;
    setState(() => _isLiked = newStatus);

    if (newStatus) {
      await DatabaseService.instance.tagPhoto(widget.asset.id, '2');
      if (Platform.isAndroid) {
        try {
          await PhotoManager.editor.android.favoriteAsset(entity: widget.asset, favorite: true);
          LogService.instance.info('System favorite status (true) set for ${widget.asset.id}');
        } catch (e) {
          LogService.instance.warn('Failed system favorite: $e');
        }
      }
    } else {
      await DatabaseService.instance.untagPhoto(widget.asset.id, '2');
      if (Platform.isAndroid) {
        try {
          await PhotoManager.editor.android.favoriteAsset(entity: widget.asset, favorite: false);
          LogService.instance.info('System favorite status (false) set for ${widget.asset.id}');
        } catch (e) {
          LogService.instance.warn('Failed system favorite: $e');
        }
      }
    }
    // Refresh favorites list if active
    ref.invalidate(favoriteAssetListProvider);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => toggleLike(),
      icon: Icon(
        _isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(),
        color: _isLiked ? Colors.red : Colors.white,
        size: 36,
      ),
    ).animate(target: _isLiked ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 200.ms,
          curve: Curves.elasticOut,
        ).then().scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
          duration: 100.ms,
        );
  }
}

class ReelsSettingsScreen extends ConsumerStatefulWidget {
  const ReelsSettingsScreen({super.key});

  @override
  ConsumerState<ReelsSettingsScreen> createState() =>
      _ReelsSettingsScreenState();
}

class _ReelsSettingsScreenState extends ConsumerState<ReelsSettingsScreen> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(ref.read(appSettingsProvider).reelsIncludedAlbumIds);
  }

  Future<void> _pickDate(BuildContext context,
      {required bool isStart}) async {
    final settings = ref.read(appSettingsProvider);
    final initial = isStart
        ? (settings.reelsStartDate ?? DateTime.now())
        : (settings.reelsEndDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (isStart) {
      await ref
          .read(appSettingsProvider.notifier)
          .setReelsStartDate(picked);
    } else {
      await ref
          .read(appSettingsProvider.notifier)
          .setReelsEndDate(picked);
    }
  }

  String _fmtDate(DateTime? d) =>
      d == null ? 'Any' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final albumsAsync = ref.watch(reelsAlbumsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Reels Filters', style: AppTheme.headingStyle(context).copyWith(fontSize: 20)),
        centerTitle: false,
        backgroundColor: cs.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(appSettingsProvider.notifier).setReelsIncludedAlbums(_selectedIds.toList());
              if (mounted) navigator.pop();
            },
            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabelRow(title: 'Media Type', icon: PhosphorIcons.filmStrip()),
          _FilterCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 8,
                children: [
                  _ReelChoiceChip(
                    label: 'Photos',
                    selected: settings.reelsMediaMode == MediaMode.photosOnly,
                    onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMediaMode(MediaMode.photosOnly),
                  ),
                  _ReelChoiceChip(
                    label: 'Videos',
                    selected: settings.reelsMediaMode == MediaMode.videosOnly,
                    onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMediaMode(MediaMode.videosOnly),
                  ),
                  _ReelChoiceChip(
                    label: 'Both',
                    selected: settings.reelsMediaMode == MediaMode.photosAndVideos,
                    onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMediaMode(MediaMode.photosAndVideos),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabelRow(title: 'Sort Order', icon: PhosphorIcons.sortAscending()),
          _FilterCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SortMode>(
                  value: settings.reelsSortMode,
                  isExpanded: true,
                  onChanged: (v) => v != null ? ref.read(appSettingsProvider.notifier).setReelsSortMode(v) : null,
                  items: const [
                    DropdownMenuItem(value: SortMode.newestFirst, child: Text('Newest First')),
                    DropdownMenuItem(value: SortMode.oldestFirst, child: Text('Oldest First')),
                    DropdownMenuItem(value: SortMode.largestFirst, child: Text('Largest First')),
                    DropdownMenuItem(value: SortMode.smallestFirst, child: Text('Smallest First')),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabelRow(title: 'Date Range', icon: PhosphorIcons.calendar()),
          _FilterCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _DatePickerTile(
                      label: 'From',
                      value: _fmtDate(settings.reelsStartDate),
                      onTap: () => _pickDate(context, isStart: true),
                      onClear: settings.reelsStartDate != null
                          ? () => ref.read(appSettingsProvider.notifier).setReelsStartDate(null)
                          : null,
                      cs: cs,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerTile(
                      label: 'To',
                      value: _fmtDate(settings.reelsEndDate),
                      onTap: () => _pickDate(context, isStart: false),
                      onClear: settings.reelsEndDate != null
                          ? () => ref.read(appSettingsProvider.notifier).setReelsEndDate(null)
                          : null,
                      cs: cs,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabelRow(title: 'File Size', icon: PhosphorIcons.fileSql()),
          _FilterCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Minimum Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SizeChip(label: 'Any', selected: settings.minSizeReels == null, onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMinSize(null)),
                      _SizeChip(label: '> 5MB', selected: settings.minSizeReels == 5 * 1024 * 1024, onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMinSize(5 * 1024 * 1024)),
                      _SizeChip(label: '> 50MB', selected: settings.minSizeReels == 50 * 1024 * 1024, onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMinSize(50 * 1024 * 1024)),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Maximum Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SizeChip(label: 'Any', selected: settings.maxSizeReels == null, onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMaxSize(null)),
                      _SizeChip(label: '< 10MB', selected: settings.maxSizeReels == 10 * 1024 * 1024, onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMaxSize(10 * 1024 * 1024)),
                      _SizeChip(label: '< 100MB', selected: settings.maxSizeReels == 100 * 1024 * 1024, onSelected: () => ref.read(appSettingsProvider.notifier).setReelsMaxSize(100 * 1024 * 1024)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabelRow(title: 'Included Folders', icon: PhosphorIcons.folder()),
          _FilterCard(
            child: albumsAsync.when(
              data: (albums) => Column(
                children: albums.map((a) => CheckboxListTile(
                  title: Text(a.name, style: const TextStyle(fontSize: 14)),
                  value: _selectedIds.contains(a.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.add(a.id);
                      } else {
                        _selectedIds.remove(a.id);
                      }
                    });
                  },
                )).toList(),
              ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
            ),
          ),

          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              setState(() => _selectedIds.clear());
              final n = ref.read(appSettingsProvider.notifier);
              await n.setReelsMediaMode(MediaMode.photosAndVideos);
              await n.setReelsSortMode(SortMode.newestFirst);
              await n.setReelsMinSize(null);
              await n.setReelsMaxSize(null);
              await n.setReelsStartDate(null);
              await n.setReelsEndDate(null);
              await n.setReelsIncludedAlbums([]);
              if (mounted) navigator.pop();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset All Filters'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionLabelRow extends StatelessWidget {
  final String title;
  final PhosphorIconData icon;
  const _SectionLabelRow({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          PhosphorIcon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  final Widget child;
  const _FilterCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _ReelChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const _ReelChoiceChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const _SizeChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onSelected(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final ColorScheme cs;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != 'Any';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasValue ? cs.primary : cs.outline,
            width: hasValue ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasValue ? cs.primary.withValues(alpha: 0.08) : null,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 16,
                color: hasValue ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10,
                          color: hasValue ? cs.primary : cs.onSurfaceVariant)),
                  Text(value,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasValue ? cs.primary : cs.onSurface)),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 16, color: cs.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
