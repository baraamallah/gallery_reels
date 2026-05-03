import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_settings.dart';
import '../../features/about/about_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  /// 🌓 Easter egg: long-press the app title to toggle theme instantly.
  void _onTitleLongPress() {
    final settings = ref.read(appSettingsProvider);
    ThemeMode next;
    switch (settings.themeMode) {
      case ThemeMode.dark:
        next = ThemeMode.light;
        break;
      case ThemeMode.light:
        next = ThemeMode.system;
        break;
      case ThemeMode.system:
        next = ThemeMode.dark;
        break;
    }
    ref.read(appSettingsProvider.notifier).setThemeMode(next);

    final label = next == ThemeMode.dark
        ? '🌙 Dark mode'
        : next == ThemeMode.light
            ? '☀️ Light mode'
            : '🌓 System theme';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label enabled  •  psst, secret shortcut!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ── App title — long-press for theme toggle easter egg ──────
            GestureDetector(
              onLongPress: _onTitleLongPress,
              child: ListTile(
                leading: Icon(Icons.auto_awesome, color: cs.primary),
                title: const Text('Gallery Reels'),
                subtitle: const Text('Clean your gallery, fast.'),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Offline-first • No ads • Open source friendly',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
