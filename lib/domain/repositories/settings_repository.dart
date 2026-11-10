import 'package:esme26/domain/models/theme_preference.dart';

abstract interface class SettingsRepository {
  /// [ThemePreference.system] tant que rien n'a été choisi.
  ThemePreference get themePreference;

  Future<void> setThemePreference(ThemePreference preference);
}
