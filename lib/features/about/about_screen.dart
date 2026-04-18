import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui';
import '../../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: 200,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 40),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 48),
                        _buildConnectSection(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'LUMINOUS',
            style: AppTheme.headingStyle.copyWith(
              fontSize: 20,
              color: AppTheme.primary,
              letterSpacing: 4.0,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceContainerHigh,
              border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.person, size: 16, color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Hero Image
        Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.background, width: 4),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBLaHtwYgY-rDYfOtJDzo8nmP6MPl9YyFt0xjGjYGdTle04rOrduFrb_hdchYQxziOBywF9D5w7vPPl14KBOcvYbYRSe5UxatZcoHIpaQdvRTvnlDoUm7N-3Q73T5gckWbV28JfKTE2rgO4GlkWdgX6QRHGDz0s1Iy4eH_uA19Z42fxY2FzB5xu5kttGriqqPaChcOT0TBdm3PCjauVxI1IJddeuXdfw50hAa-jJv_ljwQy9qF_zlqYLNqVr__Ew0hBs9rkaWMoErQ'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 32),

        Text(
          'Baraa El Mallah',
          style: AppTheme.headingStyle.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: 8),

        Text(
          'Lead Developer & Designer',
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 18,
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

        const SizedBox(height: 24),

        Text(
          'Crafting immersive digital experiences through code and light. The vision for Gallery Reels is to build a visual archive that feels alive—where every interaction is fluid and every pixel has purpose. Building beyond standard templates to create spaces that feel like curated galleries rather than mere software.',
          textAlign: TextAlign.center,
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 16,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildConnectSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.surfaceVariant.withValues(alpha: 0.2), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          Text('Connect', style: AppTheme.headingStyle.copyWith(fontSize: 24)),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _SocialButton(
                title: 'Instagram',
                icon: PhosphorIcons.instagramLogo(),
                color: const Color(0xFFE1306C),
                onTap: () => _launchUrl('https://instagram.com/baraael_mallah_'),
              ),
              _SocialButton(
                title: 'GitHub',
                icon: PhosphorIcons.githubLogo(),
                color: Colors.white,
                onTap: () => _launchUrl('https://github.com/baraamallah'),
              ),
              _SocialButton(
                title: 'Linktree',
                icon: PhosphorIcons.link(),
                color: const Color(0xFF39E09B),
                onTap: () => _launchUrl('https://linktr.ee/baraael_mallah_'),
              ),
              _SocialButton(
                title: 'Portfolio',
                icon: PhosphorIcons.globe(),
                color: AppTheme.primary,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }
}

class _SocialButton extends StatelessWidget {
  final String title;
  final PhosphorIconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: PhosphorIcon(icon, color: color, size: 24),
                  ),
                ),
                const SizedBox(height: 12),
                Text(title, style: AppTheme.bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: color.withValues(alpha: 0.1));
  }
}
