import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/video_manager.dart';

/// Renders the controller for [index] from the [VideoManager], covering the
/// screen. Shows a spinner while uninitialized/buffering, a play glyph when the
/// active video is paused, and a retry affordance on load failure.
class VideoPlayerView extends ConsumerWidget {
  final int index;

  const VideoPlayerView({super.key, required this.index});

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
          return const _Loading();
        }
        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final showPlayIcon = manager.currentIndex == index &&
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
                    const Center(child: CircularProgressIndicator()),
                  if (showPlayIcon)
                    const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 84,
                        color: Colors.white70,
                        shadows: kOverlayTextShadows,
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

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: CircularProgressIndicator()),
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
            const Text(
              "Couldn't load video",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
