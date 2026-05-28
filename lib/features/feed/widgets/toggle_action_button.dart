import 'package:flutter/material.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/core/utils/number_format.dart';

/// 토글 액션(좋아요·북마크 등) 공통 버튼: 아이콘 + 카운트.
/// 비활성→활성으로 바뀔 때 스케일 바운스로 팝 한다(직접 탭이든 외부 트리거든 동일).
class ToggleActionButton extends StatefulWidget {
  final bool isActive;
  final int count;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final VoidCallback onTap;

  const ToggleActionButton({
    super.key,
    required this.isActive,
    required this.count,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<ToggleActionButton> createState() => _ToggleActionButtonState();
}

class _ToggleActionButtonState extends State<ToggleActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.35,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.35,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 50,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant ToggleActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
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
              widget.isActive ? widget.activeIcon : widget.inactiveIcon,
              size: AppGaps.actionIconSize,
              color: widget.isActive ? widget.activeColor : Colors.white,
              shadows: kOverlayTextShadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(formatCount(widget.count), style: AppTextStyles.actionCount),
        ],
      ),
    );
  }
}
