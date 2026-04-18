import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme.dart';
import '../../shared/widgets/glass_card.dart';

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
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 32),
                      _buildDescriptionSection(),
                      const SizedBox(height: 32),
                      _buildSocialGrid(),
                      const SizedBox(height: 48),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text('About', style: AppTheme.headingStyle.copyWith(fontSize: 20)),
          const Spacer(),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.accentColor, AppTheme.shareColor],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text(
          'Baraa El Mallah',
          style: AppTheme.headingStyle.copyWith(fontSize: 28),
        ).animate().fadeIn(delay: 200.ms),
        Text(
          'Curating with passion',
          style: AppTheme.captionStyle.copyWith(fontSize: 16),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App Description', style: AppTheme.headingStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Text(
            'SnapClean is a premium gallery management tool designed to help you declutter and organize your photos with ease. Experience a smoother, faster, and more beautiful way to keep what matters.',
            style: AppTheme.bodyStyle.copyWith(height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildSocialGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _SocialButton(
          title: 'Instagram',
          icon: PhosphorIcons.instagramLogo(),
          color: const Color(0xFFE1306C),
          onTap: () => _launchUrl('https://instagram.com/baraael_mallah_'), // Placeholder
        ),
        _SocialButton(
          title: 'GitHub',
          icon: PhosphorIcons.githubLogo(),
          color: Colors.white70,
          onTap: () => _launchUrl('https://github.com/baraamallah'), // Placeholder
        ),
        _SocialButton(
          title: 'Linktree',
          icon: PhosphorIcons.link(),
          color: const Color(0xFF39E09B),
          onTap: () => _launchUrl('https://linktr.ee/baraael_mallah_'), // Placeholder
        ),
        _SocialButton(
          title: 'Portfolio',
          icon: PhosphorIcons.globe(),
          color: AppTheme.accentColor,
          onTap: () {},
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Version 1.0.0',
          style: AppTheme.captionStyle,
        ),
        const SizedBox(height: 8),
        const Text(
          'Built with Flutter & ❤️ by Baraa El Mallah',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
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
      child: GlassCard(
        opacity: 0.05,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            PhosphorIcon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTheme.headingStyle.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
