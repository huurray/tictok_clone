import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tiktok/core/theme/app_theme.dart';
import 'package:tiktok/features/settings/providers/locale_provider.dart';
import 'package:tiktok/l10n/gen/app_localizations.dart';

/// 설정 화면. 현재는 언어(한국어/English) 선택을 제공한다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppGaps.screenPadding),
        children: [
          Text(
            l10n.settingsLanguage,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsLanguageDescription,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          for (final option in _languageOptions)
            _LanguageTile(
              option: option,
              selected: current.languageCode == option.locale.languageCode,
              onTap: () =>
                  ref.read(localeProvider.notifier).setLocale(option.locale),
            ),
        ],
      ),
    );
  }
}

/// 언어 선택 항목 메타데이터. 이름은 항상 해당 언어로 표기(네이티브 네임).
class _LanguageOption {
  final Locale locale;
  final String nativeName;
  final String flag;

  const _LanguageOption(this.locale, this.nativeName, this.flag);
}

const List<_LanguageOption> _languageOptions = [
  _LanguageOption(Locale('ko'), '한국어', '🇰🇷'),
  _LanguageOption(Locale('en'), 'English', '🇺🇸'),
];

class _LanguageTile extends StatelessWidget {
  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandRed.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.brandRed : Colors.white12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(option.flag, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option.nativeName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.brandRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
