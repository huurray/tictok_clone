import 'package:flutter/foundation.dart';

/// 피드 한 항목. 불변이며, 좋아요 상태는 [copyWith]로 갱신한다.
@immutable
class VideoModel {
  final String id;
  final String videoUrl;
  final String username;
  final String caption;
  final String musicTitle;
  final String avatarUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;

  const VideoModel({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.caption,
    required this.musicTitle,
    required this.avatarUrl,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.isLiked = false,
  });

  VideoModel copyWith({
    String? id,
    String? videoUrl,
    String? username,
    String? caption,
    String? musicTitle,
    String? avatarUrl,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
  }) {
    return VideoModel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      musicTitle: musicTitle ?? this.musicTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// [isLiked]를 토글하고 [likeCount]를 그에 맞게 조정한 복사본을 반환한다.
  VideoModel toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    );
  }

  /// 좋아요 상태로 만든 복사본을 반환한다(멱등 — 취소 없는 더블탭용).
  VideoModel liked() {
    if (isLiked) return this;
    return copyWith(isLiked: true, likeCount: likeCount + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModel &&
          other.id == id &&
          other.videoUrl == videoUrl &&
          other.username == username &&
          other.caption == caption &&
          other.musicTitle == musicTitle &&
          other.avatarUrl == avatarUrl &&
          other.likeCount == likeCount &&
          other.commentCount == commentCount &&
          other.shareCount == shareCount &&
          other.isLiked == isLiked;

  @override
  int get hashCode => Object.hash(
        id,
        videoUrl,
        username,
        caption,
        musicTitle,
        avatarUrl,
        likeCount,
        commentCount,
        shareCount,
        isLiked,
      );
}
