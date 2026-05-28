import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/video_model.dart';

/// Bottom-left overlay: username, caption, and the music row.
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
