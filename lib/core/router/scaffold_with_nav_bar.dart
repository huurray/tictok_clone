import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tiktok/features/feed/providers/video_manager.dart';
import 'package:tiktok/l10n/gen/app_localizations.dart';

/// 바텀 탭바 셸. 홈/설정 브랜치를 [IndexedStack]으로 유지하고,
/// 탭이 바뀔 때 피드 영상의 재생/일시정지를 토글한다.
class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onTap(WidgetRef ref, int index) {
    // 홈(0)을 벗어나면 영상 멈추고, 홈으로 오면 재생.
    ref.read(videoManagerProvider).setFeedVisible(index == 0);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(ref, index),
        backgroundColor: Colors.black,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
