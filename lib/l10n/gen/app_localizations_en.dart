// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDescription => 'Choose your preferred language';

  @override
  String get feedLoadError => 'Failed to load feed';

  @override
  String get videoLoadError => 'Couldn\'t load video';

  @override
  String get noVideos => 'No videos';

  @override
  String get retry => 'Retry';
}
