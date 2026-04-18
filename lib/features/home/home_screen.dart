import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/theme.dart';
import '../../core/database.dart';
import '../../shared/widgets/glass_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic>? _stats;
  int _totalPhotos = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DatabaseService.instance.getTodayStats();
    final count = await PhotoManager.getAssetCount(type: RequestType.image);
    setState(() {
      _stats = stats;
      _totalPhotos = count;
    });
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < suffixes.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    final spaceFreed = _stats?['space_freed'] as int? ?? 0;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Good evening,',
                style: AppTheme.bodyStyle.copyWith(fontSize: 18),
              ),
              Text(
                'Gallery Reels',
                style: AppTheme.headingStyle.copyWith(fontSize: 32),
              ),
              
              const SizedBox(height: 40),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _StatCard(
                    title: 'Reviewed today',
                    value: _stats?['reviewed']?.toString() ?? '0',
                    icon: PhosphorIcons.checkCircle(),
                    color: AppTheme.keepColor,
                  ),
                  _StatCard(
                    title: 'Space to free',
                    value: _formatSize(spaceFreed),
                    icon: PhosphorIcons.broom(),
                    color: AppTheme.accentColor,
                  ),
                  _StatCard(
                    title: 'Current streak',
                    value: '5',
                    icon: PhosphorIcons.fire(),
                    color: AppTheme.shareColor,
                    isStreak: true,
                  ),
                  _StatCard(
                    title: 'Library size',
                    value: _totalPhotos.toString(),
                    icon: PhosphorIcons.image(),
                    color: AppTheme.tagColor,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Progress Section
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Weekly Progress', style: AppTheme.headingStyle),
                        Text('80%', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.8,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final PhosphorIconData icon;
  final Color color;
  final bool isStreak;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isStreak = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PhosphorIcon(icon, color: color, size: 24),
              if (isStreak)
                const PhosphorIcon(PhosphorIconsFill.fire, color: Colors.orange, size: 20)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1.seconds),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.headingStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              Text(
                title,
                style: AppTheme.captionStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
