# DEVLOG — TikTok Clone

개발 중 내린 의미 있는 의사결정과 트레이드오프 기록. 과제의 "AI 사용 내역·대화 기록" 및 Q3(가장 어려웠던 문제) 근거 자료.
형식: `맥락 → 고려한 대안 → 결정 → 이유 → AI 활용`. 협업 도구: **Claude Code (Opus 4.7)** — 설계·구현 전반을 페어로 진행.

---

## 2026-05-28 — 기술 스택 결정

- **맥락:** `flutter create` 백지 스캐폴드에서 시작. 과제 요구(세로 피드/자동재생/오버레이) + 전체 가산점(좋아요·더블탭·무한스크롤·상태관리·확장 구조) 목표.
- **대안:** 상태관리 Riverpod vs Bloc vs Provider / 비디오 video_player vs better_player / 데모 iOS 시뮬레이터 vs 웹 vs 실기기.
- **결정:** Riverpod + video_player(공식) + iOS 시뮬레이터(iPhone 16 Pro).
- **이유:** Riverpod은 테스트·확장 용이하고 컨트롤러 생명주기 오케스트레이션에 적합. video_player는 공식·안정적이며 과제 권장. 시뮬레이터는 데모 영상이 실제 폰처럼 보임.
- **AI 활용:** 옵션별 트레이드오프 정리 후 사용자가 선택.

## 2026-05-28 — Video Controller 생명주기 전략 (핵심)

- **맥락:** 각 `VideoPlayerController`는 네이티브 플레이어 리소스를 점유 → 영상마다 1개씩 만들면 메모리 고갈/크래시.
- **대안:** (a) 전부 생성 (b) 현재 1개만 생성 후 매번 init (c) 현재 주변만 유지하는 슬라이딩 윈도우 풀.
- **결정:** (c) **슬라이딩 윈도우 풀(current ± 1)** — 윈도우 밖은 즉시 dispose, 이웃은 미리 init해 스와이프 시 즉시 재생.
- **이유:** (a)는 리소스 폭발, (b)는 스와이프마다 버퍼링으로 UX 저하. (c)가 리소스/체감속도 균형.
- **미해결 → 구현 시 처리:** 초기화가 async라 빠른 스와이프 시 레이스 컨디션 우려 → `play()` 직전 currentIndex 재검증으로 방지 예정.
- **AI 활용:** 풀 설계와 레이스 처리 방식을 Claude Code와 함께 설계.

## 2026-05-28 — 문서화 산출물 도입

- **결정:** `DEVLOG.md`(의사결정 로그)·`DESIGN.md`(디자인 시스템)·프로젝트 `CLAUDE.md`(코드베이스 가이드)를 별도 산출물로 유지.
- **이유:** 과제가 AI 대화/의사결정 기록과 구조 설명을 요구. 디자인 토큰을 한 곳에 모아 UI 일관성 확보. README가 DEVLOG와 Claude Code 세션을 함께 참조.

## 2026-05-28 — 공개 영상 소스 교체 (실데이터 이슈)

- **맥락:** 처음엔 흔히 쓰이는 Google `gtv-videos-bucket` 샘플 MP4를 mock 데이터로 넣었다.
- **문제:** `curl`로 검증하니 모든 URL이 `403 AccessDenied`. 해당 버킷이 더 이상 익명 접근을 허용하지 않게 바뀌어 있었다(HEAD·GET 모두 실패).
- **해결:** 후보 호스트를 일괄 probe해 안정적으로 살아있는 곳만 채택 — `flutter.github.io`(butterfly/bee), `w3schools.com`, `test-videos.co.uk`, `media.w3.org`. 각 URL의 HTTP 상태·content-type·용량까지 확인하고, 64MB짜리(Elephants Dream)는 버퍼링이 느려 제외, 시뮬레이터 호환을 위해 H.264만 사용.
- **교훈:** "유명한" 공개 URL도 시간이 지나면 죽는다. mock이라도 빌드 시점에 실제로 검증해야 데모가 깨지지 않는다.
- **AI 활용:** Claude Code가 후보 URL을 병렬 probe하고 상태/용량 기준으로 선별.

## 2026-05-28 — 시뮬레이터 검증 & Riverpod 3.x API

