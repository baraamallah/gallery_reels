import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/nav_provider.dart';
import '../../core/theme.dart';
import 'glass_card.dart';

class FloatingBottomNav extends ConsumerWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navTabProvider);

    return GlassCard(
      borderRadius: 40,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(
            tab: NavTab.home,
            icon: PhosphorIcons.house(),
            isActive: currentTab == NavTab.home,
          ),
          _NavIcon(
            tab: NavTab.swipe,
            icon: PhosphorIcons.cards(),
            isActive: currentTab == NavTab.swipe,
          ),
          _NavIcon(
            tab: NavTab.reels,
            icon: PhosphorIcons.filmReel(),
            isActive: currentTab == NavTab.reels,
          ),
          _NavIcon(
            tab: NavTab.folders,
            icon: PhosphorIcons.folder(),
            isActive: currentTab == NavTab.folders,
          ),
          _NavIcon(
            tab: NavTab.trash,
            icon: PhosphorIcons.trash(),
            isActive: currentTab == NavTab.trash,
          ),
        ],
      ),
    ).animate().slideY(begin: 1.5, duration: 800.ms, curve: Curves.easeOutQuart).fadeIn();
  }
}

class _NavIcon extends ConsumerWidget {
  final NavTab tab;
  final PhosphorIconData icon;
  final bool isActive;

  const _NavIcon({
    required this.tab,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(navTabProvider.notifier).setTab(tab);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              color: isActive ? AppTheme.accentColor : Colors.white.withValues(alpha: 0.5),
              size: 26,
            ),
          ],
        ),
      ).animate(target: isActive ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
    );
  }
}
