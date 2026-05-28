# TikTok Clone (Flutter)

슈퍼센트 **AI 네이티브 직무** 과제 — Flutter로 구현한 TikTok 스타일 숏폼 영상 피드 앱.
세로 스크롤 피드, 현재 영상 자동재생 / 화면 밖 자동 일시정지, 오버레이 UI(좋아요·댓글·공유, username·caption)를 갖추고, 가산점 항목(좋아요 토글·더블탭 좋아요·무한 스크롤·상태관리·확장형 구조)을 모두 포함한다.

> **실행 영상:** _(여기에 1~2분 데모 영상 링크 추가)_

---

## 실행 방법

**요구사항**

- Flutter `3.44+` / Dart `3.12+`
- iOS 시뮬레이터(권장: iPhone 16 Pro) 또는 Android 에뮬레이터 / 실기기
- (iOS) Xcode + CocoaPods

**실행**

```bash
flutter pub get

# iOS 시뮬레이터
open -a Simulator
flutter run                      # 여러 기기면 flutter run -d <device-id>
```

**검증**

```bash
flutter analyze                  # 정적 분석 (경고 0)
flutter test                     # 단위 테스트
```

> 영상 데이터는 공개·로열티프리 H.264 MP4 URL을 사용한다. iOS는 `Info.plist`에 ATS 예외가 설정되어 있고, 화면은 세로 모드로 고정된다.

---

## 사용한 패키지