- **검증:** iPhone 16 Pro 시뮬레이터 빌드·실행 성공. 현재 영상 자동재생(프레임 진행 확인), 초기 페이지(index 0) 일관, 오버레이(우측 액션바·하단 정보·음악 디스크) 정상 렌더, `flutter analyze` 0 경고, 단위 테스트 13개 통과.
- **API 메모:** 설치된 Riverpod이 3.x(flutter_riverpod 3.3.1)라 `AsyncValue.valueOrNull`이 없어졌고 nullable 접근자는 `.value`였다. 패키지 소스를 직접 확인해 `.value`로 교정.

## 2026-05-28 — import 컨벤션: 절대경로(`package:`) 채택

- **결정:** `lib/` 내부 모듈 import를 상대경로(`../../../`)에서 `package:tiktok/...` 절대경로로 통일.
- **이유:** 깊은 상대경로는 가독성이 떨어지고 파일을 옮기면 깨지기 쉽다. 절대경로는 위치에 무관해 리팩터링·검색이 수월하고, test 코드가 이미 `package:tiktok/...`를 써서 컨벤션이 일관된다.
- **범위:** lib 14개 파일 일괄 변환(상대 import 0개). flutter_lints 기본 셋엔 강제 룰이 없어 경고는 없지만 팀 컨벤션으로 고정. analyze 0 경고 / 테스트 13개 통과로 무결성 확인.

## 2026-05-28 — 버그: 스와이프 후 정지 상태로 시작 (autoplay 누락)
- **증상:** 첫 영상(index 0)은 자동재생되는데, 스와이프로 다음 영상에 도착하면 ▶ 정지 상태로 시작.
- **원인:** 재생(`play()`) 로직이 `_ensure()` 안에만 있었다. 이웃 컨트롤러는 직전 단계에서 이미 `_ensure`로 프리로드돼 있어, `setActive`의 `await _ensure(index)`가 "이미 존재" 분기로 즉시 return → `play()`를 호출하지 않았다. 매번 새로 생성되는 첫 영상만 우연히 재생됐던 것.
- **해결:** 재생 책임을 `setActive`로 분리한 `_playActive(index)` 도입 — 새로 만들었든 프리로드돼 있었든 활성 컨트롤러를 항상 재생한다. 레이스 가드(`index == currentIndex`)는 유지하고, `_ensure`도 늦은 초기화/retry 대비로 `_playActive`를 호출.
- **교훈:** "준비(ensure)"와 "재생(orchestrate)" 책임을 한 메서드에 섞으면 캐시 히트(이미 초기화됨) 경로에서 부수효과가 누락된다. 단일 책임으로 분리.

## 2026-05-28 — 바텀 탭바(go_router) + 다국어(한/영)
- **맥락:** 홈/설정 2탭 구조와 설정에서 언어(한국어/English) 전환 기능 추가.
- **결정:** 라우팅은 go_router `StatefulShellRoute.indexedStack`(탭별 상태 보존), i18n은 공식 `flutter_localizations + intl + gen-l10n`(ARB), 선택 언어는 `shared_preferences`로 영속화하고 Riverpod `localeProvider`로 런타임 전환.
- **대안:** easy_localization(JSON, 간단)도 검토했으나 공식 gen-l10n이 타입세이프·표준이라 채택. 라우팅도 셸 라우트로 탭 상태 보존이 깔끔한 go_router 선택.
- **부수 이슈(중요):** `IndexedStack`은 탭 전환 시 피드를 dispose하지 않아 설정 탭에서도 영상이 백그라운드 재생됨 → `VideoManager`에 `_feedVisible` 플래그와 `setFeedVisible()`를 추가해 홈을 벗어나면 일시정지, 복귀 시 재생. `_playActive` 게이트에 `_feedVisible` 포함.
- **검증:** 시뮬레이터에서 바텀탭(홈/설정) 렌더·라벨 한글화, 설정 화면 언어 선택 UI(선택 하이라이트/체크) 확인. analyze 0 / 테스트 13 통과.

