import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'shared/widgets/bottom_nav.dart';
import 'shared/providers/nav_provider.dart';
import 'features/home/home_screen.dart';
import 'features/swipe/swipe_screen.dart';
import 'features/reels/reels_screen.dart';
import 'features/folders/folders_screen.dart';
import 'features/trash/trash_screen.dart';
import 'onboarding/splash_screen.dart';

class GalleryReelsApp extends StatelessWidget {
  const GalleryReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery Reels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(), // Start with splash
    );
  }
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navTabProvider);

    return Scaffold(
      extendBody: true, // Crucial for floating nav bar
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: AppTheme.backgroundGradient,
          ),
          
          // Current Page
          _buildPage(currentTab),

          // Floating Bottom Nav
          const Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(NavTab tab) {
    switch (tab) {
      case NavTab.home:
        return const HomeScreen();
      case NavTab.swipe:
        return const SwipeScreen();
      case NavTab.reels:
        return const ReelsScreen();
      case NavTab.folders:
        return const FoldersScreen();
      case NavTab.trash:
        return const TrashScreen();
    }
  }
}
