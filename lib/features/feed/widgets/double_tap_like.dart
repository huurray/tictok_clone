import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A single heart burst shown at the double-tap location: pops in with an
/// elastic scale, holds, then fades out and calls [onCompleted] so the parent
/// can remove it.
class DoubleTapHeart extends StatefulWidget {
  final VoidCallback onCompleted;

  const DoubleTapHeart({super.key, required this.onCompleted});

  @override
  State<DoubleTapHeart> createState() => _DoubleTapHeartState();
}

class _DoubleTapHeartState extends State<DoubleTapHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
  );

  late final Animation<double> _opacity = Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onCompleted();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Transform.rotate(
          angle: -0.15,
          child: const Icon(
            Icons.favorite,
            color: AppColors.brandRed,
            size: 110,
            shadows: kOverlayTextShadows,
          ),
        ),
      ),
    );
  }
}
