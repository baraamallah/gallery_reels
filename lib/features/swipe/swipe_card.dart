import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../shared/models/swipe_models.dart';
import '../../core/theme.dart';
import 'dart:math';

class SwipeCard extends StatefulWidget {
  final AssetEntity asset;
  final Function(SwipeDirection) onSwiped;

  const SwipeCard({
    super.key,
    required this.asset,
    required this.onSwiped,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final threshold = screenSize.width * 0.3;

    if (_dragOffset.dx > threshold) {
      _animateAndSwipe(SwipeDirection.right, Offset(screenSize.width, 0));
    } else if (_dragOffset.dx < -threshold) {
      _animateAndSwipe(SwipeDirection.left, Offset(-screenSize.width, 0));
    } else if (_dragOffset.dy < -threshold) {
      _animateAndSwipe(SwipeDirection.up, Offset(0, -screenSize.height));
    } else if (_dragOffset.dy > threshold) {
      _animateAndSwipe(SwipeDirection.down, Offset(0, screenSize.height));
    } else {
      _resetPosition();
    }
  }

  void _animateAndSwipe(SwipeDirection direction, Offset target) {
    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(from: 0).then((_) {
      widget.onSwiped(direction);
    });
  }

  void _resetPosition() {
    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    
    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _controller.isAnimating ? _animation.value : _dragOffset;
        final rotation = offset.dx / MediaQuery.of(context).size.width * (pi / 8);

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: rotation,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AssetEntityImage(
                      widget.asset,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize(800, 800),
                      fit: BoxFit.cover,
                    ),

                    // Gradient overlay for metadata
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Metadata overlay
                    Positioned(
                      top: 24,
                      right: 24,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: AppTheme.onSurface),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.asset.createDateTime.month}/${widget.asset.createDateTime.day}/${widget.asset.createDateTime.year}',
                                  style: AppTheme.labelStyle.copyWith(color: AppTheme.onSurface, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Gesture Indicators (Opacity based on drag)
                    if (offset.dx > 0)
                      Positioned(
                        top: 40,
                        left: 40,
                        child: Transform.rotate(
                          angle: -pi / 12,
                          child: Opacity(
                            opacity: (offset.dx / 100).clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.primary, width: 4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'KEEP',
                                style: AppTheme.headingStyle.copyWith(color: AppTheme.primary, fontSize: 32),
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (offset.dx < 0)
                      Positioned(
                        top: 40,
                        right: 40,
                        child: Transform.rotate(
                          angle: pi / 12,
                          child: Opacity(
                            opacity: (-offset.dx / 100).clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.error, width: 4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'TRASH',
                                style: AppTheme.headingStyle.copyWith(color: AppTheme.error, fontSize: 32),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
