# MIGRATION.md — 이 Flutter 앱을 React Native로 포팅한다면

> TikTok 클론(Flutter)의 아키텍처를 읽고 **React Native로 포팅하는 설계**를 정리한 문서다.
>
> **RN 스택 가정:** Expo + TypeScript / Expo Router(or React Navigation) / TanStack Query + Zustand / `expo-video` / react-native-gesture-handler + Reanimated / `react-native-mmkv` / i18next.

---

## 1. 스택 매핑 한눈에

| Flutter                                      | → React Native                                             | 비고                   |
| -------------------------------------------- | ---------------------------------------------------------- | ---------------------- |
| Riverpod `AsyncNotifier` (피드)              | **TanStack Query `useInfiniteQuery`**                      | 페이지네이션 상태 내장 |
| Riverpod `Notifier` (언어 등 동기)           | **Zustand** (+ `persist`/MMKV)                             |                        |
| Riverpod `Provider` (DI)                     | 모듈 export / 쿼리 fn                                      |                        |
| freezed 불변 모델 + `copyWith`               | TS `type` + 스프레드 `{...}`                               | 코드젠 불필요          |
| `fromJson`/`json_serializable`               | **zod** 스키마(런타임 검증)                                |                        |
| `VideoManager` 컨트롤러 풀                   | **`FlatList` 가상화 + `onViewableItemsChanged`**           | §3-3                   |
| `video_player`                               | **`expo-video`** (`useVideoPlayer`) / `react-native-video` |                        |
| `PageView(vertical)` + `PageController`      | `FlatList`(vertical, `pagingEnabled`) / `FlashList`        |                        |
| `ListenableBuilder`/`ValueListenableBuilder` | store 구독 + `<Video>` 콜백(`onProgress`)                  | §3-3                   |
| `IgnorePointer`                              | **`pointerEvents="none"`**                                 | 1:1                    |
| `ValueKey` 교체로 애니메이션 재시작          | **`key` prop 교체 → 리마운트**                             | 1:1                    |
| `GestureDetector`(tap/doubleTap)             | gesture-handler `Gesture.Tap().numberOfTaps()`             |                        |
| `AppLifecycleListener`                       | `AppState`                                                 |                        |
| `go_router` `StatefulShellRoute`             | Expo Router / React Navigation Tabs                        |                        |
| `shared_preferences`                         | `react-native-mmkv`(동기) / AsyncStorage                   |                        |
| gen-l10n(ARB)                                | i18next / react-intl                                       |                        |

---

## 2. 변하지 않는 것 — 아키텍처와 결정 (가장 중요)

포팅에서 **그대로 살아남는** 것들. 프레임워크가 아니라 원리이기 때문이다:

- **feature-first 구조 + 단방향 의존성** (`features → data → core`) → `src/` 아래 동일하게.
- **불변 상태 + 단방향 데이터 흐름** (copyWith로 새 객체 → 교체) → React/RN의 기본 철학과 동일.
- **슬라이딩 윈도우 결정** ("보이는 것만 재생, 살아있는 디코더 N개로 제한") → RN에서도 그대로 필요(§3-3, §4).
- **관심사 분리** (모델=도메인 / 상태=오케스트레이션 / 위젯=렌더) → 컴포넌트·훅·스토어로 그대로.
- **2단계 구독 원칙** ("고빈도 프레임값은 로컬, 저빈도 오케스트레이션만 전역") → RN에서 재생 진행률을 전역 store에 넣지 않는 것과 동일.

> 즉 이 코드의 가치는 "Flutter 문법"이 아니라 **위 판단들**이고, 그것들은 RN으로 전이된다.

---

## 3. 핵심 코드 포팅 (before → after)

### 3-1. 불변 모델 — `VideoModel` → TS `type`

```ts
// data/models/video.ts
export type Video = {
  id: string;
  videoUrl: string;
  thumbnailUrl: string;
  username: string;
  caption: string;
  musicTitle: string;
  profileImageUrl: string;
  likeCount: number;
  commentCount: number;
  bookmarkCount: number;
  shareCount: number;
  isLiked: boolean;
  isBookmarked: boolean;
};

// copyWith ≈ 스프레드. 도메인 연산은 순수 함수.
export const toggleLike = (v: Video): Video => ({
  ...v,
  isLiked: !v.isLiked,
  likeCount: v.isLiked ? v.likeCount - 1 : v.likeCount + 1,
});

// 더블탭 — 멱등(연타해도 카운트 안 부풂), Flutter의 liked()와 동일 설계
export const liked = (v: Video): Video =>
  v.isLiked ? v : { ...v, isLiked: true, likeCount: v.likeCount + 1 };

// fromJson ≈ zod 스키마로 런타임 검증 (단순 as 단언보다 안전)
import { z } from "zod";
export const VideoSchema = z.object({
  id: z.string(),
  likeCount: z.number() /* ... */,
});
export const parseVideos = (json: unknown): Video[] =>
  VideoSchema.array().parse(json);
```

