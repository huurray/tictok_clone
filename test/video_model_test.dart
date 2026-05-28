import 'package:flutter_test/flutter_test.dart';
import 'package:tiktok/data/models/video_model.dart';

VideoModel _make({int likeCount = 10, bool isLiked = false}) => VideoModel(
      id: '1',
      videoUrl: 'u',
      thumbnailUrl: 't',
      username: '@u',
      caption: 'c',
      musicTitle: 'm',
      profileImageUrl: 'a',
      likeCount: likeCount,
      commentCount: 0,
      bookmarkCount: 0,
      shareCount: 0,
      isLiked: isLiked,
    );

void main() {
  group('VideoModel.toggleLike', () {
    test('likes an unliked video and increments the count', () {
      final v = _make(likeCount: 10, isLiked: false).toggleLike();
      expect(v.isLiked, true);
      expect(v.likeCount, 11);
    });

    test('unlikes a liked video and decrements the count', () {
      final v = _make(likeCount: 10, isLiked: true).toggleLike();
      expect(v.isLiked, false);
      expect(v.likeCount, 9);
    });
  });

  group('VideoModel.liked (double-tap)', () {
    test('likes an unliked video', () {
      final v = _make(likeCount: 5, isLiked: false).liked();
      expect(v.isLiked, true);
      expect(v.likeCount, 6);
    });

    test('is idempotent on an already-liked video', () {
      final v = _make(likeCount: 5, isLiked: true).liked();
      expect(v.isLiked, true);
      expect(v.likeCount, 5);
    });
  });
}
