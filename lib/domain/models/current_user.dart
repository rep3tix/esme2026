import 'package:esme26/domain/models/user.dart';

/// Utilisateur local issu de l'onboarding.
///
/// Ne contient que ce que le parcours collecte. Le modèle [User] complet
/// (email, date de naissance, adresse…) viendra avec l'authentification.
class CurrentUser {
  final UserRole role;
  final String firstName;
  final String lastName;
  final String trade;
  final Set<String> interests;
  final String city;
  final String postalCode;
  final String country;
  final DateTime createdAt;

  CurrentUser({
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.trade = '',
    Set<String> interests = const {},
    required this.city,
    required this.postalCode,
    required this.country,
    required this.createdAt,
  }) : interests = Set.unmodifiable(interests);

  Map<String, Object?> toJson() => {
    'role': role.name,
    'firstName': firstName,
    'lastName': lastName,
    'trade': trade,
    'interests': interests.toList(),
    'city': city,
    'postalCode': postalCode,
    'country': country,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Lève une [FormatException] si les données sont invalides.
  factory CurrentUser.fromJson(Map<String, Object?> json) {
    T read<T>(String key) {
      final value = json[key];
      if (value is! T) throw FormatException('Champ "$key" invalide', json);
      return value;
    }

    final roleName = read<String>('role');
    final role = UserRole.values.where((r) => r.name == roleName).firstOrNull;
    if (role == null) throw FormatException('Rôle inconnu : $roleName', json);

    final createdAt = DateTime.tryParse(read<String>('createdAt'));
    if (createdAt == null) throw FormatException('Date invalide', json);

    return CurrentUser(
      role: role,
      firstName: read<String>('firstName'),
      lastName: read<String>('lastName'),
      trade: read<String>('trade'),
      interests: read<List<Object?>>('interests').whereType<String>().toSet(),
      city: read<String>('city'),
      postalCode: read<String>('postalCode'),
      country: read<String>('country'),
      createdAt: createdAt,
    );
  }
}
