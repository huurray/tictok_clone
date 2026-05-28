import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/video_model.dart';
import '../providers/feed_provider.dart';
import '../providers/video_manager.dart';
import 'double_tap_like.dart';
import 'video_overlay.dart';
import 'video_player_view.dart';

/// One full-screen feed page: video + tap-to-pause/double-tap-like gestures +
/// overlay UI + the transient double-tap heart.
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
