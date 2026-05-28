import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tiktok/app.dart';
import 'package:tiktok/core/preferences/preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 풀블리드 다크 영상 위에서도 잘 보이도록 상태바 아이콘을 밝게 설정.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  // 저장된 언어 설정을 읽기 위해 SharedPreferences를 먼저 로드한다.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TikTokApp(),
    ),
  );
}
