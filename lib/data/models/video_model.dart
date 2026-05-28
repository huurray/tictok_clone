import 'package:flutter/foundation.dart';

/// A single feed item. Immutable; like state is updated via [copyWith].
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

  /// Returns a copy with [isLiked] toggled and [likeCount] adjusted accordingly.
  VideoModel toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    );
  }

  /// Returns a copy liked (idempotent — used by double-tap, which never unlikes).
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
