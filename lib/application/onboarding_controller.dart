import 'dart:async';

import 'package:esme26/domain/models/current_user.dart';
import 'package:esme26/domain/models/user.dart';
import 'package:esme26/domain/onboarding/onboarding_flow.dart';
import 'package:esme26/domain/repositories/current_user_repository.dart';
import 'package:esme26/domain/repositories/kyc_repository.dart';
import 'package:flutter/foundation.dart';

enum KycStatus { idle, verifying, rejected, failed }

class OnboardingController extends ChangeNotifier {
  final KycRepository kycRepository;

  /// Si fourni, l'utilisateur y est enregistré à la fin du parcours.
  final CurrentUserRepository? userRepository;
  final OnboardingFlow _flow = OnboardingFlow();
  KycStatus _kycStatus = KycStatus.idle;
  String? _kycError;
  bool _disposed = false;

  OnboardingController({required this.kycRepository, this.userRepository});

  OnboardingStep get step => _flow.step;
  UserRole? get role => _flow.role;
  bool get isCompleted => step == OnboardingStep.completed;
  bool get isChoosingRole => step == OnboardingStep.role;
  bool get canGoBack => _flow.canGoBack && !isVerifying;
  int get stepNumber => _flow.stepNumber;
  int get stepCount => _flow.steps.length;
  double get progress => stepNumber / stepCount;
  String get trade => _flow.trade;
  Set<String> get interests => _flow.interests;
  String get firstName => _flow.firstName;
  String get lastName => _flow.lastName;
  String get city => _flow.city;
  String get postalCode => _flow.postalCode;
  String get country => _flow.country;
  KycStatus get kycStatus => _kycStatus;
  String? get kycError => _kycError;
  bool get isVerifying => _kycStatus == KycStatus.verifying;

  void chooseRole(UserRole role) {
    _flow.chooseRole(role);
    _resetKyc();
    notifyListeners();
  }

  void toggleInterest(String value) {
    _flow.toggleInterest(value);
    notifyListeners();
  }

  void updateTrade(String value) => _flow.trade = value;
  void updateFirstName(String value) => _flow.firstName = value;
  void updateLastName(String value) => _flow.lastName = value;
  void updateCity(String value) => _flow.city = value;
  void updatePostalCode(String value) => _flow.postalCode = value;
  void updateCountry(String value) => _flow.country = value;

  void next() {
    _flow.next();
    _saveIfCompleted();
    notifyListeners();
  }

  /// L'utilisateur construit à partir des saisies, une fois le parcours terminé.
  CurrentUser? get result {
    final role = this.role;
    if (!isCompleted || role == null) return null;
    final isArtisan = role == UserRole.artisan;
    return CurrentUser(
      role: role,
      // Les saisies propres à l'autre profil ne sont pas conservées.
      firstName: isArtisan ? '' : firstName.trim(),
      lastName: isArtisan ? '' : lastName.trim(),
      trade: isArtisan ? trade.trim() : '',
      interests: isArtisan ? const {} : interests,
      city: city.trim(),
      postalCode: postalCode.trim(),
      country: country.trim(),
      createdAt: DateTime.now(),
    );
  }

  void _saveIfCompleted() {
    final user = result;
    final repository = userRepository;
    if (user == null || repository == null) return;
    // La lecture est mise à jour tout de suite ; l'écriture disque suit.
    // En cas d'échec, l'onboarding sera simplement reproposé au prochain lancement.
    unawaited(repository.save(user).catchError((Object error) => debugPrint('Enregistrement impossible : $error')));
  }

  bool requestBack() {
    if (!canGoBack) return false;
    _flow.back();
    _resetKyc();
    notifyListeners();
    return true;
  }

  Future<void> verifyIdentity() async {
    if (isVerifying) return;
    if (step != OnboardingStep.kyc) {
      throw StateError('Identity verification requires the KYC step.');
    }
    _kycStatus = KycStatus.verifying;
    _kycError = null;
    notifyListeners();
    try {
      final result = await kycRepository.verify();
      if (_disposed) return;
      if (result == KycResult.approved) {
        _flow.completeKyc();
        _kycStatus = KycStatus.idle;
        _saveIfCompleted();
      } else {
        _kycStatus = KycStatus.rejected;
      }
    } on KycException catch (error) {
      if (_disposed) return;
      _kycStatus = KycStatus.failed;
      _kycError = error.message;
    } finally {
      if (!_disposed) {
        if (isVerifying) _kycStatus = KycStatus.idle;
        notifyListeners();
      }
    }
  }

  void _resetKyc() {
    _kycStatus = KycStatus.idle;
    _kycError = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
