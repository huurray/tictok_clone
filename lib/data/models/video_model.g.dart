// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => _VideoModel(
  id: json['id'] as String,
  videoUrl: json['videoUrl'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String,
  username: json['username'] as String,
  caption: json['caption'] as String,
  musicTitle: json['musicTitle'] as String,
  profileImageUrl: json['profileImageUrl'] as String,
  likeCount: (json['likeCount'] as num).toInt(),
  commentCount: (json['commentCount'] as num).toInt(),
  bookmarkCount: (json['bookmarkCount'] as num).toInt(),
  shareCount: (json['shareCount'] as num).toInt(),
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$VideoModelToJson(_VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'username': instance.username,
      'caption': instance.caption,
      'musicTitle': instance.musicTitle,
      'profileImageUrl': instance.profileImageUrl,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'bookmarkCount': instance.bookmarkCount,
      'shareCount': instance.shareCount,
      'isLiked': instance.isLiked,
    };
