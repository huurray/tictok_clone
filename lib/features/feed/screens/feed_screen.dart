import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/core/constants/app_constants.dart';
import 'package:tiktok/features/feed/providers/feed_provider.dart';
import 'package:tiktok/features/feed/providers/video_manager.dart';
import 'package:tiktok/features/feed/widgets/video_item.dart';
import 'package:tiktok/l10n/gen/app_localizations.dart';

/// 세로 숏폼 영상 피드. [PageController]를 소유하고, 페이지 전환 시
/// [VideoManager]를 구동하며, 끝 근처에서 무한 스크롤 로딩을 트리거하고,
/// 앱 백그라운드/화면 이탈 시 재생을 멈춘다.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PageController _pageController = PageController();
  AppLifecycleListener? _lifecycleListener;
  bool _activatedFirst = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: _onLifecycleChange,
    );
  }

  void _onLifecycleChange(AppLifecycleState state) {
    final manager = ref.read(videoManagerProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        manager.onAppResumed();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        manager.onAppPaused();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // 일시적 상태(시작 중 blip·제어센터·앱 전환 미리보기)는 무시 — 재생 유지.
        break;
    }
  }

  @override
  void dispose() {
    ref.read(videoManagerProvider).pauseAll();
    _lifecycleListener?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, int total) {
    ref.read(videoManagerProvider).setActive(index);
    if (index >= total - AppConstants.loadMoreThreshold) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            _ErrorView(onRetry: () => ref.invalidate(feedProvider)),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noVideos,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!_activatedFirst) {
            _activatedFirst = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(videoManagerProvider).setActive(0);
            });
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: videos.length,
            onPageChanged: (index) => _onPageChanged(index, videos.length),
            itemBuilder: (context, index) =>
                VideoItem(index: index, video: videos[index]),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 48),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).feedLoadError,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
}
