import 'package:go_router/go_router.dart';

import 'package:tiktok/core/router/scaffold_with_nav_bar.dart';
import 'package:tiktok/features/feed/screens/feed_screen.dart';
import 'package:tiktok/features/settings/screens/settings_screen.dart';

/// 앱 라우터. 홈/설정을 가진 바텀 탭바 셸을 구성한다.
/// [StatefulShellRoute.indexedStack]으로 각 탭의 상태(피드 스크롤 위치 등)를 보존한다.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, _) => const FeedScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
