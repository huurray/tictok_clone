import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/features/feed/providers/video_manager.dart';
import 'package:tiktok/l10n/gen/app_localizations.dart';

/// [VideoManager]에서 [index]의 컨트롤러를 가져와 화면을 가득 채워 렌더한다.
/// 컨트롤러 init 전(캐시 다운로드 중)에는 [thumbnailUrl] 포스터 위에 스피너,
/// 활성 영상이 일시정지면 재생 아이콘, 로드 실패 시 재시도 UI를 보여준다.
class VideoPlayerView extends ConsumerWidget {
  final int index;
  final String thumbnailUrl;

  const VideoPlayerView({
    super.key,
    required this.index,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(videoManagerProvider);
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        if (manager.isErrored(index)) {
          return _ErrorRetry(onRetry: () => manager.retry(index));
        }
        final controller = manager.controllerAt(index);
        if (controller == null || !controller.value.isInitialized) {
          return _Poster(thumbnailUrl: thumbnailUrl);
        }
        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final showPlayIcon =
                manager.currentIndex == index &&
                value.isInitialized &&
                !value.isPlaying &&
                !value.isBuffering;
            return ColoredBox(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: value.size.width <= 0 ? 16 : value.size.width,
                      height: value.size.height <= 0 ? 9 : value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                  if (value.isBuffering)
                    const SafeArea(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (showPlayIcon)
                    const SafeArea(
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 84,
                          color: Colors.white70,
                          shadows: kOverlayTextShadows,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// 컨트롤러 init 전 보여줄 포스터(정지컷) + 스피너. 다운로드 지연을 시각적으로 가린다.
class _Poster extends StatelessWidget {
  final String thumbnailUrl;

  const _Poster({required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, _) => const ColoredBox(color: Colors.black),
          errorWidget: (_, _, _) => const ColoredBox(color: Colors.black),
        ),
        const SafeArea(child: Center(child: CircularProgressIndicator())),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white70, size: 48),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).videoLoadError,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
