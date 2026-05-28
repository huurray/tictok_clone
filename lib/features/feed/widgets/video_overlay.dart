import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/features/feed/providers/feed_provider.dart';
import 'package:tiktok/features/feed/widgets/bottom_info.dart';
import 'package:tiktok/features/feed/widgets/side_action_bar.dart';

/// 영상이 아닌 레이어: 하단 그라데이션 scrim, 좌하단 정보, 우측 액션.
/// scrim과 정보는 [IgnorePointer]로 감싸 탭이 아래의 재생/일시정지 + 더블탭
/// 제스처 레이어로 통과하게 하고, 액션바만 상호작용한다.
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
