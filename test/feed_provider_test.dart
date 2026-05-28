import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/data/repositories/video_repository.dart';
import 'package:tiktok/features/feed/providers/feed_provider.dart';

/// Instant, deterministic repository so the notifier logic can be tested
/// without network latency.
class _FakeRepo extends VideoRepository {
  const _FakeRepo();

  @override
  Future<List<VideoModel>> fetchPage(int page, {int pageSize = 5}) async {
    return List.generate(
      pageSize,
      (i) => VideoModel(
        id: 'p${page}_$i',
        videoUrl: 'u',
        username: '@u',
        caption: 'c',
        musicTitle: 'm',
        avatarUrl: 'a',
        likeCount: 100,
        commentCount: 0,
        shareCount: 0,
      ),
    );
  }
}

ProviderContainer _makeContainer() => ProviderContainer(
      overrides: [
        videoRepositoryProvider.overrideWith((ref) => const _FakeRepo()),
      ],
    );

void main() {
  test('build loads the first page', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    final list = await container.read(feedProvider.future);
    expect(list.length, 5);
  });

  test('loadMore appends the next page', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(feedProvider.future);
    await container.read(feedProvider.notifier).loadMore();

    expect(container.read(feedProvider).value!.length, 10);
  });

  test('toggleLike flips like state and adjusts the count', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(feedProvider.future);
    container.read(feedProvider.notifier).toggleLike(0);

    final item = container.read(feedProvider).value![0];
    expect(item.isLiked, true);
    expect(item.likeCount, 101);
  });

  test('like is idempotent (double-tap cannot over-count)', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(feedProvider.future);
    container.read(feedProvider.notifier).like(0);
    container.read(feedProvider.notifier).like(0);

    final item = container.read(feedProvider).value![0];
    expect(item.isLiked, true);
    expect(item.likeCount, 101);
  });
}
