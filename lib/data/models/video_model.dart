import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

/// 피드 한 항목. freezed가 불변성·동등성·copyWith·JSON 직렬화를 생성하고,
/// 좋아요 토글 같은 도메인 메서드는 private 생성자(`VideoModel._`) + 본문 메서드로 유지한다.
@freezed
abstract class VideoModel with _$VideoModel {
  const VideoModel._();

  const factory VideoModel({
    required String id,
    required String videoUrl,
    required String thumbnailUrl,
    required String username,
    required String caption,
    required String musicTitle,
    required String profileImageUrl,
    required int likeCount,
    required int commentCount,
    required int bookmarkCount,
    required int shareCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  /// [isLiked]를 토글하고 [likeCount]를 그에 맞게 조정한 복사본을 반환한다.
  VideoModel toggleLike() => copyWith(
    isLiked: !isLiked,
    likeCount: isLiked ? likeCount - 1 : likeCount + 1,
  );

  /// 좋아요 상태로 만든 복사본을 반환한다(멱등 — 취소 없는 더블탭용).
  VideoModel liked() =>
      isLiked ? this : copyWith(isLiked: true, likeCount: likeCount + 1);

  /// [isBookmarked]를 토글하고 [bookmarkCount]를 그에 맞게 조정한 복사본을 반환한다.
  VideoModel toggleBookmark() => copyWith(
    isBookmarked: !isBookmarked,
    bookmarkCount: isBookmarked ? bookmarkCount - 1 : bookmarkCount + 1,
  );
}
