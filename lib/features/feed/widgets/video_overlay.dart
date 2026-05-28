import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/video_model.dart';
import '../providers/feed_provider.dart';
import 'bottom_info.dart';
import 'side_action_bar.dart';

/// The non-video layer: bottom gradient scrim, bottom-left info, right actions.
/// The scrim and info are wrapped in [IgnorePointer] so taps fall through to
/// the play/pause + double-tap gesture layer below; only the action bar is
/// interactive.
class VideoOverlay extends ConsumerWidget {
  final VideoModel video;
  final int index;

  const VideoOverlay({super.key, required this.video, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: const IgnorePointer(
            child: SizedBox(
              height: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: IgnorePointer(child: BottomInfo(video: video))),
                    const SizedBox(width: 8),
                    SideActionBar(
                      video: video,
                      onLikeTap: () =>
                          ref.read(feedProvider.notifier).toggleLike(index),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
