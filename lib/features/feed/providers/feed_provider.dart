import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/video_model.dart';
import '../../../data/repositories/video_repository.dart';

final videoRepositoryProvider = Provider<VideoRepository>(
  (ref) => const VideoRepository(),
);

/// Holds the (growing) list of feed items and exposes infinite-scroll loading
/// and like mutations.
class FeedNotifier extends AsyncNotifier<List<VideoModel>> {
  int _nextPage = 0;
  bool _isLoadingMore = false;

  @override
  Future<List<VideoModel>> build() async {
    final first = await ref.read(videoRepositoryProvider).fetchPage(0);
    _nextPage = 1;
    return first;
  }

  /// Append the next page. Guarded so overlapping scroll events don't double-load.
  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    final current = state.value;
    if (current == null) return;

    _isLoadingMore = true;
    try {
      final next = await ref.read(videoRepositoryProvider).fetchPage(_nextPage);
      _nextPage++;
      state = AsyncData([...current, ...next]);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Toggle like from the like button.
  void toggleLike(int index) => _mutate(index, (v) => v.toggleLike());

  /// Like from a double-tap (never unlikes).
  void like(int index) => _mutate(index, (v) => v.liked());

  void _mutate(int index, VideoModel Function(VideoModel) transform) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.length) return;
    final updated = [...current];
    updated[index] = transform(updated[index]);
    state = AsyncData(updated);
  }
}

final feedProvider =
    AsyncNotifierProvider<FeedNotifier, List<VideoModel>>(FeedNotifier.new);
