import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:ui';


import '../../core/theme.dart';


// The new Home Screen serves as the "Library" from the design
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _totalPhotos = 0;
  int _videoCount = 0;
  int _screenshotCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final imageCount = await PhotoManager.getAssetCount(type: RequestType.image);
    final vidCount = await PhotoManager.getAssetCount(type: RequestType.video);

    // In a real app we'd query specifically for screenshots,
    // but for UI purposes we'll mock it based on total
    final mockScreenshotCount = (imageCount * 0.15).toInt();

    if (mounted) {
      setState(() {
        _totalPhotos = imageCount;
        _videoCount = vidCount;
        _screenshotCount = mockScreenshotCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Ambient Glow 1
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.05), blurRadius: 100),
                ],
              ),
            ),
          ),
          // Ambient Glow 2
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF70aaff).withValues(alpha: 0.03),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF70aaff).withValues(alpha: 0.03), blurRadius: 120),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Library',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Organize and explore your visual archive.',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.primary.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 48),

                  // System Albums Header
                  Text(
                    'System Albums',
                    style: AppTheme.headingStyle.copyWith(fontSize: 24),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // System Albums Bento Grid
                  SizedBox(
                    height: 320,
                    child: Row(
                      children: [
                        // Left Column (Recents - spans full height)
                        Expanded(
                          flex: 2,
                          child: _buildBentoCard(
                            title: 'Recents',
                            subtitle: '$_totalPhotos Items',
                            icon: Icons.schedule,
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA8VLpk65I7_2Xj-leOiK53_Z0eiUMRX3ucYOzJ8XwtvjPXSmixEz4Gc6kmII_mK4oNu2WXA8ayTyAYa0Y468ZhrbP0fSvciDijUNQgwGrDUfyToCpA9w1C1z9FcVgm7TB1Q994lI-tDQJnYNAKrKWXo1rxMRNCqE5d67u7TqWlmIx6XD18HFrAD5M_lfbLHmt71IAmWV_OOYwtymxYBMvcKd89JcvDD3LSYd3OPQpNbbtXgLc3DMmxE34iY9PpYWHcGtYiIHVvjGU',
                            isLarge: true,
                            delay: 400,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Column (2 stacked items)
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(
                                child: _buildBentoCard(
                                  title: 'Favorites',
                                  subtitle: '142 Items',
                                  icon: Icons.favorite,
                                  isLarge: false,
                                  iconScale: true,
                                  delay: 500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _buildBentoCard(
                                  title: 'Videos',
                                  subtitle: '$_videoCount Items',
                                  icon: Icons.movie,
                                  isLarge: false,
                                  iconScale: true,
                                  delay: 600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Second Row of System Albums
                  SizedBox(
                    height: 140,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBentoCard(
                            title: 'Screenshots',
                            subtitle: '$_screenshotCount Items',
                            icon: Icons.screenshot,
                            isLarge: false,
                            delay: 700,
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [AppTheme.surfaceContainerHigh, AppTheme.surfaceContainerLow],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBentoCard(
                            title: 'Selfies',
                            subtitle: '12 Items',
                            icon: Icons.person,
                            isLarge: false,
                            delay: 800,
                            gradient: const LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [AppTheme.surfaceContainerHigh, AppTheme.surfaceContainerLow],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // My Tags Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'My Tags',
                        style: AppTheme.headingStyle.copyWith(fontSize: 24),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All',
                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 24),

                  // Tag Chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildTagChip('Architecture', 42, isActive: true),
                      _buildTagChip('Portraits', 18),
                      _buildTagChip('Landscapes', 105),
                      _buildTagChip('Macro', 7),
                      _buildTagChip('New Tag', 0, isAdd: true),
                    ],
                  ).animate().fadeIn(delay: 1000.ms),

                  const SizedBox(height: 32),

                  // Curated Tag Preview Grid
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        // Left Large Image
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: const DecorationImage(
                                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCe5Y0KiEw-a_ZgB_hu8VfSD9yFyFRDDkd2Oyd9uOOaS59KVnhxDswLQK7KvnoE0jG2j6joWRpOT4FhV9ukvAh2iu7iAiPiXU6IPr9MGqm_wN2Bd2nJPV5T_GKyMFWYHp-SlnR-Cmk7a7H2K9djfht2Py2Bo3r7TeLaYGkK6eJhS6d3tLC0BuBf51lJIbraH0rKykodCC9_rFuief5muPTyBjcKg7yyEO16j4ZLDHdWtEdFtdyD5EFfEKdDRoZIMHe8AnPK3tf3RIE'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text('Minimalist Concrete', style: AppTheme.headingStyle.copyWith(fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Stacked Images
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAzQLPrslp8kQrDYzP72ORf2A6h7h0hJpdpfEX5ImzF8fyWsucH13cGG_cYOwMz7CYlBgf2mAud-pQW9lnL-gdqNq9lc9ezrsbny2mcg4R_wEmBVosHexvOR97UynYANf8LnlR6bCleQJWTW3UO4ydqdkCvzob8AbghfBaVgggxTTeRCJrMSONia_SVxzs2rZpOfs8GdOrpUsmCr-3eLIKyML6n8kyBOrKyP51z3tBscdkLsgQT6DfM_hBppVRigkx6RaoirqwTrfQ'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('+39', style: AppTheme.headingStyle.copyWith(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.w300)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? imageUrl,
    required bool isLarge,
    bool iconScale = false,
    LinearGradient? gradient,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        image: imageUrl != null ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
        ) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (iconScale)
              Center(
                child: Icon(icon, size: 80, color: AppTheme.primary.withValues(alpha: 0.1)),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: AppTheme.primary, size: isLarge ? 24 : 20),
                      if (isLarge) ...[
                        const SizedBox(width: 12),
                        Text(title, style: AppTheme.headingStyle.copyWith(fontSize: 20)),
                      ]
                    ],
                  ),
                  if (!isLarge) ...[
                    const SizedBox(height: 8),
                    Text(title, style: AppTheme.headingStyle.copyWith(fontSize: 16)),
                  ],
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                ],
              ),
            ),
            if (isLarge)
              Positioned(
                top: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
                        border: Border.all(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryContainer,
                            ),
                          ).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
                          const SizedBox(width: 6),
                          Text('ACTIVE', style: AppTheme.labelStyle.copyWith(fontSize: 10, color: AppTheme.onSurface)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTagChip(String label, int count, {bool isActive = false, bool isAdd = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00677D) // secondary-container
            : AppTheme.surfaceVariant.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? null
            : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdd ? Icons.add : Icons.label,
            size: 18,
            color: isActive ? const Color(0xFFEDFAFF) : AppTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFFEDFAFF) : AppTheme.onSurface,
            ),
          ),
          if (!isAdd) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFEDFAFF).withValues(alpha: 0.2)
                    : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                count.toString(),
                style: AppTheme.labelStyle.copyWith(
                  fontSize: 10,
                  color: isActive ? const Color(0xFFEDFAFF) : AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
