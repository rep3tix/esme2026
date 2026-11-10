import 'dart:convert';

import 'package:esme26/domain/models/current_user.dart';
import 'package:esme26/domain/repositories/current_user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enregistre l'utilisateur sur l'appareil (SharedPreferences, en JSON).
///
/// Stockage local non chiffré : n'y mettre aucune donnée sensible
/// (mot de passe, pièce d'identité…).
class LocalCurrentUserRepository implements CurrentUserRepository {
  static const storageKey = 'current_user.v1';

  final SharedPreferences _prefs;
  CurrentUser? _user;

  LocalCurrentUserRepository(this._prefs) : _user = _read(_prefs);

  static CurrentUser? _read(SharedPreferences prefs) {
    final raw = prefs.getString(storageKey);
    if (raw == null) return null;
    try {
      return CurrentUser.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object {
      // Données illisibles (ancienne version, corruption) : on repart de zéro
      // plutôt que de bloquer le démarrage.
      return null;
    }
  }

  @override
  CurrentUser? get currentUser => _user;

  @override
  Future<void> save(CurrentUser user) async {
    _user = user;
    await _prefs.setString(storageKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clear() async {
    _user = null;
    await _prefs.remove(storageKey);
  }
}
