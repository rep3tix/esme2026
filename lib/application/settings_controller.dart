import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';

/// Expose les réglages à l'UI et prévient les écrans quand ils changent.
class SettingsController extends ChangeNotifier {
  final SettingsRepository _repository;
  ThemePreference _themePreference;

  SettingsController({required SettingsRepository repository})
    : _repository = repository,
      _themePreference = repository.themePreference;

  ThemePreference get themePreference => _themePreference;

  Future<void> setThemePreference(ThemePreference preference) async {
    if (preference == _themePreference) return;
    // L'UI change tout de suite ; l'écriture disque suit.
    _themePreference = preference;
    notifyListeners();
    await _repository.setThemePreference(preference);
  }
}
