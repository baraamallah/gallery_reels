import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final cs = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top + 64;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPadding)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Setup',
                        style: AppTheme.headingStyle(context).copyWith(fontSize: 28),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      const SizedBox(height: 8),
                      Text(
                        'Configure your cleaning session filters below.',
                        style: AppTheme.bodyStyle(context).copyWith(color: cs.onSurfaceVariant),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),
                      
                      _FilterSection(
                        title: 'Media Types',
                        icon: PhosphorIcons.fileImage(),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            _ModernChip(
                              label: 'Photos',
                              selected: settings.mediaMode == MediaMode.photosOnly,
                              onTap: () => ref.read(appSettingsProvider.notifier).setMediaMode(MediaMode.photosOnly),
                              icon: PhosphorIcons.image(),
                            ),
                            _ModernChip(
                              label: 'Videos',
                              selected: settings.mediaMode == MediaMode.videosOnly,
                              onTap: () => ref.read(appSettingsProvider.notifier).setMediaMode(MediaMode.videosOnly),
                              icon: PhosphorIcons.videoCamera(),
                            ),
                            _ModernChip(
                              label: 'Both',
                              selected: settings.mediaMode == MediaMode.photosAndVideos,
                              onTap: () => ref.read(appSettingsProvider.notifier).setMediaMode(MediaMode.photosAndVideos),
                              icon: PhosphorIcons.infinity(),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                      const SizedBox(height: 20),

                      _FilterSection(
                        title: 'Sort Order',
                        icon: PhosphorIcons.sortAscending(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _ModernChip(
                                label: 'Newest',
                                selected: settings.sortMode == SortMode.newestFirst,
                                onTap: () => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.newestFirst),
                              ),
                              const SizedBox(width: 8),
                              _ModernChip(
                                label: 'Oldest',
                                selected: settings.sortMode == SortMode.oldestFirst,
                                onTap: () => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.oldestFirst),
                              ),
                              const SizedBox(width: 8),
                              _ModernChip(
                                label: 'Largest',
                                selected: settings.sortMode == SortMode.largestFirst,
                                onTap: () => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.largestFirst),
                              ),
                              const SizedBox(width: 8),
                              _ModernChip(
                                label: 'Smallest',
                                selected: settings.sortMode == SortMode.smallestFirst,
                                onTap: () => ref.read(appSettingsProvider.notifier).setSortMode(SortMode.smallestFirst),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: 20),

                      _FilterSection(
                        title: 'File Size',
                        icon: PhosphorIcons.hardDrive(),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            _ModernChip(
                              label: 'All Sizes',
                              selected: settings.minSizeEditor == null,
                              onTap: () => ref.read(appSettingsProvider.notifier).setMinSizeEditor(null),
                            ),
                            _ModernChip(
                              label: '> 10MB',
                              selected: settings.minSizeEditor == 10 * 1024 * 1024,
                              onTap: () => ref.read(appSettingsProvider.notifier).setMinSizeEditor(10 * 1024 * 1024),
                            ),
                            _ModernChip(
                              label: '> 50MB',
                              selected: settings.minSizeEditor == 50 * 1024 * 1024,
                              onTap: () => ref.read(appSettingsProvider.notifier).setMinSizeEditor(50 * 1024 * 1024),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Folders',
                            style: AppTheme.headingStyle(context).copyWith(fontSize: 20),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedAlbumIds.clear()),
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear Selection'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),
              albumsAsync.when(
                data: (albums) {
                  if (albums.isEmpty) return const SliverToBoxAdapter(child: _PermissionOrEmpty());
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 250), // Raised padding
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final album = albums[index];
                          final selected = _selectedAlbumIds.contains(album.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AlbumCard(
                              album: album,
                              selected: selected,
                              onTap: () => _toggle(album.id),
                            ),
                          );
                        },
                        childCount: albums.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ))),
                error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              ),
            ],
          ),
          
          // Floating Action Area - Raised above BottomNav
          Positioned(
            left: 0,
            right: 0,
            bottom: 84, // Higher than FloatingBottomNav (80)
            child: _FloatingActionPanel(
              folderSelectOnly: widget.folderSelectOnly,
              onAction: () async {
                await ref.read(appSettingsProvider.notifier).setIncludedAlbums(_selectedAlbumIds.toList());
                if (widget.folderSelectOnly) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  return;
                }
                if (!context.mounted) return;
                
                // Beautiful Slide + Fade Transition
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => CleanReelScreen(
                      deleteMode: settings.deleteMode,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(Tween(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutQuart))),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  final PhosphorIconData icon;

  const _FilterSection({required this.title, required this.child, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PhosphorIcon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ModernChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final PhosphorIconData? icon;

  const _ModernChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: 1.5,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              PhosphorIcon(icon!, size: 16, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final AssetPathEntity album;
  final bool selected;
  final VoidCallback onTap;

  const _AlbumCard({required this.album, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer.withValues(alpha: 0.4) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? cs.primary : cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selected ? Icons.check_rounded : Icons.folder_rounded,
              color: selected ? cs.onPrimary : cs.primary,
            ),
          ),
          title: Text(
            album.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: FutureBuilder<int>(
            future: album.assetCountAsync,
            builder: (context, snap) => Text(
              snap.hasData ? '${snap.data} items' : 'Calculating...',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          trailing: Checkbox(
            value: selected,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) => onTap(),
          ),
        ),
      ),
    );
  }
}

class _FloatingActionPanel extends ConsumerWidget {
  final bool folderSelectOnly;
  final VoidCallback onAction;

  const _FloatingActionPanel({required this.folderSelectOnly, required this.onAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(editorAssetListProvider);
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                assetsAsync.when(
                  data: (assets) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(PhosphorIcons.sparkle(), size: 14, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${assets.length} items match your filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ).animate(key: ValueKey(assets.length)).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                  loading: () => const SizedBox(height: 38),
                  error: (_, __) => const SizedBox(height: 38),
                ),
                _AnimatedScaleButton(
                  onTap: onAction,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          folderSelectOnly ? 'Save Configuration' : 'Start Session',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onPrimary),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: cs.onPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionOrEmpty extends StatelessWidget {
  const _PermissionOrEmpty();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(PhosphorIcons.warningCircle(), color: cs.primary, size: 48),
            const SizedBox(height: 16),
            const Text('No media found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Try selecting different filters or grant gallery permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedScaleButton({required this.child, required this.onTap});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
