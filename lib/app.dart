import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/core/router/app_router.dart';
import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/features/settings/providers/locale_provider.dart';
import 'package:tiktok/l10n/gen/app_localizations.dart';

class TikTokApp extends ConsumerWidget {
  const TikTokApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'TikTok Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
