import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Privacy Policy'),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          ListView(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 80, 24, 40),
            children: [
              _PolicySection(
                icon: PhosphorIcons.shieldCheck(),
                title: 'Data Sovereignty',
                content: 'Gallery Reels is built on the principle of local-first computing. We do not collect, store, or transmit your media files to any external server. Your photos and videos stay exactly where they belong: on your device.',
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 24),
              
              _PolicySection(
                icon: PhosphorIcons.eyeSlash(),
                title: 'No Analytics',
                content: 'We believe your usage patterns are your own business. The app contains zero third-party tracking scripts, analytics SDKs, or advertising identifiers. We don\'t know how many photos you delete, and we don\'t want to.',
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 24),
              
              _PolicySection(
                icon: PhosphorIcons.lockKey(),
                title: 'Permissions',
                content: 'The app only requests access to your photo library to provide its core functionality. These permissions are used exclusively to display your media for cleaning and to perform the deletion actions you explicitly authorize.',
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 24),
              
              _PolicySection(
                icon: PhosphorIcons.hardDrive(),
                title: 'Local Storage',
                content: 'Settings and session data are stored in a local encrypted storage on your device. This data is deleted if you uninstall the app.',
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 48),

              Center(
                child: Text(
                  'Last Updated: May 2026',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final PhosphorIconData icon;
  final String title;
  final String content;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(icon, size: 22, color: cs.primary),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