| 패키지                                                                  | 버전  | 용도                                    |
| ----------------------------------------------------------------------- | ----- | --------------------------------------- |
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod)         | ^3.3  | 상태관리 (Notifier / AsyncNotifier, DI) |
| [`video_player`](https://pub.dev/packages/video_player)                 | ^2.11 | 영상 재생 (공식 플러그인)               |
| [`cached_network_image`](https://pub.dev/packages/cached_network_image) | ^3.4  | 아바타/이미지 네트워크 캐싱             |

---

## 프로젝트 구조

feature-first 구조. 횡단 관심사는 `core/`, 데이터 계층은 `data/`, 화면 기능은 `features/<feature>/`로 분리한다.

```
lib/
├─ main.dart                     # ProviderScope + 시스템 UI 스타일
├─ app.dart                      # MaterialApp + 다크 테마
├─ core/
│  ├─ constants/                 # preloadWindow, pageSize 등 튜닝 상수
│  ├─ theme/                     # DESIGN.md 토큰 구현 (색/타이포/스페이싱)
│  └─ utils/                     # number_format (1.2K / 3.4M)
├─ data/
│  ├─ models/                    # VideoModel (+ copyWith / toggleLike / liked)
│  ├─ sources/                   # mock_videos (검증된 공개 MP4 URL)
│  └─ repositories/              # VideoRepository (시뮬레이션 페이지네이션)
└─ features/feed/
   ├─ providers/
   │  ├─ feed_provider.dart       # AsyncNotifier: 목록·무한스크롤·좋아요
   │  └─ video_manager.dart       # ★ 컨트롤러 풀(슬라이딩 윈도우) — 핵심
   ├─ screens/feed_screen.dart    # PageView(세로) + lifecycle + loadMore
   └─ widgets/                    # player / overlay / 액션바 / 하단정보 / 하트
```

문서: [`DESIGN.md`](DESIGN.md)(디자인 시스템) · [`DEVLOG.md`](DEVLOG.md)(의사결정 로그) · [`CLAUDE.md`](CLAUDE.md)(코드베이스 가이드).

---

## 구현 기능 목록

**필수**

- ✅ 세로 스크롤 영상 피드 (`PageView.builder`, `Axis.vertical`)
- ✅ 현재 화면 영상 자동재생 / 화면 밖 영상 자동 일시정지
- ✅ video_player 기반 재생: autoplay · pause/resume(탭) · buffering 처리(스피너)
- ✅ 오버레이 UI: 우측 ❤️ Like · 💬 Comment · ↗ Share, 하단 username · caption

**가산점 (전체 구현)**

- ✅ 좋아요 토글 (+ 스케일 팝 애니메이션)
- ✅ 더블탭 좋아요 (탭 위치 하트 버스트, 좋아요만/취소 없음)
- ✅ 무한 스크롤 (끝 근접 시 다음 페이지 로드)
- ✅ 상태관리 (Riverpod)
- ✅ 확장 가능한 feature-first 구조
- ✅ 단위 테스트 (number_format · 좋아요 로직 · feed provider)

추가 폴리시: 앱 백그라운드/복귀 시 일시정지·재개, 영상 로드 실패 시 재시도 UI, 회전 음악 디스크, 하단 그라데이션 scrim, 세로 고정 + 라이트 상태바.

---

## Q1. 앱 구조 설계

**폴더 구조 (feature-first)**
기능 단위 응집을 우선했다. `core`(테마·상수·유틸), `data`(모델·소스·리포지토리), `features/feed`(프로바이더·화면·위젯)로 나눠, 새 기능은 `features/<new>`만 추가하면 되고 데이터·UI가 섞이지 않는다. 데이터 계층은 순수 Dart라 위젯 없이 테스트할 수 있다.

**상태관리 선택 (Riverpod)**

- 컴파일 타임 안전성과 `ref` 기반 의존성 주입(리포지토리 교체로 테스트 용이 — 실제 `feed_provider_test`에서 fake 리포지토리로 검증).
- 비동기 피드 로딩·페이지네이션을 `AsyncNotifier`의 `AsyncValue`로 자연스럽게 표현(로딩/에러/데이터).
- 네이티브 리소스를 쥔 `VideoManager`는 `Provider` + `ref.onDispose`로 생성·정리해 생명주기를 명확히 한다.

**Video player lifecycle 처리**
`VideoManager`가 **현재 index ± 1**만 컨트롤러를 유지하는 슬라이딩 윈도우 풀을 운영한다. 데이터·오케스트레이션은 Riverpod이, 프레임 단위 값(`isBuffering`/`isPlaying`)은 컨트롤러 자체의 `ValueListenable`을 위젯에서 직접 구독해 불필요한 rebuild를 막는다. 윈도우를 벗어난 컨트롤러는 즉시 `pause + dispose`, 재생은 `play()` 직전 현재 index를 재확인한 뒤 수행한다. 앱이 백그라운드로 가거나(`AppLifecycleListener`) 피드 화면을 벗어나면 재생을 멈춘다.

---

## Q2. 확장성 설계 (실제 TikTok 규모라면)

**Video preload 전략**

- 고정 ±1 윈도우 → 네트워크/스크롤 속도 기반 **적응형 윈도우**.
- 썸네일·첫 프레임 프리페치, 다음 영상 일부 프리버퍼.
- HLS/DASH **ABR**로 대역폭에 따라 해상도 적응, 컨트롤러 풀 **상한 + LRU** 회수.

**네트워크 처리**

- mock → cursor 기반 페이지네이션 API + **CDN**.
- HTTP 캐싱(ETag), **재시도 + 지수 백오프**, 오프라인/디스크 캐시, 동시 요청 제한.

**상태관리 구조**

- 기능별 모듈화, `Repository` 인터페이스화 + DI로 데이터 소스 교체/모킹.
- `riverpod_generator` 코드젠으로 보일러플레이트 축소, 페이지네이션 상태(hasMore/loading/error)를 명시 모델로.

**성능 최적화**

- `const`·`RepaintBoundary`로 rebuild·repaint 격리, 이미지 캐시 용량 제한.
- 살아있는 디코더 수 상한, `ValueListenable` 직접 구독으로 위젯 rebuild 최소화.
- DevTools로 프레임/메모리 프로파일링, 영상 디코더 재사용.

---

## Q3. 가장 어려웠던 문제

**문제 상황 — 컨트롤러 풀의 레이스 컨디션**
`VideoPlayerController.initialize()`는 비동기다. 빠르게 세로 스와이프하면 초기화가 끝나기 전에 현재 index가 바뀌어, **이미 지나간 영상이 뒤늦게 재생**되거나, 초기화 중이던 화면 밖 컨트롤러가 정리되지 않고 **네이티브 리소스가 누수**되는 문제가 있었다.

**시도한 방법**

1. 페이지마다 컨트롤러 1개만 재사용 → 스와이프마다 재버퍼링이 발생해 체감 속도가 나빠졌다.
2. 초기화 콜백에서 무조건 `play()` 호출 → 늦게 끝난 초기화가 엉뚱한(지나간) 영상을 재생했다.

**최종 해결**
슬라이딩 윈도우 풀에 세 가지 가드를 두었다.

- `initialize()` 완료 후 **`index == currentIndex`를 재확인**한 뒤에만 `play()` (오재생 방지).
- 초기화 도중 윈도우를 벗어났으면 완료 직후 **즉시 `dispose`** (리소스 누수 방지).
- `setActive` 진입 시 윈도우 밖의 초기화된 컨트롤러를 **선제적으로 `dispose`**.

이 동작은 [`video_manager.dart`](lib/features/feed/providers/video_manager.dart)에 주석으로, 의사결정 맥락은 [`DEVLOG.md`](DEVLOG.md)에 기록했다.

---

## AI 사용 내역 및 대화 기록

- **AI 사용 여부:** 사용함 — **Claude Code (Opus 4.7)** 를 페어 프로그래밍 에이전트로 사용.
- **AI를 사용한 작업 범위:** 과제 요구사항 분석, 아키텍처·컨트롤러 생명주기 설계, 전체 코드 구현, 단위 테스트 작성, 공개 영상 URL 검증, 문서(README/DESIGN/DEVLOG/CLAUDE) 작성.
- **본인이 직접 작성/결정한 부분:** 핵심 기술 의사결정(상태관리 = Riverpod, 비디오 라이브러리 = video_player, 데모 타깃 = iOS 시뮬레이터, 구현 범위 = 전체 가산점), 코드 리뷰 및 방향 조정, 시뮬레이터 동작 검증, 데모 영상 촬영.
- **가장 어려웠던 문제와 해결:** 위 **Q3** 참고.
- **대화 기록:** 의사결정 로그는 [`DEVLOG.md`](DEVLOG.md)에 정리. 전체 AI 대화 트랜스크립트(Claude Code 세션)는 _(링크/스크린샷 첨부)_.

> 위 "본인이 직접 작성한 부분"은 실제 작업에 맞게 본인이 검토·수정해 주세요.
