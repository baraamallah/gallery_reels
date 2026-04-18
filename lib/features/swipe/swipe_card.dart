import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/theme.dart';
import '../../shared/models/swipe_models.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

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
  Offset _offset = Offset.zero;
  double _rotation = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _offset += d.delta;
      _rotation = _offset.dx / 300 * 0.4;
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_offset.dx > 120) {
      _swipe(SwipeDirection.right);
    } else if (_offset.dx < -120) {
      _swipe(SwipeDirection.left);
    } else if (_offset.dy < -100) {
      _swipe(SwipeDirection.up);
    } else if (_offset.dy > 100) {
      _swipe(SwipeDirection.down);
    } else {
      _resetPosition();
    }
  }

  void _swipe(SwipeDirection direction) {
    Offset endOffset;
    switch (direction) {
      case SwipeDirection.right:
        endOffset = const Offset(500, 0);
        break;
      case SwipeDirection.left:
        endOffset = const Offset(-500, 0);
        break;
      case SwipeDirection.up:
        endOffset = const Offset(0, -800);
        break;
      case SwipeDirection.down:
        endOffset = const Offset(0, 800);
        break;
    }

    final startOffset = _offset;
    final animation = Tween<Offset>(begin: startOffset, end: endOffset).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _animationController.forward(from: 0).then((_) {
      widget.onSwiped(direction);
    });
  }

  void _resetPosition() {
    final startOffset = _offset;
    final startRotation = _rotation;
    
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    animation.addListener(() {
      setState(() {
        _offset = Offset.lerp(startOffset, Offset.zero, animation.value)!;
        _rotation = lerpDouble(startRotation, 0, animation.value);
      });
    });

    _animationController.forward(from: 0);
  }

  double lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return 0;
    a ??= 0;
    b ??= 0;
    return a + (b - a) * t;
  }

  @override
  Widget build(BuildContext context) {
    final deleteOpacity = (_offset.dx / 120).clamp(0.0, 1.0);
    final keepOpacity = (-_offset.dx / 120).clamp(0.0, 1.0);
    final tagOpacity = (-_offset.dy / 100).clamp(0.0, 1.0);
    final shareOpacity = (_offset.dy / 100).clamp(0.0, 1.0);

    return Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: _rotation,
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              // Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox.expand(
                  child: AssetEntityImage(
                    widget.asset,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize(1000, 1000),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Overlays
              _buildOverlay(AppTheme.deleteColor, Icons.delete, deleteOpacity),
              _buildOverlay(AppTheme.keepColor, Icons.check_circle, keepOpacity),
              _buildOverlay(AppTheme.tagColor, Icons.folder, tagOpacity),
              _buildOverlay(AppTheme.shareColor, Icons.share, shareOpacity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(Color color, IconData icon, double opacity) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 60),
          ),
        ),
      ),
    );
  }
}
