# DESIGN.md — TikTok Clone 디자인 시스템

UI 일관성을 위한 단일 디자인 소스. 모든 토큰은 `lib/core/theme/app_theme.dart`(`AppColors`, `AppTextStyles`, `AppGaps`)에 1:1로 구현되어 있으며, 위젯은 하드코딩 값 대신 이 토큰을 참조한다. 공개된 TikTok 디자인 언어 + 공식 브랜드 컬러 기반.

## 1. Colors
| 토큰 | 값 | 용도 |
|---|---|---|
| `background` | `#000000` | 전체 배경 (영상 뒤 검정) |
| `surface` | `#121212` | 스켈레톤/플레이스홀더 |
| `textPrimary` | `#FFFFFF` | 기본 텍스트 |
| `textSecondary` | `white70` | 보조 텍스트/카운트 |
| `brandRed` | `#FE2C55` | 좋아요 활성, 강조 (TikTok red) |
| `brandCyan` | `#25F4EE` | 보조 액센트 |
| `bookmark` | `#FACC15` | 북마크(저장) 활성 (amber) |
| `divider` | `white24` | 구분선 |

- 영상 위 텍스트/아이콘은 가독성을 위해 항상 `shadow: black54`(blur 4, offset 0,1)를 동반.
- 하단 정보 영역 뒤에는 `transparent → black54` 세로 그라데이션 scrim.

## 2. Typography (시스템 폰트: iOS=SF Pro)
| 스타일 | size / weight | 비고 |
|---|---|---|
| `username` | 16 / w700 | `@handle`, 흰색 |
| `caption` | 14 / w400 | 최대 2줄 ellipsis |
| `actionCount` | 13 / w600 | 아이콘 하단 카운트 |
| `musicTitle` | 13 / w400 | 음악 한 줄 (marquee 생략 가능) |

## 3. Spacing (`AppGaps`)
- 화면 가로 패딩: `16`
- 우측 액션바: 우측 패딩 `8`, 아이템 세로 간격 `20`
- 아이콘 크기: 액션(♥/💬/↗) `34`, 아바타 `48`, 음악 디스크 `48`
- 하단 정보: SafeArea 기준 좌하단, 우측은 액션바 폭만큼 여백

## 4. Components
- **SideActionBar** (우측 세로, 하단 정렬): `아바타(+팔로우 + 배지)` → `♥ Like(+count)` → `💬 Comment(+count)` → `🔖 Bookmark(+count)` → `↗ Share(+count)` → `회전 음악 디스크`. 좋아요·북마크는 토글 + 스케일 팝(활성: Like=brandRed, Bookmark=amber).
- **BottomInfo** (좌하단): `@username`(w700) + `caption`(2줄) + `♪ 음악` 한 줄. 뒤에 그라데이션 scrim.
- **LikeButton**: 토글 시 `AnimatedScale`(1.0→1.3→1.0, 200ms). 비활성 흰색, 활성 `brandRed` 채움 하트.
- **DoubleTapHeart**: 탭 좌표에 큰 하트(size ~100, `brandRed`) 버스트 — scale 0→1.2 + fade out, 약 600ms 후 제거. 더블탭은 "좋아요 설정"만(취소 없음).
- **Buffering**: `!isInitialized || isBuffering`일 때 중앙 흰색 `CircularProgressIndicator`.
- **LoadingPoster**: 컨트롤러 init 전(캐시 다운로드 중)에는 `thumbnailUrl` 정지컷을 `BoxFit.cover` 포스터로 깔고 그 위에 스피너 — 첫 시청/다운로드 지연을 시각적으로 가린다.
- **PlayIndicator**: 사용자가 일시정지 시 중앙에 반투명 흰색 `play_arrow`(size ~80).

## 5. Layout 원칙
- 영상: `BoxFit.cover`로 화면 풀블리드(노치/홈 인디케이터 영역까지). `FittedBox` + `SizedBox(video size)`.
- 오버레이 UI: `SafeArea`로 노치/홈 인디케이터 회피.
- 세로 고정(portrait lock, Info.plist).
