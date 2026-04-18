import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/nav_provider.dart';
import '../../core/theme.dart';

class FloatingBottomNav extends ConsumerWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navTabProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          height: 80 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1E).withValues(alpha: 0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 32,
                offset: const Offset(0, -8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(
                tab: NavTab.home,
                icon: PhosphorIcons.house(),
                fillIcon: PhosphorIcons.house(),
                isActive: currentTab == NavTab.home,
              ),
              _NavIcon(
                tab: NavTab.swipe,
                icon: PhosphorIcons.cards(),
                fillIcon: PhosphorIcons.cards(),
                isActive: currentTab == NavTab.swipe,
              ),
              _NavIcon(
                tab: NavTab.reels,
                icon: PhosphorIcons.filmReel(),
                fillIcon: PhosphorIcons.filmReel(),
                isActive: currentTab == NavTab.reels,
              ),
              _NavIcon(
                tab: NavTab.folders,
                icon: PhosphorIcons.folder(),
                fillIcon: PhosphorIcons.folder(),
                isActive: currentTab == NavTab.folders,
              ),
              _NavIcon(
                tab: NavTab.trash,
                icon: PhosphorIcons.trash(),
                fillIcon: PhosphorIcons.trash(),
                isActive: currentTab == NavTab.trash,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutQuart);
  }
}

class _NavIcon extends ConsumerWidget {
  final NavTab tab;
  final PhosphorIconData icon;
  final PhosphorIconData fillIcon;
  final bool isActive;

  const _NavIcon({
    required this.tab,
    required this.icon,
    required this.fillIcon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(navTabProvider.notifier).setTab(tab);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: PhosphorIcon(
          isActive ? fillIcon : icon,
          color: isActive ? AppTheme.primary : AppTheme.onSurface.withValues(alpha: 0.4),
          size: 24,
        ),
      ).animate(target: isActive ? 1 : 0).scale(
        begin: const Offset(1, 1),
        end: const Offset(0.9, 0.9),
        duration: 150.ms,
      ),
    );
  }
}
