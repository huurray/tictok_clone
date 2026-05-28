import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/feed_provider.dart';
import '../providers/video_manager.dart';
import '../widgets/video_item.dart';

/// The vertical short-video feed. Owns the [PageController], drives the
/// [VideoManager] on page changes, triggers infinite-scroll loading near the
/// end, and pauses playback on app background / screen exit.
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
    _lifecycleListener =
        AppLifecycleListener(onStateChange: _onLifecycleChange);
  }

  void _onLifecycleChange(AppLifecycleState state) {
    final manager = ref.read(videoManagerProvider);
    if (state == AppLifecycleState.resumed) {
      manager.onAppResumed();
    } else {
      manager.onAppPaused();
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
            return const Center(
              child: Text('No videos', style: TextStyle(color: Colors.white70)),
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
          const Text(
            'Failed to load feed',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
