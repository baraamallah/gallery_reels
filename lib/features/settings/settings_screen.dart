import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_settings.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../swipe/swipe_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Settings', style: AppTheme.headingStyle(context).copyWith(fontSize: 22)),
        centerTitle: false,
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader(title: 'Appearance', icon: PhosphorIcons.palette()),
          _SettingsCard(
            children: [
              _SettingTile(
                title: 'Theme Mode',
                subtitle: _themeLabel(settings.themeMode),
                trailing: _ThemeDropdown(currentMode: settings.themeMode),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          _SectionHeader(title: 'Cleaning Session', icon: PhosphorIcons.sparkle()),
          _SettingsCard(
            children: [
              _SettingTile(
                title: 'Media Type',
                subtitle: 'Include items in swiping sessions',
                trailing: _MediaDropdown(currentMode: settings.mediaMode),
              ),
              const Divider(indent: 20, endIndent: 20),
              _SettingTile(
                title: 'Delete Behavior',
                subtitle: _deleteLabel(settings.deleteMode),
                trailing: _DeleteDropdown(currentMode: settings.deleteMode),
              ),
              const Divider(indent: 20, endIndent: 20),
              _SettingTile(
                title: 'Target Folders',
                subtitle: settings.includedAlbumIds.isEmpty 
                    ? 'All folders (default)' 
                    : '${settings.includedAlbumIds.length} folders selected',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SwipeScreen(folderSelectOnly: true)),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Memory & Performance', icon: PhosphorIcons.cpu()),
          _SettingsCard(
            children: [
              _SettingTile(
                title: 'Library Mode',
                subtitle: settings.enableLibrary ? 'Enabled (uses more memory)' : 'Disabled (performance mode)',
                trailing: Switch(
                  value: settings.enableLibrary,
                  onChanged: (v) => ref.read(appSettingsProvider.notifier).setEnableLibrary(v),
                ),
              ),
              const Divider(indent: 20, endIndent: 20),
              _SettingTile(
                title: 'Import Limit',
                subtitle: 'Load assets in parts for speed',
                trailing: DropdownButton<int>(
                  value: settings.loadLimit,
                  underline: const SizedBox.shrink(),
                  onChanged: (v) => v != null ? ref.read(appSettingsProvider.notifier).setLoadLimit(v) : null,
                  items: const [
                    DropdownMenuItem(value: 500, child: Text('500 items')),
                    DropdownMenuItem(value: 1000, child: Text('1000 items')),
                    DropdownMenuItem(value: 2500, child: Text('2500 items')),
                    DropdownMenuItem(value: 5000, child: Text('5000 items')),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Help & FAQ', icon: PhosphorIcons.question()),
          _SettingsCard(
            children: [
              _SettingTile(
                title: 'System Bin Permission',
                subtitle: 'Why does it ask "Allow"?',
                trailing: const Icon(Icons.info_outline, size: 20),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('System Bin Permission'),
                      content: const Text(
                        'Android & iOS require user permission for every deletion to protect your files.\n\n'
                        'Tip: Use "In-App Trash" to swipe without interruptions. You can empty the trash once at the end.',
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Got it'))],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'System & Permissions', icon: PhosphorIcons.shieldCheck()),
          _SettingsCard(
            children: [
              _SettingTile(
                title: 'Gallery Access',
                subtitle: 'Manage photo/video permissions',
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => PhotoManager.openSetting(),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: AppTheme.captionStyle(context),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
      case ThemeMode.system: return 'System Default';
    }
  }

  String _deleteLabel(DeleteMode mode) {
    switch (mode) {
      case DeleteMode.systemTrash: return 'System Bin';
      case DeleteMode.inAppTrash: return 'In-App Trash';
      case DeleteMode.permanent: return 'Immediate Delete';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final PhosphorIconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          PhosphorIcon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: AppTheme.labelStyle(context).copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _ThemeDropdown extends ConsumerWidget {
  final ThemeMode currentMode;
  const _ThemeDropdown({required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<ThemeMode>(
      value: currentMode,
      underline: const SizedBox.shrink(),
      onChanged: (v) => v != null ? ref.read(appSettingsProvider.notifier).setThemeMode(v) : null,
      items: const [
        DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
        DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
      ],
    );
  }
}

class _MediaDropdown extends ConsumerWidget {
  final MediaMode currentMode;
  const _MediaDropdown({required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<MediaMode>(
      value: currentMode,
      underline: const SizedBox.shrink(),
      onChanged: (v) => v != null ? ref.read(appSettingsProvider.notifier).setMediaMode(v) : null,
      items: const [
        DropdownMenuItem(value: MediaMode.photosAndVideos, child: Text('All Media')),
        DropdownMenuItem(value: MediaMode.photosOnly, child: Text('Photos Only')),
        DropdownMenuItem(value: MediaMode.videosOnly, child: Text('Videos Only')),
      ],
    );
  }
}

class _DeleteDropdown extends ConsumerWidget {
  final DeleteMode currentMode;
  const _DeleteDropdown({required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButton<DeleteMode>(
      value: currentMode,
      underline: const SizedBox.shrink(),
      onChanged: (v) async {
        if (v == null) return;
        if (v == DeleteMode.permanent) {
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Permanent Delete?'),
              content: const Text('Items will be erased immediately. This cannot be undone. Recommended: In-App Trash.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Enable')),
              ],
            ),
          );
          if (ok != true) return;
        }
        await ref.read(appSettingsProvider.notifier).setDeleteMode(v);
      },
      items: [
        const DropdownMenuItem(value: DeleteMode.systemTrash, child: Text('System Bin')),
        const DropdownMenuItem(value: DeleteMode.inAppTrash, child: Text('In-App Trash')),
        DropdownMenuItem(
          value: DeleteMode.permanent, 
          child: Text('Immediate', style: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
