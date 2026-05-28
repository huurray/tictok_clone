import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:tiktok/core/constants/app_constants.dart';
import 'package:tiktok/data/models/video_model.dart';

/// `assets/mock/videos.json`을 rootBundle로 읽어 파싱하고, 그 풀을 순환시켜
/// 사실상 끝없는 피드를 시뮬레이션한다. 페이지마다 항목에 고유 id를 부여한다.
/// 파싱한 풀은 한 번만 로드하고 메모이즈한다.
class VideoRepository {
  VideoRepository();

  static const _assetPath = 'assets/mock/videos.json';

  Future<List<VideoModel>>? _poolFuture;

  Future<List<VideoModel>> fetchPage(
    int page, {
    int pageSize = AppConstants.pageSize,
  }) async {
    // 버퍼링/로딩 상태를 확인할 수 있도록 네트워크 지연을 시뮬레이션.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final pool = await (_poolFuture ??= _loadPool());
    return List.generate(pageSize, (i) {
      final base = pool[(page * pageSize + i) % pool.length];
      return base.copyWith(id: 'p${page}_${i}_${base.id}');
    });
  }

  Future<List<VideoModel>> _loadPool() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
