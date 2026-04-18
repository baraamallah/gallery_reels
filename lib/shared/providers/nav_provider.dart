import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_provider.g.dart';

enum NavTab { home, swipe, reels, folders, trash }

@riverpod
class NavTabNotifier extends _$NavTabNotifier {
  @override
  NavTab build() => NavTab.home;
  
  void setTab(NavTab tab) => state = tab;
}
