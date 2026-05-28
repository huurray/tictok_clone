import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/data/repositories/video_repository.dart';

final videoRepositoryProvider = Provider<VideoRepository>(
  (ref) => VideoRepository(),
);

/// (점점 늘어나는) 피드 항목 목록을 보관하고, 무한 스크롤 로딩과
/// 좋아요 변경을 제공한다.
class FeedNotifier extends AsyncNotifier<List<VideoModel>> {
  int _nextPage = 0;
  bool _isLoadingMore = false;

  @override
  Future<List<VideoModel>> build() async {
    final first = await ref.read(videoRepositoryProvider).fetchPage(0);
    _nextPage = 1;
    return first;
  }

  /// 다음 페이지를 덧붙인다. 스크롤 이벤트가 겹쳐도 중복 로드되지 않도록 가드한다.
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

  /// 좋아요 버튼에서의 토글.
  void toggleLike(int index) => _mutate(index, (v) => v.toggleLike());

  /// 더블탭에서의 좋아요(취소하지 않음).
  void like(int index) => _mutate(index, (v) => v.liked());

  /// 북마크 토글.
  void toggleBookmark(int index) => _mutate(index, (v) => v.toggleBookmark());

  void _mutate(int index, VideoModel Function(VideoModel) transform) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.length) return;
    final updated = [...current];
    updated[index] = transform(updated[index]);
    state = AsyncData(updated);
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<VideoModel>>(
  FeedNotifier.new,
);
