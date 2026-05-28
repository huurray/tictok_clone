import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/video_model.dart';
import 'feed_provider.dart';

/// Owns a sliding-window pool of [VideoPlayerController]s around the current
/// page. Only `current ± AppConstants.preloadWindow` controllers are kept
/// alive; everything else is paused, disposed, and dropped to free the limited
/// native player resources.
///
/// Notifies listeners whenever the set of available controllers changes so the
/// feed widgets can rebind. Per-frame values (buffering/position) are observed
/// directly on each controller (which is itself a `ValueListenable`).
class VideoManager extends ChangeNotifier {
  VideoManager(this._ref);

  final Ref _ref;

  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _errored = {};

  int _currentIndex = 0;
  bool _userPaused = false; // user tapped to pause the current video
  bool _appPaused = false; // app went to background

  int get currentIndex => _currentIndex;

  VideoPlayerController? controllerAt(int index) => _controllers[index];

  bool isErrored(int index) => _errored.contains(index);

  List<VideoModel> get _videos =>
      _ref.read(feedProvider).value ?? const [];

  // ---- Public API ---------------------------------------------------------

  /// Make [index] the active page: pause others, free out-of-window
  /// controllers, ensure the window is initialized, and play the active one.
  Future<void> setActive(int index) async {
    _currentIndex = index;
    _userPaused = false;
    if (_videos.isEmpty) return;
    _pauseAllExcept(index);
    _disposeOutsideWindow();
    await _ensure(index); // current first — plays inside if still current
    for (final i in _windowIndices(index)) {
      if (i != index) unawaited(_ensure(i)); // preload neighbors (no await)
    }
  }

  /// Toggle play/pause on the current video (single-tap gesture).
  void togglePlayPause() {
    final controller = _controllers[_currentIndex];
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
      _userPaused = true;
    } else {
      controller.play();
      _userPaused = false;
    }
    notifyListeners();
  }

  void onAppPaused() {
    _appPaused = true;
    _controllers[_currentIndex]?.pause();
    notifyListeners();
  }

  void onAppResumed() {
    _appPaused = false;
    if (!_userPaused) _controllers[_currentIndex]?.play();
    notifyListeners();
  }

  /// Pause everything (e.g. when the feed screen is left).
  void pauseAll() {
    for (final c in _controllers.values) {
      if (c.value.isInitialized) c.pause();
    }
  }

  /// Retry a controller that previously failed to initialize.
  void retry(int index) {
    _errored.remove(index);
    unawaited(_ensure(index));
  }

  // ---- Internals ----------------------------------------------------------

  Iterable<int> _windowIndices(int index) sync* {
    final last = _videos.length - 1;
    final start = (index - AppConstants.preloadWindow).clamp(0, last);
    final end = (index + AppConstants.preloadWindow).clamp(0, last);
    for (var i = start; i <= end; i++) {
      yield i;
    }
  }

  bool _inWindow(int index) =>
      (index - _currentIndex).abs() <= AppConstants.preloadWindow &&
      index >= 0 &&
      index < _videos.length;

  Future<void> _ensure(int index) async {
    final videos = _videos;
    if (index < 0 || index >= videos.length) return;
    if (_controllers.containsKey(index) || _errored.contains(index)) return;

    final controller =
        VideoPlayerController.networkUrl(Uri.parse(videos[index].videoUrl));
    _controllers[index] = controller; // register early so disposal can find it

    try {
      await controller.initialize();
      // It may have scrolled out of the window while initializing.
      if (!_inWindow(index)) {
        _controllers.remove(index);
        await controller.dispose();
        notifyListeners();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(1.0);
      // Race guard: only play if this is still the active page.
      if (index == _currentIndex && !_userPaused && !_appPaused) {
        await controller.play();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('VideoManager: failed to init index $index: $e');
      _errored.add(index);
      _controllers.remove(index);
      await controller.dispose();
      notifyListeners();
    }
  }

  void _pauseAllExcept(int index) {
    _controllers.forEach((i, c) {
      if (i != index && c.value.isInitialized && c.value.isPlaying) c.pause();
    });
  }

  void _disposeOutsideWindow() {
    // Dispose initialized controllers outside the window now; controllers still
    // initializing are cleaned up by the post-init window check in [_ensure].
    final toRemove = _controllers.keys
        .where((i) => !_inWindow(i) && _controllers[i]!.value.isInitialized)
        .toList();
    for (final i in toRemove) {
      final c = _controllers.remove(i)!;
      c.dispose();
    }
    if (toRemove.isNotEmpty) notifyListeners();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}

final videoManagerProvider = Provider<VideoManager>((ref) {
  final manager = VideoManager(ref);
  ref.onDispose(manager.dispose);
  return manager;
});
