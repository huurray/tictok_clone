# CLAUDE.md — tiktok

이 저장소에서 작업하는 Claude Code를 위한 프로젝트 전용 가이드. (사용자 글로벌 `~/CLAUDE.md`와 별개)

## 프로젝트 개요
Flutter로 만든 TikTok 스타일 숏폼 영상 피드 앱. 세로 `PageView` 피드 + `video_player` 기반 자동재생/일시정지 + 오버레이 UI(좋아요/댓글/공유, username/caption). 상태관리는 Riverpod. 슈퍼센트 AI 네이티브 직무 과제.

## 핵심 명령 (iOS 시뮬레이터 기준)
```bash
flutter pub get
flutter analyze                       # 경고 0 유지
flutter test                          # 단위/위젯 테스트
open -a Simulator                     # iPhone 16 Pro 부팅
flutter run -d <ios-sim-id>           # flutter devices 로 id 확인
```

## 아키텍처 (feature-first)
- `lib/core/` — 횡단 관심사: `theme/app_theme.dart`(디자인 토큰), `constants/app_constants.dart`(preloadWindow/pageSize), `utils/number_format.dart`.
- `lib/data/` — `models/`(VideoModel), `sources/`(mock_videos), `repositories/`(VideoRepository: 시뮬레이션 페이지네이션).
- `lib/features/feed/` — `providers/`(feed_provider, video_manager), `screens/`(feed_screen), `widgets/`(player/overlay/제스처 컴포넌트).

## Riverpod 컨벤션
- plain Notifier/AsyncNotifier 패턴 사용 (code-gen/build_runner 미사용).
- 데이터·오케스트레이션은 Riverpod, 영상 프레임 단위 값(`isBuffering` 등)은 `VideoPlayerController`의 `ValueListenable`을 위젯에서 직접 구독.
- 리소스 보유 객체(VideoManager)는 `Provider` + `ref.onDispose`로 정리.

## ⚠️ Video Controller 불변식 (가장 중요 — 깨면 크래시/오재생)
`features/feed/providers/video_manager.dart`:
1. **윈도우 = current ± `AppConstants.preloadWindow`(=1)** 범위의 컨트롤러만 살아있다.
2. 윈도우를 벗어난 컨트롤러는 **즉시 pause + dispose + 맵에서 제거** (네이티브 리소스 누수/고갈 방지).
3. 초기화는 async — `play()` 직전 **`currentIndex == 대상 index` 재검증** (빠른 스와이프 레이스 컨디션 방지).
4. 한 번에 한 컨트롤러만 재생, 나머지는 pause.

## 디자인 / 문서 규칙
- UI 값은 하드코딩 금지 → `DESIGN.md`의 토큰을 구현한 `app_theme.dart`(`AppColors`/`AppTextStyles`/`AppGaps`) 참조.
- 의미 있는 의사결정·트레이드오프는 `DEVLOG.md`에 `맥락→대안→결정→이유` 형식으로 append (과제의 AI 기록/Q3 근거).
