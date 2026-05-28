// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navHome => '홈';

  @override
  String get navSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageDescription => '사용할 언어를 선택하세요';

  @override
  String get feedLoadError => '피드를 불러오지 못했어요';

  @override
  String get videoLoadError => '영상을 불러올 수 없어요';

  @override
  String get noVideos => '영상이 없습니다';

  @override
  String get retry => '다시 시도';
}
