import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/core/preferences/preferences_provider.dart';

/// 앱이 지원하는 로케일 (l10n ARB 파일과 일치해야 함).
const List<Locale> supportedAppLocales = [Locale('ko'), Locale('en')];

/// 현재 로케일을 보관하고, 사용자의 선택을 shared_preferences에 영속화한다.
class LocaleNotifier extends Notifier<Locale> {
  static const _prefsKey = 'locale_code';

  @override
  Locale build() {
    final code = ref.read(sharedPreferencesProvider).getString(_prefsKey);
    return _localeFromCode(code) ?? const Locale('ko');
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_prefsKey, locale.languageCode);
  }

  Locale? _localeFromCode(String? code) {
    if (code == null) return null;
    for (final locale in supportedAppLocales) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
