import 'package:tiktok/data/models/video_model.dart';

/// 공개·로열티프리 H.264 MP4를 사용하는 피드 기본 풀. 안정적인 호스트
/// (flutter.github.io, w3schools.com, test-videos.co.uk, media.w3.org)에서
/// 가져오며, 모두 접근 가능하고 iOS 시뮬레이터에서 무리 없이 재생될 만큼 가볍다.
/// 원본은 가로 영상이라 플레이어가 `BoxFit.cover`로 세로 화면을 채운다.
/// 리포지토리가 이 풀을 순환시켜 끝없는 피드를 시뮬레이션한다.
const List<VideoModel> mockVideos = [
  VideoModel(
    id: 'butterfly',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    username: '@nature.daily',
    caption: 'Slow mornings with this little one 🦋 #nature #calm #fyp',
    musicTitle: 'morning dew - ambient',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    likeCount: 1243000,
    commentCount: 8421,
    shareCount: 15600,
  ),
  VideoModel(
    id: 'bee',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    username: '@macro.world',
    caption: 'Caught this bee mid-snack 🐝🌸 macro season is back #macro',
    musicTitle: 'buzz - lofi beats',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    likeCount: 543200,
    commentCount: 3120,
    shareCount: 9800,
  ),
  VideoModel(
    id: 'bear',
    videoUrl: 'https://www.w3schools.com/html/movie.mp4',
    username: '@wildlife.clips',
    caption: 'He just wants a snack 🐻 #wildlife #bear #cute',
    musicTitle: 'into the wild - acoustic',
    avatarUrl: 'https://i.pravatar.cc/150?img=13',
    likeCount: 89400,
    commentCount: 1204,
    shareCount: 2300,
  ),
  VideoModel(
    id: 'big_buck_bunny',
    videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    username: '@bunny.studio',
    caption: 'Big Buck Bunny hops into your feed 🐰 #animation #classic',
    musicTitle: 'original sound - bunny.studio',
    avatarUrl: 'https://i.pravatar.cc/150?img=14',
    likeCount: 2100000,
    commentCount: 19200,
    shareCount: 45300,
  ),
  VideoModel(
    id: 'jellyfish_720',
    videoUrl:
        'https://test-videos.co.uk/vids/jellyfish/mp4/h264/720/Jellyfish_720_10s_1MB.mp4',
    username: '@ocean.calm',
    caption: 'POV: you are floating with the jellyfish 🪼💙 #ocean #asmr',
    musicTitle: 'underwater - chill',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    likeCount: 12300,
    commentCount: 540,
    shareCount: 410,
  ),
  VideoModel(
    id: 'sintel_720',
    videoUrl:
        'https://test-videos.co.uk/vids/sintel/mp4/h264/720/Sintel_720_10s_1MB.mp4',
    username: '@sintel.film',
    caption: 'An epic quest begins ⚔️ Sintel #blender #fantasy #shortfilm',
    musicTitle: 'epic orchestra - score',
    avatarUrl: 'https://i.pravatar.cc/150?img=16',
    likeCount: 765000,
    commentCount: 6700,
    shareCount: 12100,
  ),
  VideoModel(
    id: 'sintel_trailer',
    videoUrl: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
    username: '@trailers.hub',
    caption: 'This trailer still gives me chills 🥶 Sintel (2010) #trailer',
    musicTitle: 'cinematic - rise',
    avatarUrl: 'https://i.pravatar.cc/150?img=17',
    likeCount: 3400000,
    commentCount: 41000,
    shareCount: 98000,
  ),
  VideoModel(
    id: 'bunny_trailer',
    videoUrl: 'https://media.w3.org/2010/05/bunny/trailer.mp4',
    username: '@animation.fans',
    caption: 'The bunny trailer that started it all 🎬 #animation #throwback',
    musicTitle: 'playful - orchestral',
    avatarUrl: 'https://i.pravatar.cc/150?img=18',
    likeCount: 980000,
    commentCount: 8800,
    shareCount: 21000,
  ),
  VideoModel(
    id: 'movie_300',
    videoUrl: 'https://media.w3.org/2010/05/video/movie_300.mp4',
    username: '@behind.scenes',
    caption: 'A little behind-the-scenes magic ✨ #bts #film',
    musicTitle: 'studio session - jazz',
    avatarUrl: 'https://i.pravatar.cc/150?img=19',
    likeCount: 156000,
    commentCount: 2010,
    shareCount: 3400,
  ),
  VideoModel(
    id: 'jellyfish_360',
    videoUrl:
        'https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_2MB.mp4',
    username: '@deepblue',
    caption: 'Could watch these for hours 🌊🪼 part 2 #ocean #relax #fyp',
    musicTitle: 'deep blue - ambient',
    avatarUrl: 'https://i.pravatar.cc/150?img=20',
    likeCount: 671000,
    commentCount: 5300,
    shareCount: 14800,
  ),
];
