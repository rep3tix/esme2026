import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enregistre les réglages sur l'appareil (SharedPreferences).
class LocalSettingsRepository implements SettingsRepository {
  static const themeKey = 'settings.theme';

  final SharedPreferences _prefs;

  LocalSettingsRepository(this._prefs);

  @override
  ThemePreference get themePreference {
    final name = _prefs.getString(themeKey);
    return ThemePreference.values.where((p) => p.name == name).firstOrNull ?? ThemePreference.system;
  }

  @override
  Future<void> setThemePreference(ThemePreference preference) => _prefs.setString(themeKey, preference.name);
}
