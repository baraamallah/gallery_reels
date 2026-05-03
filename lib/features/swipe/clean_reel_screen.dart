import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';

import '../../core/app_settings.dart';
import '../../core/haptics.dart';
import '../../core/database.dart';
import '../../core/log_service.dart';
import '../../shared/widgets/video_player_widget.dart';
import 'swipe_provider.dart';

class CleanReelScreen extends ConsumerStatefulWidget {
  final DeleteMode deleteMode;

  const CleanReelScreen({super.key, required this.deleteMode});

  @override
  ConsumerState<CleanReelScreen> createState() => _CleanReelScreenState();
}

class _CleanReelScreenState extends ConsumerState<CleanReelScreen> {
  final PageController _pageController = PageController();
  final Set<AssetEntity> _sessionDeleted = {};
  late ConfettiController _confettiController;
  int _index = 0;
  int _decisionsThisSession = 0;
  bool _cleanFreakBadgeShown = false;
  bool _isProcessingBatch = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_isProcessingBatch) return false;
    if (_sessionDeleted.isEmpty || widget.deleteMode == DeleteMode.inAppTrash) {
      LogService.instance.info('Exiting session: No pending system deletions.');
      return true;
    }

    setState(() => _isProcessingBatch = true);
    final pendingCount = _sessionDeleted.length;
    LogService.instance.info('Committing batch delete for $pendingCount items...');

    try {
      final assets = _sessionDeleted.toList();
      final ids = assets.map((a) => a.id).toList();

      List<String> successfullyDeletedIds = [];

      if (widget.deleteMode == DeleteMode.systemTrash && Platform.isAndroid) {
        LogService.instance.verbose('Calling Android moveToTrash for $pendingCount items...');
        successfullyDeletedIds = await PhotoManager.editor.android.moveToTrash(assets);
        LogService.instance.info('Android moveToTrash Result: ${successfullyDeletedIds.length} / $pendingCount items successfully moved.');
      } else if (widget.deleteMode == DeleteMode.permanent) {
        LogService.instance.verbose('Calling deleteWithIds (Permanent) for $pendingCount items...');
        successfullyDeletedIds = await PhotoManager.editor.deleteWithIds(ids);
        LogService.instance.info('Permanent Delete Result: ${successfullyDeletedIds.length} / $pendingCount items successfully removed.');
      }
      
      if (successfullyDeletedIds.isNotEmpty) {
        final successSet = successfullyDeletedIds.toSet();
        LogService.instance.verbose('Synchronizing internal database for successful deletions...');
        
        for (final id in successfullyDeletedIds) {
          await DatabaseService.instance.removeFromTrash(id);
        }
        
        await DatabaseService.instance.updateStats(
          reviewed: successfullyDeletedIds.length, 
          deleted: successfullyDeletedIds.length
        );
        
        // Remove successfully deleted from the session set
        _sessionDeleted.removeWhere((a) => successSet.contains(a.id));
      }

      if (_sessionDeleted.isNotEmpty) {
        LogService.instance.warn('${_sessionDeleted.length} items remain in In-App Trash because system action was cancelled or failed.');
      } else {
        LogService.instance.info('Batch deletion complete. All items processed.');
      }

      await _checkCleanFreakBadge();
    } catch (e, s) {
      LogService.instance.error('CRITICAL ERROR in batch delete: $e', e, s);
    } finally {
      if (mounted) setState(() => _isProcessingBatch = false);
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(editorAssetListProvider);
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false, // Always handle pop manually to ensure batch commit
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        
        if (shouldPop && navigator.context.mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            assetsAsync.when(
              data: (assets) {
                if (assets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No media found matching filters', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(height: 16),
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
                        ],
                      ),
                    ),
                  );
                }

                final safeIndex = _index.clamp(0, assets.length - 1);
                if (safeIndex != _index) _index = safeIndex;

                return Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _index = i),
                      itemCount: assets.length,
                      itemBuilder: (context, i) {
                        final asset = assets[i];
                        return _ReelItem(
                          key: ValueKey(asset.id),
                          asset: asset,
                          onSwipeLeft: () => _queueDelete(asset),
                          onSwipeRight: () => _keep(asset),
                          onDoubleTap: () => _toggleFavorite(asset),
                        );
                      },
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 12,
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ).animate().fadeIn(duration: 400.ms),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      right: 16,
                      child: _IndexPill(current: _index + 1, total: assets.length),
                    ).animate().fadeIn(duration: 400.ms),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BottomHint(deleteMode: widget.deleteMode),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            if (_isProcessingBatch)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'Moving ${_sessionDeleted.length} items to bin...',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _keep(AssetEntity asset) {
    LogService.instance.verbose('Keeping asset: ${asset.id}');
    HapticHelper.light();
    _handleDecision();
    _pageController.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
  }

  void _queueDelete(AssetEntity asset) async {
    LogService.instance.verbose('Queueing asset for delete: ${asset.id} (${asset.title})');
    HapticHelper.medium();
    _handleDecision();

    // 1. Mark in In-app trash immediately for logical delete (seamless feel)
    await _addToInAppTrash(asset);
    
    // 2. Add to session batch for official system delete on exit
    _sessionDeleted.add(asset);

    // 3. Move to next immediately
    _pageController.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Moved to trash'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            LogService.instance.verbose('UNDO delete for asset: ${asset.id}');
            _sessionDeleted.remove(asset);
            await DatabaseService.instance.removeFromTrash(asset.id);
            // We don't scroll back, but it's removed from the "to be deleted" list
            HapticHelper.light();
          },
        ),
      ),
    );
  }

  Future<void> _addToInAppTrash(AssetEntity asset) async {
    final file = await asset.file;
    final size = await file?.length() ?? 0;
    await DatabaseService.instance.addToTrash(asset.id, asset.title, size);
    await DatabaseService.instance.updateStats(spaceFreed: size);
  }

  // Remove the old _commitDelete as it's now handled by _onWillPop and _queueDelete


  /// 🏆 Easter egg: fires a one-time trophy dialog after the user has deleted
  /// 50 files total across all sessions.
  Future<void> _checkCleanFreakBadge() async {
    if (_cleanFreakBadgeShown) return;
    final stats = await DatabaseService.instance.getLifetimeStats();
    final totalDeleted = (stats['deleted'] as int?) ?? 0;
    if (totalDeleted < 50) return;
    _cleanFreakBadgeShown = true;
    if (!mounted) return;
    _confettiController.play();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _CleanFreakBadgeDialog(),
    );
  }

  void _handleDecision() {
    _decisionsThisSession++;
    if (_decisionsThisSession % 20 == 0) {
      _confettiController.play();
    }
  }

  Future<void> _toggleFavorite(AssetEntity asset) async {
    LogService.instance.verbose('Toggling favorite for asset: ${asset.id}');
    HapticHelper.light();
    final tags = await DatabaseService.instance.getPhotoTags(asset.id);
    final isFav = tags.contains('2');
    if (isFav) {
      await DatabaseService.instance.untagPhoto(asset.id, '2');
    } else {
      await DatabaseService.instance.tagPhoto(asset.id, '2');
    }

    if (Platform.isAndroid) {
      try {
        await PhotoManager.editor.android.favoriteAsset(entity: asset, favorite: !isFav);
        LogService.instance.info('System favorite status updated for ${asset.id}');
      } catch (e) {
        LogService.instance.warn('Failed to update system favorite status: $e');
      }
    }
  }
}

