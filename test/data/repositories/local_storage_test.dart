import 'package:esme26/data/repositories/local_current_user_repository.dart';
import 'package:esme26/data/repositories/local_settings_repository.dart';
import 'package:esme26/domain/models/current_user.dart';
import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/domain/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

CurrentUser _camille() => CurrentUser(
  role: UserRole.customer,
  firstName: 'Camille',
  lastName: 'Martin',
  interests: {'Décoration', 'Bijouterie'},
  city: 'Paris',
  postalCode: '75001',
  country: 'France',
  createdAt: DateTime.utc(2026, 11, 10, 12),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CurrentUser survives a JSON round trip', () {
    final restored = CurrentUser.fromJson(_camille().toJson());
    expect(restored.role, UserRole.customer);
    expect(restored.firstName, 'Camille');
    expect(restored.lastName, 'Martin');
    expect(restored.interests, {'Décoration', 'Bijouterie'});
    expect(restored.city, 'Paris');
    expect(restored.postalCode, '75001');
    expect(restored.country, 'France');
    expect(restored.createdAt, DateTime.utc(2026, 11, 10, 12));
  });

  test('CurrentUser rejects invalid data', () {
    expect(() => CurrentUser.fromJson({'role': 'admin'}), throwsFormatException);
  });

  test('saved user is read back by a fresh repository (app restart)', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = LocalCurrentUserRepository(prefs);
    expect(first.currentUser, isNull);

    await first.save(_camille());
    expect(first.currentUser?.firstName, 'Camille');

    final afterRestart = LocalCurrentUserRepository(prefs);
    expect(afterRestart.currentUser?.firstName, 'Camille');
    expect(afterRestart.currentUser?.interests, contains('Décoration'));
  });

  test('clear forgets the user for the next launch', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalCurrentUserRepository(prefs);
    await repository.save(_camille());
    await repository.clear();
    expect(repository.currentUser, isNull);
    expect(LocalCurrentUserRepository(prefs).currentUser, isNull);
  });

  test('corrupted stored user is ignored instead of crashing', () async {
    SharedPreferences.setMockInitialValues({LocalCurrentUserRepository.storageKey: '{pas du json'});
    final prefs = await SharedPreferences.getInstance();
    expect(LocalCurrentUserRepository(prefs).currentUser, isNull);
  });

  test('theme preference defaults to system and is persisted', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = LocalSettingsRepository(prefs);
    expect(settings.themePreference, ThemePreference.system);

    await settings.setThemePreference(ThemePreference.dark);
    expect(LocalSettingsRepository(prefs).themePreference, ThemePreference.dark);
  });

  test('unknown stored theme falls back to system', () async {
    SharedPreferences.setMockInitialValues({LocalSettingsRepository.themeKey: 'rose'});
    final prefs = await SharedPreferences.getInstance();
    expect(LocalSettingsRepository(prefs).themePreference, ThemePreference.system);
  });
}
