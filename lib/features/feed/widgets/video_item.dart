import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/features/feed/providers/feed_provider.dart';
import 'package:tiktok/features/feed/providers/video_manager.dart';
import 'package:tiktok/features/feed/widgets/double_tap_like.dart';
import 'package:tiktok/features/feed/widgets/video_overlay.dart';
import 'package:tiktok/features/feed/widgets/video_player_view.dart';

/// 전체 화면 피드 한 페이지: 영상 + 탭(일시정지)/더블탭(좋아요) 제스처 +
/// 오버레이 UI + 잠깐 나타나는 더블탭 하트.
class VideoItem extends ConsumerStatefulWidget {
  final int index;
  final VideoModel video;

  const VideoItem({super.key, required this.index, required this.video});

  @override
  ConsumerState<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends ConsumerState<VideoItem> {
  Offset? _heartPosition;
  Offset _pendingPosition = Offset.zero;
  int _heartKey = 0;

  void _onTap() => ref.read(videoManagerProvider).togglePlayPause();

  void _onDoubleTapDown(TapDownDetails details) {
    _pendingPosition = details.localPosition;
  }

  void _onDoubleTap() {
    ref.read(feedProvider.notifier).like(widget.index);
    setState(() {
      _heartPosition = _pendingPosition;
      _heartKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayerView(index: widget.index),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap: _onDoubleTap,
          ),
        ),
        VideoOverlay(video: widget.video, index: widget.index),
        if (_heartPosition != null)
          Positioned(
            left: _heartPosition!.dx - 55,
            top: _heartPosition!.dy - 55,
            child: IgnorePointer(
              child: DoubleTapHeart(
                key: ValueKey(_heartKey),
                onCompleted: () {
                  if (mounted) setState(() => _heartPosition = null);
                },
              ),
            ),
          ),
      ],
    );
  }
}