### 3-2. 피드 상태 + 무한 스크롤 — `AsyncNotifier` → `useInfiniteQuery`

Flutter에서 수동 관리한 `loadMore` + `_nextPage` + `_isLoadingMore`가 **전부 내장으로 흡수**된다:

```ts
// features/feed/useFeed.ts
const PAGE_SIZE = 5;
export const useFeed = () =>
  useInfiniteQuery({
    queryKey: ["feed"],
    queryFn: ({ pageParam }) => fetchPage(pageParam), // ≈ VideoRepository.fetchPage
    initialPageParam: 0,
    getNextPageParam: (_last, pages) => pages.length, // ≈ _nextPage
  });

// 컴포넌트에서:
const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
  isLoading,
  error,
} = useFeed();
const videos = data?.pages.flat() ?? [];
// isLoading/error/data 분기 = Flutter의 feed.when(loading/error/data)
// fetchNextPage = loadMore, isFetchingNextPage = _isLoadingMore 가드
```

> 좋아요는 서버가 없으니 **클라이언트 상태**: 낙관적 `useMutation`으로 쿼리 캐시를 업데이트하거나, Zustand 오버레이(videoId→{isLiked,likeCount})로 둔다.

### 3-3. ★ 비디오 재생 생명주기 — `VideoManager` → `FlatList` viewability (핵심)

Flutter에서 손으로 만든 컨트롤러 풀을, RN은 **FlatList 가상화 + viewability**로 상당 부분 자동화한다. 단 **동시 디코더 상한은 여전히 직접** 둔다(안 그러면 RN도 디코더 고갈):

```tsx
const viewabilityConfig = { itemVisiblePercentThreshold: 80 };

function Feed() {
  const { data, fetchNextPage, hasNextPage } = useFeed();
  const videos = data?.pages.flat() ?? [];
  const [activeIndex, setActiveIndex] = useState(0);

  // ≈ setActive(index): 보이는 항목을 활성으로
  const onViewableItemsChanged = useRef(({ viewableItems }) => {
    const idx = viewableItems[0]?.index;
    if (idx != null) setActiveIndex(idx); // (빠른 스크롤 레이스는 §5)
  }).current;

  return (
    <FlatList
      data={videos}
      pagingEnabled // ≈ 세로 스냅
      keyExtractor={(v) => v.id}
      windowSize={3} // ≈ preloadWindow: 현재±1만 mount
      onViewableItemsChanged={onViewableItemsChanged} // ≈ onPageChanged → setActive
      viewabilityConfig={viewabilityConfig}
      onEndReached={() => hasNextPage && fetchNextPage()} // ≈ loadMore 트리거
      onEndReachedThreshold={0.5}
      renderItem={({ item, index }) => (
        <VideoCell
          video={item}
          isActive={index === activeIndex}
          isNear={Math.abs(index - activeIndex) <= 1} // ≈ 슬라이딩 윈도우 ±1
        />
      )}
    />
  );
}

// 디코더 상한: 윈도우 밖이면 플레이어를 아예 mount하지 않고 썸네일 (= dispose)
function VideoCell({
  video,
  isActive,
  isNear,
}: {
  video: Video;
  isActive: boolean;
  isNear: boolean;
}) {
  return isNear ? (
    <ActivePlayer video={video} isActive={isActive} />
  ) : (
    <Poster uri={video.thumbnailUrl} />
  );
}

function ActivePlayer({
  video,
  isActive,
}: {
  video: Video;
  isActive: boolean;
}) {
  const player = useVideoPlayer(video.videoUrl, (p) => {
    p.loop = true;
  });
  useEffect(() => {
    // ≈ _playActive 게이트
    isActive ? player.play() : player.pause();
  }, [isActive, player]);
  // 프레임값(버퍼링/위치)은 player 콜백으로 로컬 처리 — 전역 store에 안 올림(2단계 구독 원칙)
  return (
    <VideoView
      player={player}
      style={StyleSheet.absoluteFill}
      contentFit="cover"
    />
  );
}
```

**매핑 요약:**

