import 'package:esme26/domain/models/current_user.dart';

abstract interface class CurrentUserRepository {
  /// Lecture synchrone : les données sont chargées avant le lancement de l'app.
  /// Null si aucun onboarding n'a été terminé.
  CurrentUser? get currentUser;

  /// Remplace l'utilisateur enregistré.
  Future<void> save(CurrentUser user);

  /// Oublie l'utilisateur : l'onboarding sera proposé au prochain lancement.
  Future<void> clear();
}