class _ReelItem extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onDoubleTap;

  const _ReelItem({
    super.key,
    required this.asset,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onDoubleTap,
  });

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> {
  double _dx = 0;
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      onHorizontalDragUpdate: (d) => setState(() => _dx += d.delta.dx),
      onHorizontalDragEnd: (d) {
        final vx = d.primaryVelocity ?? 0;
        final goLeft = vx < -800 || _dx < -120;
        final goRight = vx > 800 || _dx > 120;
        setState(() => _dx = 0);
        if (goLeft) widget.onSwipeLeft();
        if (goRight) widget.onSwipeRight();
      },
      onHorizontalDragCancel: () => setState(() => _dx = 0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.asset.type == AssetType.video)
            VideoPlayerWidget(asset: widget.asset)
          else
            AssetEntityImage(
              widget.asset,
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
          
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0, 0.22, 0.7, 1],
              ),
            ),
          ),

          // Info Button (I Logo)
          Positioned(
            right: 16,
            bottom: 140,
            child: IconButton(
              iconSize: 28,
              onPressed: () => setState(() => _showInfo = !_showInfo),
              icon: Icon(
                _showInfo ? Icons.info : Icons.info_outline,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),

          if (_showInfo)
            Positioned(
              left: 16,
              right: 70,
              bottom: 140,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.asset.title ?? 'Unknown',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<File?>(
                      future: widget.asset.file,
                      builder: (context, snap) {
                        final file = snap.data;
                        if (file == null) return const SizedBox.shrink();
                        final size = file.lengthSync();
                        final sizeMb = (size / (1024 * 1024)).toStringAsFixed(2);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Size: $sizeMb MB', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('Path: ${file.path}', style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        );
                      },
                    ),
                    Text(
                      'Date: ${widget.asset.createDateTime.day}/${widget.asset.createDateTime.month}/${widget.asset.createDateTime.year}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 100.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 100.ms),
            ),

          if (_dx.abs() > 30)
            Align(
              alignment: _dx < 0 ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (_dx < 0 ? cs.error : cs.primary).withValues(alpha: 0.2),
                    border: Border.all(color: _dx < 0 ? cs.error : cs.primary, width: 2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _dx < 0 ? 'TRASH' : 'KEEP',
                    style: TextStyle(
                      color: _dx < 0 ? cs.error : cs.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ).animate().scale(duration: 100.ms),
            ),
        ],
      ),
    );
  }
}

class _IndexPill extends StatelessWidget {
  final int current;
  final int total;

  const _IndexPill({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$current of $total',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BottomHint extends StatelessWidget {
  final DeleteMode deleteMode;

  const _BottomHint({required this.deleteMode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swipe_left_alt_rounded, color: cs.error, size: 28),
                          const SizedBox(height: 4),
                          const Text(
                            'TRASH',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 32, width: 1.5, color: Colors.white.withValues(alpha: 0.2)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swipe_right_alt_rounded, color: cs.primary, size: 28),
                          const SizedBox(height: 4),
                          const Text(
                            'KEEP',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 🏆 Clean Freak Badge Dialog — shown once when lifetime deletes reach 50
// ─────────────────────────────────────────────────────────────────────────────

class _CleanFreakBadgeDialog extends StatefulWidget {
  const _CleanFreakBadgeDialog();

  @override
  State<_CleanFreakBadgeDialog> createState() => _CleanFreakBadgeDialogState();
}

class _CleanFreakBadgeDialogState extends State<_CleanFreakBadgeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700),
                      cs.primary.withValues(alpha: 0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Clean Freak!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD700),
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'You\'ve deleted 50+ files 🎉\nYour gallery is looking seriously pristine. Keep up the clean streak!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'psst — this badge is a secret 🤫',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome! 🙌'),
            ),
          ],
        ),
      ),
    );
  }
}
