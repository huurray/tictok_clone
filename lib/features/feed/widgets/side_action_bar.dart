import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/core/utils/number_format.dart';
import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/features/feed/widgets/like_button.dart';

/// 우측 세로 액션 컬럼: 아바타, 좋아요, 댓글, 공유, 음악 디스크.
class SideActionBar extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onLikeTap;

  const SideActionBar({
    super.key,
    required this.video,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Avatar(url: video.profileImageUrl),
        const SizedBox(height: AppGaps.actionItemGap),
        LikeButton(
          isLiked: video.isLiked,
          likeCount: video.likeCount,
          onTap: onLikeTap,
        ),
        const SizedBox(height: AppGaps.actionItemGap),
        _ActionItem(icon: Icons.mode_comment, count: video.commentCount),
        const SizedBox(height: AppGaps.actionItemGap),
        _ActionItem(icon: Icons.share, count: video.shareCount),
        const SizedBox(height: AppGaps.actionItemGap),
        _MusicDisc(url: video.profileImageUrl),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final int count;

  const _ActionItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppGaps.actionIconSize,
          color: Colors.white,
          shadows: kOverlayTextShadows,
        ),
        const SizedBox(height: 4),
        Text(formatCount(count), style: AppTextStyles.actionCount),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;

  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppGaps.avatarSize,
      height: AppGaps.avatarSize + 10,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: AppGaps.avatarSize,
            height: AppGaps.avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              color: AppColors.surface,
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(color: AppColors.surface),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.brandRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// 가운데에 앨범(아바타) 아트가 들어간, 회전하는 LP 스타일 디스크.
class _MusicDisc extends StatefulWidget {
  final String url;

  const _MusicDisc({required this.url});

  @override
  State<_MusicDisc> createState() => _MusicDiscState();
}

class _MusicDiscState extends State<_MusicDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: AppGaps.musicDiscSize,
        height: AppGaps.musicDiscSize,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          border: Border.all(color: AppColors.divider, width: 2),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ColoredBox(color: AppColors.surface),
            errorWidget: (_, _, _) => const ColoredBox(color: AppColors.surface),
          ),
        ),
      ),
    );
  }
}
