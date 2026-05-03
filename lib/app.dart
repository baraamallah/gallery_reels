import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'core/app_settings.dart';
import 'core/theme.dart';
import 'shared/widgets/bottom_nav.dart';
import 'shared/providers/nav_provider.dart';
import 'features/home/home_screen.dart';
import 'features/swipe/swipe_screen.dart';
import 'features/reels/reels_screen.dart';
import 'features/folders/folders_screen.dart';
import 'features/folders/favorites_screen.dart';
import 'features/trash/trash_screen.dart';
import 'onboarding/splash_screen.dart';
import 'shared/widgets/app_drawer.dart';

class GalleryReelsApp extends ConsumerWidget {
  const GalleryReelsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      title: 'Gallery Reels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const SplashScreen(), // Start with splash
    );
  }
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navTabProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      extendBody: true,
      body: Stack(
        children: [
          _buildPage(currentTab),
          
          // Only show top bar if not in Reels tab (which is full-screen)
          if (currentTab != NavTab.reels)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    height: 64 + MediaQuery.of(context).padding.top,
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 12, right: 24),
                    color: cs.surface.withValues(alpha: 0.8),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu, color: cs.onSurface),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTitle(currentTab),
                          style: AppTheme.headingStyle(context).copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Floating Bottom Nav
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  String _getTitle(NavTab tab) {
    switch (tab) {
      case NavTab.home:
        return 'Gallery Reels';
      case NavTab.swipe:
        return 'Start Cleaning';
      case NavTab.reels:
        return 'Reels';
      case NavTab.favorites:
        return 'Favorites';
      case NavTab.folders:
        return 'Library';
      case NavTab.trash:
        return 'Trash';
    }
  }

  Widget _buildPage(NavTab tab) {
    switch (tab) {
      case NavTab.home:
        return const HomeScreen();
      case NavTab.swipe:
        return const SwipeScreen();
      case NavTab.reels:
        return const ReelsScreen();
      case NavTab.favorites:
        return const FavoritesScreen();
      case NavTab.folders:
        return const FoldersScreen();
      case NavTab.trash:
        return const TrashScreen();
    }
  }
}
