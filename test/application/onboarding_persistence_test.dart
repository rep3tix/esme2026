import 'package:esme26/application/onboarding_controller.dart';
import 'package:esme26/data/repositories/in_memory_current_user_repository.dart';
import 'package:esme26/domain/models/user.dart';
import 'package:esme26/domain/repositories/kyc_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _ApprovingKyc implements KycRepository {
  @override
  Future<KycResult> verify() async => KycResult.approved;
}

void main() {
  test('nothing is saved before the onboarding is completed', () {
    final users = InMemoryCurrentUserRepository();
    final controller = OnboardingController(kycRepository: _ApprovingKyc(), userRepository: users);
    controller.chooseRole(UserRole.customer);
    controller.toggleInterest('Bijouterie');
    controller.next();
    expect(controller.result, isNull);
    expect(users.currentUser, isNull);
    controller.dispose();
  });

  test('artisan is saved after KYC without data from the other profile', () async {
    final users = InMemoryCurrentUserRepository();
    final controller = OnboardingController(kycRepository: _ApprovingKyc(), userRepository: users);

    // Saisie côté particulier, puis changement de profil.
    controller.chooseRole(UserRole.customer);
    controller.toggleInterest('Bijouterie');
    controller.requestBack();
    controller.chooseRole(UserRole.artisan);

    controller.updateTrade('  Potier ');
    controller.next();
    controller.updateCity('Lyon');
    controller.updatePostalCode('69001');
    controller.next();
    expect(users.currentUser, isNull, reason: 'pas encore vérifié');

    await controller.verifyIdentity();

    final saved = users.currentUser;
    expect(saved, isNotNull);
    expect(saved!.role, UserRole.artisan);
    expect(saved.trade, 'Potier');
    expect(saved.city, 'Lyon');
    expect(saved.interests, isEmpty);
    expect(saved.firstName, isEmpty);
    controller.dispose();
  });
}
