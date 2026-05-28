import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/feed/screens/feed_screen.dart';

class TikTokApp extends StatelessWidget {
  const TikTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const FeedScreen(),
    );
  }
}
