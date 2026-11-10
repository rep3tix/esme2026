import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/domain/repositories/settings_repository.dart';

/// Version sans persistance : utilisée par défaut (tests, aperçus).
class InMemorySettingsRepository implements SettingsRepository {
  @override
  ThemePreference themePreference;

  InMemorySettingsRepository([this.themePreference = ThemePreference.system]);

  @override
  Future<void> setThemePreference(ThemePreference preference) async => themePreference = preference;
}
