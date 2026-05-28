import 'package:flutter/material.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/core/utils/number_format.dart';

/// 북마크(저장) 아이콘 + 카운트. 저장 상태로 바뀔 때 스케일 바운스로 팝 한다.
/// LikeButton과 동일한 토글 패턴.
class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final int bookmarkCount;
  final VoidCallback onTap;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.bookmarkCount,
    required this.onTap,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
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
  void didUpdateWidget(covariant BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isBookmarked && widget.isBookmarked) {
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
              widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: AppGaps.actionIconSize,
              color: widget.isBookmarked ? AppColors.bookmark : Colors.white,
              shadows: kOverlayTextShadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(formatCount(widget.bookmarkCount), style: AppTextStyles.actionCount),
        ],
      ),
    );
  }
}
