import 'package:tiktok/core/constants/app_constants.dart';
import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/data/sources/mock_videos.dart';

/// [mockVideos] 위에서 페이지네이션 백엔드를 시뮬레이션한다. 풀을 순환시켜
/// 사실상 끝없는 피드를 만들고, 페이지마다 항목에 고유 id를 부여한다.
class VideoRepository {
  const VideoRepository();

  Future<List<VideoModel>> fetchPage(
    int page, {
    int pageSize = AppConstants.pageSize,
  }) async {
    // 버퍼링/로딩 상태를 확인할 수 있도록 네트워크 지연을 시뮬레이션.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.generate(pageSize, (i) {
      final base = mockVideos[(page * pageSize + i) % mockVideos.length];
      return base.copyWith(id: 'p${page}_${i}_${base.id}');
    });
  }
}
