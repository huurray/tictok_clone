/// 피드 동작을 조절하는 튜닝 상수.
class AppConstants {
  AppConstants._();

  /// 현재 페이지 양옆으로 몇 개의 컨트롤러를 살려둘지.
  /// 윈도우 = 현재 ± [preloadWindow]. 클수록 스와이프는 부드럽지만 메모리를 더 쓴다.
  static const int preloadWindow = 1;

  /// 시뮬레이션 페이지네이션 피드의 페이지 크기.
  static const int pageSize = 5;

  /// 현재 index가 끝에서 이 개수 이내로 들어오면 loadMore를 호출한다.
  static const int loadMoreThreshold = 2;
}
