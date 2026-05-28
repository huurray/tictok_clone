import 'package:flutter/material.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/data/models/video_model.dart';

/// 좌하단 오버레이: username, caption, 음악 행.
class BottomInfo extends StatelessWidget {
  final VideoModel video;

  const BottomInfo({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(video.username, style: AppTextStyles.username),
        const SizedBox(height: 8),
        Text(
          video.caption,
          style: AppTextStyles.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.music_note,
              size: 16,
              color: Colors.white,
              shadows: kOverlayTextShadows,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                video.musicTitle,
                style: AppTextStyles.musicTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
