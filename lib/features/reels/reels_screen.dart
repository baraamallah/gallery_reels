import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../swipe/swipe_provider.dart';
import '../../core/theme.dart';
import '../../core/haptics.dart';
import '../../core/database.dart';

import '../../shared/widgets/glass_card.dart';

class ReelsScreen extends ConsumerWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoListAsync = ref.watch(photoListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: photoListAsync.when(
        data: (assets) => PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: assets.length,
          onPageChanged: (index) {
            // Logic to handle page change could go here if needed
          },
          itemBuilder: (context, index) {
            return ReelPage(asset: assets[index], key: ValueKey(assets[index].id));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class ReelPage extends ConsumerStatefulWidget {
  final AssetEntity asset;

  const ReelPage({super.key, required this.asset});

  @override
  ConsumerState<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends ConsumerState<ReelPage> {
  bool _showOverlay = true;
  Timer? _hideTimer;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkIfLiked() async {
    final tags = await DatabaseService.instance.getPhotoTags(widget.asset.id);
    if (mounted) {
      setState(() => _isLiked = tags.contains('2'));
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (_showOverlay) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showOverlay = false);
        }
      });
    }
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      if (_showOverlay) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  Future<void> _handleLike() async {
    if (_isLiked) {
      await DatabaseService.instance.untagPhoto(widget.asset.id, '2');
      setState(() => _isLiked = false);
      HapticHelper.light();
    } else {
      await DatabaseService.instance.tagPhoto(widget.asset.id, '2');
      setState(() => _isLiked = true);
      HapticHelper.medium();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleOverlay,
      onDoubleTap: _handleLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full Screen Photo
          AssetEntityImage(
            widget.asset,
            isOriginal: true,
            fit: BoxFit.cover,
          ),

          // Action Overlay
          AnimatedOpacity(
            opacity: _showOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showOverlay,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.asset.createDateTime.toString().split(' ')[0],
                                style: AppTheme.captionStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: GlassCard(
                          borderRadius: 35,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ReelAction(
                                icon: Icons.delete_outline,
                                color: AppTheme.deleteColor,
                                onTap: () async {
                                  HapticHelper.heavy();
                                  final asset = widget.asset;
                                  final file = await asset.file;
                                  final size = await file?.length() ?? 0;

                                  await DatabaseService.instance.addToTrash(asset.id, asset.title, size);
                                  await DatabaseService.instance.updateStats(deleted: 1, spaceFreed: size);

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Photo moved to trash'),
                                      backgroundColor: Colors.black87,
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        textColor: AppTheme.accentColor,
                                        onPressed: () async {
                                          HapticHelper.light();
                                          await DatabaseService.instance.removeFromTrash(asset.id);
                                          await DatabaseService.instance.updateStats(deleted: -1, spaceFreed: -size);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _ReelAction(
                                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: _isLiked ? AppTheme.keepColor : Colors.white,
                                isHighlighted: _isLiked,
                                onTap: _handleLike,
                              ),
                              _ReelAction(
                                icon: Icons.folder_open,
                                color: AppTheme.tagColor,
                                onTap: () {},
                              ),
                              _ReelAction(
                                icon: Icons.share_outlined,
                                color: AppTheme.shareColor,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideY(begin: 0.5, curve: Curves.easeOutCubic, duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLiked)
            Center(
              child: const Icon(Icons.favorite, color: Colors.white, size: 100)
                  .animate(onPlay: (c) => c.forward())
                  .scale(duration: 400.ms, curve: Curves.elasticOut)
                  .fadeOut(delay: 600.ms),
            ),
        ],
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ReelAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlighted ? color.withValues(alpha: 0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }
}
