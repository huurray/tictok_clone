import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:tiktok/core/constants/app_constants.dart';
import 'package:tiktok/data/models/video_model.dart';
import 'package:tiktok/features/feed/providers/feed_provider.dart';

/// 현재 페이지 주변의 [VideoPlayerController]를 슬라이딩 윈도우 풀로 관리한다.
/// `현재 ± AppConstants.preloadWindow` 범위의 컨트롤러만 살아있고, 나머지는
/// pause·dispose 후 제거해 한정된 네이티브 플레이어 리소스를 확보한다.
///
/// 사용 가능한 컨트롤러 집합이 바뀌면 리스너에 알려 피드 위젯이 다시 바인딩되게 한다.
/// 프레임 단위 값(버퍼링/재생 위치)은 컨트롤러 자체(`ValueListenable`)를 직접 구독한다.
class VideoManager extends ChangeNotifier {
  VideoManager(this._ref);

  final Ref _ref;

  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _errored = {};
  final Set<int> _pending = {}; // 다운로드/초기화 진행 중 (중복 _ensure 방지)
  final _cacheManager = DefaultCacheManager();

  int _currentIndex = 0;
  bool _userPaused = false; // 사용자가 현재 영상을 탭으로 일시정지함
  bool _appPaused = false; // 앱이 백그라운드로 감
  bool _feedVisible = true; // 피드(홈 탭)가 화면에 보이는지

  int get currentIndex => _currentIndex;

  VideoPlayerController? controllerAt(int index) => _controllers[index];

  bool isErrored(int index) => _errored.contains(index);

  List<VideoModel> get _videos => _ref.read(feedProvider).value ?? const [];

  // ---- 공개 API ---------------------------------------------------------

  /// [index]를 활성 페이지로 만든다: 나머지는 pause, 윈도우 밖 컨트롤러는 해제,
  /// 윈도우를 초기화한 뒤 활성 영상을 재생한다.
  Future<void> setActive(int index) async {
    _currentIndex = index;
    _userPaused = false;
    if (_videos.isEmpty) return;
    _pauseAllExcept(index);
    _disposeOutsideWindow();
    await _ensure(index); // 현재 컨트롤러 준비(이미 있으면 즉시 반환)
    // await 사이 더 새로운 스와이프가 왔으면 중단(stale 이웃 프리로드 방지).
    if (_currentIndex != index) return;
    _playActive(index); // 새로 만들었든 미리 로드돼 있었든 활성 영상을 즉시 재생
    for (final i in _windowIndices(index)) {
      if (i != index) unawaited(_ensure(i)); // 이웃 프리로드 (await 안 함)
    }
  }

  /// 현재 영상의 재생/일시정지 토글 (단일 탭 제스처).
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
    _playActive(_currentIndex);
  }

  /// 홈 탭이 보이는지 설정한다. 다른 탭으로 가면 현재 영상을 멈추고,
  /// 홈으로 돌아오면 다시 재생한다.
  void setFeedVisible(bool visible) {
    if (_feedVisible == visible) return;
    _feedVisible = visible;
    if (visible) {
      _playActive(_currentIndex);
    } else {
      _controllers[_currentIndex]?.pause();
      notifyListeners();
    }
  }

  /// 모든 영상 일시정지 (예: 피드 화면을 벗어날 때).
  void pauseAll() {
    for (final c in _controllers.values) {
      if (c.value.isInitialized) c.pause();
    }
  }

  /// 이전에 초기화에 실패한 컨트롤러를 다시 시도한다.
  void retry(int index) {
    _errored.remove(index);
    unawaited(_ensure(index));
  }

  // ---- 내부 구현 ----------------------------------------------------------

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
    if (_controllers.containsKey(index) ||
        _errored.contains(index) ||
        _pending.contains(index)) {
      return;
    }
    _pending.add(index);

    VideoPlayerController? controller;
    try {
      // 디스크 캐시에서 파일을 얻는다(있으면 즉시, 없으면 받아서 캐시).
      final file = await _cacheManager.getSingleFile(videos[index].videoUrl);
      // 다운로드 도중 윈도우를 벗어났으면 컨트롤러를 만들지 않는다(누수 방지).
      if (!_inWindow(index)) return;

      controller = VideoPlayerController.file(file);
      _controllers[index] = controller; // dispose 로직이 찾을 수 있게 등록
      await controller.initialize();
      // 초기화 도중 윈도우를 벗어났을 수 있다.
      if (!_inWindow(index)) {
        _controllers.remove(index);
        await controller.dispose();
        notifyListeners();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(1.0);
      // 늦게 끝난 초기화(또는 retry)라도 활성 페이지면 바로 재생한다.
      _playActive(index);
      notifyListeners();
    } catch (e) {
      debugPrint('VideoManager: failed to load index $index: $e');
      _errored.add(index);
      if (controller != null) {
        _controllers.remove(index);
        await controller.dispose();
      }
      notifyListeners();
    } finally {
      _pending.remove(index);
    }
  }

  /// 활성 페이지의 컨트롤러를 재생한다(이미 재생 중이면 무시).
  /// 레이스 가드: 호출 시점에도 여전히 활성 페이지일 때만 재생한다.
  void _playActive(int index) {
    if (index != _currentIndex || _userPaused || _appPaused || !_feedVisible) {
      return;
    }
    final controller = _controllers[index];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      controller.play();
      notifyListeners();
    }
  }

  void _pauseAllExcept(int index) {
    _controllers.forEach((i, c) {
      if (i != index && c.value.isInitialized && c.value.isPlaying) c.pause();
    });
  }

  void _disposeOutsideWindow() {
    // 윈도우 밖의 '초기화된' 컨트롤러는 지금 dispose한다. 아직 초기화 중인 것은
    // [_ensure]의 초기화 후 윈도우 검사에서 정리된다.
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
