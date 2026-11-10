import 'package:esme26/domain/models/current_user.dart';
import 'package:esme26/domain/repositories/current_user_repository.dart';

/// Version sans persistance : utilisée par défaut (tests, aperçus).
class InMemoryCurrentUserRepository implements CurrentUserRepository {
  CurrentUser? _user;

  InMemoryCurrentUserRepository([this._user]);

  @override
  CurrentUser? get currentUser => _user;

  @override
  Future<void> save(CurrentUser user) async => _user = user;

  @override
  Future<void> clear() async => _user = null;
}
