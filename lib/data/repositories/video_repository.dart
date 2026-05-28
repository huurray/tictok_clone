import '../../core/constants/app_constants.dart';
import '../models/video_model.dart';
import '../sources/mock_videos.dart';

/// Simulates a paginated backend over [mockVideos]. The pool is cycled to
/// produce an effectively endless feed, with a unique id per item per page.
class VideoRepository {
  const VideoRepository();

  Future<List<VideoModel>> fetchPage(
    int page, {
    int pageSize = AppConstants.pageSize,
  }) async {
    // Simulate network latency so buffering/loading states are exercised.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.generate(pageSize, (i) {
      final base = mockVideos[(page * pageSize + i) % mockVideos.length];
      return base.copyWith(id: 'p${page}_${i}_${base.id}');
    });
  }
}
