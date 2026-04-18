import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/theme.dart';
import '../../core/database.dart';
import '../../shared/widgets/glass_card.dart';
import '../about/about_screen.dart';

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
    if (mounted) {
      setState(() {
        _stats = stats;
        _totalPhotos = count;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
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
    final reviewedCount = _stats?['reviewed'] as int? ?? 0;
    final spaceFreed = _stats?['space_freed'] as int? ?? 0;
    final target = 50; // Daily target
    final healthProgress = (reviewedCount / target).clamp(0.0, 1.0);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Top Section: Greeting & Health Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: AppTheme.bodyStyle.copyWith(fontSize: 18, color: Colors.white70),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                      Text(
                        'SnapClean Curator',
                        style: AppTheme.headingStyle.copyWith(fontSize: 32),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    ],
                  ),
                  Row(
                    children: [
                      _CleanupHealthIndicator(progress: healthProgress)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white70),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ],
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
                    value: reviewedCount.toString(),
                    icon: PhosphorIcons.checkCircle(),
                    color: AppTheme.keepColor,
                    delay: 500,
                  ),
                  _StatCard(
                    value: _formatSize(spaceFreed),
                    icon: PhosphorIcons.broom(),
                    color: AppTheme.accentColor,
                    delay: 600,
                  ),
                  _StatCard(
                    value: '7',
                    icon: PhosphorIcons.fire(),
                    color: AppTheme.shareColor,
                    isStreak: true,
                    delay: 700,
                  ),
                  _StatCard(
                    value: _totalPhotos.toString(),
                    icon: PhosphorIcons.image(),
                    color: AppTheme.tagColor,
                    delay: 800,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // New Insights Section
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text('Weekly Insights', style: AppTheme.headingStyle.copyWith(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InsightRow(
                      value: 'Tuesday',
                      icon: Icons.calendar_today,
                      color: AppTheme.accentColor,
                    ),
                    const Divider(color: Colors.white10),
                    _InsightRow(
                      value: 'Screenshots',
                      icon: Icons.phonelink_setup,
                      color: AppTheme.deleteColor,
                    ),
                    const Divider(color: Colors.white10),
                    _InsightRow(
                      value: '2.4 GB',
                      icon: Icons.storage,
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _CleanupHealthIndicator extends StatelessWidget {
  final double progress;

  const _CleanupHealthIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            color: AppTheme.accentColor,
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Text(
              'HEALTH',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final PhosphorIconData icon;
  final Color color;
  final bool isStreak;
  final int delay;

  const _StatCard({
    required this.value,
    required this.icon,
    required this.color,
    this.isStreak = false,
    required this.delay,
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
                    .shimmer(duration: 2.seconds),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.headingStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ).animate().scale(delay: (delay + 100).ms, curve: Curves.easeOutBack),

            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2);
  }
}

class _InsightRow extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color color;

  const _InsightRow({
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