## 2026-05-28 — i18n 라이브러리 재검토: easy_localization vs 공식 gen-l10n
- **맥락:** 다국어 구현 후 easy_localization이 더 간단해 보여 다시 비교 검토.
- **비교:**
  - **easy_localization** — JSON 기반, 코드젠 불필요, `'key'.tr()`로 호출, locale 자동 영속화/전환 내장. 단점: 문자열 키라 **타입 안전 X**(오타가 런타임에야 드러남), 서드파티 의존.
  - **공식 gen-l10n(현재)** — ARB + 코드 생성, `AppLocalizations.of(context).key`로 **컴파일 타임 타입 체크 + 자동완성**, Flutter 공식·추가 런타임 의존성 없음. 단점: 설정이 다소 많고 저장/전환은 직접 구현(shared_preferences + Riverpod).
- **결정:** **공식 gen-l10n 유지.**
- **이유:** 이미 타입 세이프 + 영속화 + Riverpod 전환까지 안정적으로 동작 중. 과제 평가(구조·품질) 관점에서 "오타를 컴파일 단계에서 잡는" 타입 안전이 분명한 이점이고 공식 스택이 더 설득력 있음. easy_localization의 간결함은 매력적이나 지금 바꾸는 실익(타입 안전 포기 + 마이그레이션 비용)이 작다고 판단.
- **용어 메모:** i18n=internationalization(다국어 지원 *인프라*), l10n=localization(언어별 *번역/적용*). 숫자는 첫·끝 사이 글자 수 — i+18+n, l+10+n (그래서 `i10n`은 틀린 표기).

## 2026-05-28 — VideoModel을 freezed + json_serializable로 전환 (모델 계층 한정)
- **맥락:** mock 데이터를 코드 하드코딩에서 `assets/mock/videos.json`으로 분리해 `rootBundle`로 읽도록 변경. 모델에 `fromJson`이 필요해지고, 손으로 쓰던 `copyWith`/`==`/`hashCode` 보일러플레이트가 늘어남.
- **대안:** (a) 수기 보일러플레이트 유지 (b) 모델만 freezed+json_serializable 코드젠 (c) provider까지 riverpod_generator 전면 코드젠.
- **결정:** **(b) 모델 계층만** freezed + json_serializable 도입. `fromJson`/`copyWith`/동등성 생성, 도메인 메서드(`toggleLike`/`liked`)는 `const VideoModel._()` private 생성자 + 본문 메서드로 유지. provider는 plain Notifier 유지(riverpod_generator 미도입).
- **이유:** 데이터 모델은 필드가 많고 직렬화·동등성·copyWith가 반복돼 코드젠 이득이 크다. 반면 provider는 로직이 가볍고 코드젠을 넣으면 build_runner 의존성·생성 파일만 늘어 가독성이 떨어진다. **"코드젠은 보일러플레이트가 실제로 큰 데이터 모델에만 쓴다"**는 원칙에 따라 범위를 모델로 한정.
- **데이터/리포지토리:** mixkit 공개 영상 10개로 교체(전부 reachable 검증). 필드 추가(`thumbnailUrl`, `bookmarkCount`), `avatarUrl`→`profileImageUrl`. `VideoRepository`는 JSON 풀을 한 번 로드·메모이즈 후 순환시켜 무한 스크롤을 시뮬레이션.
- **검증:** build_runner 생성 성공, analyze 0 / 테스트 13 통과, 시뮬레이터에서 JSON 기반 첫 영상(golden_hour) 재생 확인.

## 2026-05-28 — 영상 디스크 캐시 (flutter_cache_manager)
- **맥락:** 윈도우를 오가며 같은 영상을 다시 볼 때 매번 네트워크로 재다운로드하는 비효율.
- **대안:** (a) 캐시 없음(현행) (b) flutter_cache_manager 디스크 캐시 + `VideoPlayerController.file` (c) 커스텀 캐시 + LRU 상한/추상화 레이어.
- **결정:** (b). `_ensure`에서 `DefaultCacheManager().getSingleFile(url)`로 로컬 파일을 얻어 `VideoPlayerController.file`로 init. `getSingleFile`/`initialize` await 도중 윈도우 이탈 대비해 기존 `_inWindow` 재검증 가드 유지. 다운로드 단계는 컨트롤러 등록 전이라 중복 `_ensure`를 막는 `_pending` 가드 추가.
- **이유:** 재방문 시 디스크에서 즉시 재생 + 트래픽 절감. (c)의 LRU/추상화는 컨트롤러를 이미 ±1 윈도우로 한정하므로 과함 — 과제 범위 대비 복잡도만 키운다. 캐시 만료/용량은 flutter_cache_manager 기본 정책에 위임.
- **검증:** 시뮬레이터 `Library/Caches/libCachedImageData`에 mp4 캐시 적재 확인(현재 윈도우 영상 2개, ~16MB), 재생 정상. analyze 0 / 테스트 13 통과.

