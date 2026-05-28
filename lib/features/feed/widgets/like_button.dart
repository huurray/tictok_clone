import 'package:flutter/material.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/core/utils/number_format.dart';

/// 하트 아이콘 + 카운트. 좋아요 상태로 바뀔 때 스케일 바운스로 팝 한다 —
/// 직접 탭이든 외부 더블탭 좋아요든 동일하게.
class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onTap;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      weight: 50,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Icon(
              Icons.favorite,
              size: AppGaps.actionIconSize,
              color: widget.isLiked ? AppColors.brandRed : Colors.white,
              shadows: kOverlayTextShadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(formatCount(widget.likeCount), style: AppTextStyles.actionCount),
        ],
      ),
    );
  }
}