- 윈도우 밖 dispose → `ActivePlayer` **언마운트**(컴포넌트가 사라지며 player 해제). `isNear`로 ±1만 mount.
- "한 번에 하나만 재생" → `isActive` prop + `useEffect`로 play/pause.
- 위젯/컨트롤러 분리 → RN은 `<Video>`가 컴포넌트에 묶여 더 자동이지만, **프리로드(이웃 미리 로드)와 디코더 상한은 `isNear` 게이트로 명시적으로** 가져온다.

### 3-4. 제스처 · 오버레이 — `IgnorePointer`/`ValueKey` → `pointerEvents`/`key`

```tsx
// 레이어 구조 (Stack ≈ 절대배치 겹치기)
<View style={StyleSheet.absoluteFill}>
  <ActivePlayer ... />                                  {/* ① 영상 */}
  <GestureDetector gesture={composed}>                  {/* ② 제스처 (전체) */}
    <View style={StyleSheet.absoluteFill} />
  </GestureDetector>
  <View style={styles.scrim} pointerEvents="none" />    {/* ③ 장식: 터치 통과 (≈ IgnorePointer) */}
  <BottomInfo video={video} pointerEvents="none" />     {/* ③ 정보: 터치 통과 */}
  <SideActionBar ... />                                 {/* ③ 액션바: 상호작용(통과 X) */}
  {heart && <HeartBurst key={heart.key} x={heart.x} y={heart.y} onDone={() => setHeart(null)} />}
</View>

// 탭(재생/정지) + 더블탭(좋아요, 위치 하트). key 교체로 애니메이션 재시작.
const single = Gesture.Tap().onEnd(() => togglePlayPause());
const double = Gesture.Tap().numberOfTaps(2).onEnd((e) => {
  like(index);                                          // 멱등
  setHeart({ x: e.x, y: e.y, key: heartKey + 1 });      // key++ → HeartBurst 리마운트 → 처음부터 재생
});
const composed = Gesture.Exclusive(double, single);
```

- `IgnorePointer` → **`pointerEvents="none"`** (장식은 터치를 아래 제스처 레이어로 통과, 액션바만 상호작용).
- `ValueKey(_heartKey)` 교체 → **`key` 교체로 리마운트** (연타에도 하트가 매번 새로 팝업).
- 애니메이션(스케일 팝/회전 디스크/하트 elasticOut)은 **Reanimated**(`withSequence`/`withRepeat`/`withSpring`)로.

---

## 4. RN이 공짜로 주는 것 vs 그래도 손으로 해야 하는 것

| RN이 자동으로 주는 것                                    | 그래도 직접 해야 하는 것                                                 |
| -------------------------------------------------------- | ------------------------------------------------------------------------ |
| `FlatList` 가상화 → 윈도우 밖 셀 unmount(≈ dispose)      | **동시 디코더 상한**: `isNear`로 ±1만 `<VideoView>` mount, 나머진 썸네일 |
| `onViewableItemsChanged` → "보이는 것" 판별(≈ setActive) | **빠른 스크롤 레이스 가드**(아래 §5)                                     |
| `useInfiniteQuery` → 페이지네이션 상태 전부              | **단일 재생 보장**(다른 셀 `paused`/pause 유지)                          |
| `key` 교체 → 리마운트                                    | **AppState 일시정지/복귀** 배선                                          |

> 한 문장: **설계 결정은 1:1 전이되고, "윈도우 관리·페이지네이션 상태"는 RN이 더 선언적으로 주지만, "디코더 상한·레이스 가드·단일 재생"은 어느 프레임워크든 직접 책임진다.**

---

## 5. 포팅 시 함정 (체크리스트)

- [ ] `onViewableItemsChanged`는 빠른 스크롤에 연달아 발화 → 현재 인덱스 재확인/디바운스 (Flutter의 `currentIndex` 재검증과 동일 이유).
- [ ] `<VideoView>` 인스턴스 수 상한 — 안 두면 RN도 디코더 고갈/크래시(이 프로젝트의 출발점).
- [ ] `AppState`에서 `'inactive'`(iOS 전환 중)는 **무시**, `'background'`에서만 일시정지 (Flutter의 `inactive`/`detached` 무시와 동일).
- [ ] `onViewableItemsChanged`/`viewabilityConfig`는 **안정 참조**(useRef) — 매 렌더 새로 만들면 RN이 에러.
- [ ] 세로 풀스크린 스냅: `FlatList pagingEnabled` + 풀스크린 아이템(또는 `react-native-pager-view`).
- [ ] 좋아요/북마크는 클라이언트 상태(낙관적 mutation 또는 Zustand 오버레이).
- [ ] 디스크 캐시(flutter_cache_manager) → `expo-video`/`react-native-video` 자체 캐시 또는 `expo-file-system` 프리페치.