## 2026-05-28 — 미사용 필드 살리기: thumbnail 포스터 + 북마크 토글
- **맥락:** JSON 스키마의 `thumbnailUrl`·`bookmarkCount`가 렌더/기능 없이 죽은 데이터였음("안 쓰는 필드 왜 있냐" 질문 트랩).
- **대안:** (a) 두 필드 제거(YAGNI) (b) thumbnailUrl=로딩 포스터 + bookmarkCount=북마크 토글로 살림 (c) 현행 유지(스키마 현실성으로 방어).
- **결정:** (b). thumbnailUrl은 컨트롤러 init 전 `BoxFit.cover` 포스터로(스피너 위 정지컷) 깔아 캐시 다운로드 지연을 시각적으로 가림. bookmarkCount는 사이드바에 북마크(저장) 토글 추가 — like 패턴 재사용(`BookmarkButton`, 활성색 amber). 모델에 `isBookmarked`(@Default false) + `toggleBookmark` 추가.
- **이유:** thumbnailUrl 포스터는 거의 공짜로 "죽은 필드 살리기 + 첫 시청 지연 완화"를 동시에 해결(디스크 캐시의 유일한 약점인 첫 다운로드 지연을 보완). 북마크는 TikTok 실제 기능이라 authentic하고 사이드바 완성도↑. 둘 다 살리는 쪽이 제거보다 데모/완성도에 유리.
- **검증:** 시뮬레이터에서 북마크 아이콘+카운트(678) 렌더, 포스터 동작, analyze 0 / 테스트 15(북마크 2개 추가) 통과.

## 2026-05-28 — 폴리시: 토글 버튼 DRY + 빠른 스와이프 가드 + 테스트 파리티
- **토글 버튼 통합:** LikeButton·BookmarkButton이 토글+스케일 팝 로직이 거의 동일 → `ToggleActionButton`(activeIcon/inactiveIcon/activeColor) 하나로 합침. 좋아요=하트(brandRed), 북마크=북마크(amber) 주입. 중복 제거.
- **빠른 스와이프 가드:** `setActive`에서 `await _ensure` 직후 그 사이 더 새로운 스와이프가 오면(`_currentIndex != index`) 중단 → stale 이웃 프리로드(불필요한 부분 다운로드) 방지. (누수는 기존 `_inWindow` 가드로 이미 없었음 — 이건 효율 개선.)
- **테스트:** feed_provider에 `toggleBookmark` 테스트 추가(`toggleLike`와 파리티). 총 16개.

## 2026-05-28 — 버그: 시작 시 간헐적 영상 정지 (transient lifecycle)
- **증상:** 콜드 스타트 일부에서 첫 영상이 재생되지 않고 ▶ 정지 상태로 시작(간헐적, 재현 어려움 — 초기 스샷에서도 한 번 목격).
- **원인:** iOS 앱 시작은 inactive→active를 거치는데, lifecycle 핸들러가 `resumed`가 아니면 전부 `onAppPaused`로 처리하고 있었음. 시작 중 `inactive`가 `_ensure`의 비동기(getSingleFile/initialize) 도중 끼어들면 `_appPaused=true`가 되고, 그 상태로 `_playActive`가 호출돼 재생이 막힘. 타이밍 의존이라 간헐적.
- **해결:** `inactive`/`detached`(일시적·전환 상태)는 무시하고, 실제 백그라운드(`paused`/`hidden`)에서만 `onAppPaused`. 제어센터·앱 전환 미리보기 등에도 불필요하게 멈추지 않아 동작이 더 정확해짐.
- **검증:** 3회 연속 콜드 스타트 모두 첫 영상 자동재생 확인(이전엔 간헐적 정지).
