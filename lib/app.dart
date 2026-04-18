import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
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
          // Background color
          Container(
            color: AppTheme.background,
          ),
          
          // Current Page
          _buildPage(currentTab),

          // Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  height: 64 + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 24, right: 24),
                  color: const Color(0xFF171A1E).withValues(alpha: 0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: AppTheme.onSurface),
                        onPressed: () {},
                      ),
                      Text(
                        'Gallery Reels',
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                          image: const DecorationImage(
                            image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuC3hLDPbkZ9C_6nleoYQVIavOMsl4pUtMb1z9HnZ6b_4q4BEB-TWwYjKuTl5MTeP1yb1Xs-O3rnbH0nSHns5Zf7yA_nDottzQ2Curj0IK0n6piyP8-4-tdF-WJgWD2yTDdtBUNh5FcLCs-PrmByjm9_DnJ8YTRgREo2eDLJpDOX47PHbVAJWDusZedhol88kk96WxKvlXLRC5qpoh9Njf-ypKEIPwsnCvkefLUJ0MJ5VB887bgcLALSuLZW2cQMb4OH0DTCg939QpA"),
                            fit: BoxFit.cover,
                          ),
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
