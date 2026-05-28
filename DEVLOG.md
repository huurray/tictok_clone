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
