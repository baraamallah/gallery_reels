import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../swipe/swipe_provider.dart';
import '../../core/theme.dart';
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
          itemBuilder: (context, index) {
            return ReelPage(asset: assets[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class ReelPage extends StatefulWidget {
  final AssetEntity asset;

  const ReelPage({super.key, required this.asset});

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showOverlay = !_showOverlay),
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
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
                            onPressed: () {}, // Not needed in tab view
                          ),
                          const Spacer(),
                          Text(
                            widget.asset.createDateTime.toString().split(' ')[0],
                            style: AppTheme.captionStyle.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: GlassCard(
                        borderRadius: 30,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ReelAction(icon: Icons.delete_outline, color: AppTheme.deleteColor, label: 'Delete'),
                            _ReelAction(icon: Icons.favorite_border, color: AppTheme.keepColor, label: 'Keep'),
                            _ReelAction(icon: Icons.folder_open, color: AppTheme.tagColor, label: 'Tag'),
                            _ReelAction(icon: Icons.share_outlined, color: AppTheme.shareColor, label: 'Share'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ReelAction({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
