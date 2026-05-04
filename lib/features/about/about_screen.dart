import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/log_service.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _tapCount = 0;

  void _handleSecretTap() {
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      _showPinDialog();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    final canLaunch = await canLaunchUrl(uri);
    debugPrint('CAN LAUNCH $url: $canLaunch');
    
    if (canLaunch) {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('EXTERNAL LAUNCH SUCCESS: $success');
    } else {
      debugPrint('EXTERNAL RESOLUTION FAILED, TRYING IN-APP FALLBACK...');
      // Fallback test: try to open in an in-app browser view
      try {
        final success = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        debugPrint('IN-APP LAUNCH SUCCESS: $success');
      } catch (e) {
        debugPrint('IN-APP LAUNCH FAILED: $e');
      }
    }
  }

  void _sendEmail({required String subject}) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppConstants.developerEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent("Hi ${AppConstants.developerName.split(' ').first},\n\nI am using ${AppConstants.appName} and wanted to share...")}',
    );
    launchUrl(emailLaunchUri);
  }

  void _showPinDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Developer Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the security PIN to view system logs and debug data.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'PIN',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text == '8888') {
                Navigator.pop(context);
                _showLogs();
              } else {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied')));
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _showLogs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('System Logs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    LogService.instance.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs cleared')));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: LogService.instance.allLogs));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs copied to clipboard')));
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                LogService.instance.allLogs.isEmpty ? 'No logs yet.' : LogService.instance.allLogs,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('About App'),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.15),
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(duration: 2.seconds),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.error.withValues(alpha: 0.1),
              ),
            ).animate().fadeIn(duration: 1.seconds, delay: 500.ms),
          ),

          ListView(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 80, 24, 40),
            children: [
              // Header / Logo Section
              Center(
                child: GestureDetector(
                  onTap: _handleSecretTap,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Icon(PhosphorIcons.sparkle(), size: 48, color: cs.primary),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 20),
                      Text(
                        AppConstants.appName,
                        style: AppTheme.headingStyle(context).copyWith(fontSize: 32),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      const SizedBox(height: 4),
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, letterSpacing: 0.5),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Developer Section
              _SectionTitle(title: 'Developer'),
              const SizedBox(height: 12),
              _ModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: cs.primaryContainer,
                        child: Icon(PhosphorIcons.user(), color: cs.onPrimaryContainer, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppConstants.developerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cs.onSurface)),
                            const SizedBox(height: 4),
                            Text(
                              'Crafting clean, efficient mobile experiences with Flutter.',
                              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),

              const SizedBox(height: 32),

              // Project Section
              _SectionTitle(title: 'Project'),
              const SizedBox(height: 12),
              _ModernCard(
                child: Column(
                  children: [
                    _ActionTile(
                      icon: PhosphorIcons.githubLogo(),
                      title: 'GitHub Repository',
                      subtitle: 'Check out the source code',
                      onTap: () => _launchUrl(AppConstants.githubRepoUrl),
                    ),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 56),
                    _ActionTile(
                      icon: PhosphorIcons.bug(),
                      title: 'Report a Bug',
                      subtitle: 'Found an issue? Let me know.',
                      onTap: () => _sendEmail(subject: 'Bug Report: ${AppConstants.appName}'),
                    ),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 56),
                    _ActionTile(
                      icon: PhosphorIcons.paperPlaneTilt(),
                      title: 'Send Feedback',
                      subtitle: 'Suggestions or feature requests',
                      onTap: () => _sendEmail(subject: 'Feedback: ${AppConstants.appName}'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05),

              const SizedBox(height: 32),

              // Info Section
              _SectionTitle(title: 'Information'),
              const SizedBox(height: 12),
              _ModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: PhosphorIcons.shieldCheck(),
                        title: 'Privacy Focused',
                        desc: 'All processing happens on your device. No data ever leaves the app.',
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: PhosphorIcons.lightning(),
                        title: 'Clean & Fast',
                        desc: 'Built with optimized performance in mind for large libraries.',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

              const SizedBox(height: 48),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Made with ❤️ for ${AppConstants.appName}',
                      style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: [
                        _FooterLink(label: 'Licenses', onTap: () => showLicensePage(context: context)),
                        _FooterLink(
                          label: 'Privacy Policy', 
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ModernCard extends StatelessWidget {
  final Widget child;
  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedScaleButton({required this.child, required this.onTap});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final PhosphorIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _AnimatedScaleButton(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: PhosphorIcon(icon, size: 20, color: cs.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final PhosphorIconData icon;
  final String title;
  final String desc;

  const _InfoRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhosphorIcon(icon, size: 24, color: cs.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

