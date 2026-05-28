/// Tuning constants for the feed.
class AppConstants {
  AppConstants._();

  /// How many controllers to keep alive on each side of the current page.
  /// Window = current ± [preloadWindow]. Larger = smoother swipes, more memory.
  static const int preloadWindow = 1;

  /// Page size for the simulated paginated feed.
  static const int pageSize = 5;

  /// Trigger loadMore when the current index is within this many items of the end.
  static const int loadMoreThreshold = 2;
}
