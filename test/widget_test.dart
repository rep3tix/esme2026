import 'dart:async';

import 'package:esme26/domain/repositories/kyc_repository.dart';
import 'package:esme26/ui/router.dart';
import 'package:esme26/ui/widgets/onboarding/kyc_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester, {KycRepository? kycRepository}) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: createRouter(kycRepository: kycRepository)));
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterField(WidgetTester tester, String label, String value) async {
  final finder = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
}

Future<void> fillLocation(WidgetTester tester) async {
  await enterField(tester, 'Ville', 'Paris');
  await enterField(tester, 'Code postal', '75001');
  await tapText(tester, 'Continuer');
}

void main() {
  testWidgets('Role selection uses two elevated clickable cards', (tester) async {
    await pumpApp(tester);
    expect(find.text('Votre profil'), findsOneWidget);
    expect(find.text('Je suis artisan'), findsOneWidget);
    expect(find.text('Je suis particulier'), findsOneWidget);
    final cards = tester.widgetList<Card>(find.byType(Card));
    expect(cards, hasLength(2));
    expect(cards.every((card) => card.elevation! > 0), isTrue);
    expect(find.byType(InkWell), findsNWidgets(2));
  });

  testWidgets('Customer flow validates fields and reaches home without KYC', (tester) async {
    final router = createRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tapText(tester, 'Je suis particulier');
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    await tapText(tester, 'Poterie et céramique');
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Continuer');
    expect(find.text('Ce champ est obligatoire.'), findsNWidgets(2));

    await enterField(tester, 'Prénom', 'Camille');
    await enterField(tester, 'Nom', 'Martin');
    await tapText(tester, 'Continuer');
    await tapText(tester, 'Continuer');
    expect(find.text('Ce champ est obligatoire.'), findsNWidgets(2));
    await fillLocation(tester);

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Bienvenue Camille !'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/homepage');
    expect(find.byType(KycStep), findsNothing);
    expect(find.byTooltip('Retour'), findsNothing);
  });

  testWidgets('Artisan flow validates trade and waits for mock KYC', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Je suis artisan');
    await tapText(tester, 'Continuer');
    expect(find.text('Indiquez votre métier.'), findsOneWidget);
    await enterField(tester, 'Métier', 'Menuisier');
    await tapText(tester, 'Continuer');
    await fillLocation(tester);
    expect(find.textContaining('Mode démonstration'), findsOneWidget);
    await tester.tap(find.text('Simuler la vérification'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Accueil'), findsNothing);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Bienvenue dans votre espace artisan !'), findsOneWidget);
  });

  testWidgets('Back preserves draft inputs and allows switching role', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Je suis particulier');
    await tapText(tester, 'Décoration');
    await tapText(tester, 'Continuer');
    await enterField(tester, 'Prénom', 'Camille');
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Décoration')).selected, isTrue);
    await tapText(tester, 'Continuer');
    expect(find.text('Camille'), findsOneWidget);
    await enterField(tester, 'Nom', 'Martin');
    await tapText(tester, 'Continuer');
    await enterField(tester, 'Ville', 'Lyon');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Camille'), findsOneWidget);
    await tapText(tester, 'Continuer');
    expect(find.text('Lyon'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
    }
    await tapText(tester, 'Je suis artisan');
    expect(find.text('Quel est votre métier ?'), findsOneWidget);
    expect(find.text('Comment vous appelez-vous ?'), findsNothing);
  });

  testWidgets('KYC rejection and provider failure are visible and retryable', (tester) async {
    final provider = _ControlledKycRepository();
    await pumpApp(tester, kycRepository: provider);
    await tapText(tester, 'Je suis artisan');
    await enterField(tester, 'Métier', 'Potier');
    await tapText(tester, 'Continuer');
    await fillLocation(tester);

    await tester.tap(find.text('Simuler la vérification'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(KycStep), findsOneWidget);
    expect(provider.calls, 1);
    provider.request.complete(KycResult.rejected);
    await tester.pumpAndSettle();
    expect(find.textContaining('Vérification refusée'), findsOneWidget);
    expect(find.text('Accueil'), findsNothing);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    provider.request.completeError(const KycException('Service indisponible.'));
    await tester.pumpAndSettle();
    expect(find.text('Service indisponible.'), findsOneWidget);
    expect(find.text('Accueil'), findsNothing);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    provider.request.complete(KycResult.approved);
    await tester.pumpAndSettle();
    expect(find.text('Accueil'), findsOneWidget);
    expect(provider.calls, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A fresh app starts onboarding again without persistence', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Je suis artisan');
    await enterField(tester, 'Métier', 'Potier');
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpApp(tester);
    expect(find.text('Je suis artisan'), findsOneWidget);
    await tapText(tester, 'Je suis artisan');
    expect(find.text('Potier'), findsNothing);
  });

  testWidgets('Onboarding remains scrollable on a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpApp(tester);
    await tapText(tester, 'Je suis particulier');
    await tapText(tester, 'Décoration');
    await tapText(tester, 'Continuer');
    await enterField(tester, 'Prénom', 'Camille');
    await enterField(tester, 'Nom', 'Martin');
    await tapText(tester, 'Continuer');
    await fillLocation(tester);
    expect(find.text('Accueil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ControlledKycRepository implements KycRepository {
  late Completer<KycResult> request;
  int calls = 0;

  @override
  Future<KycResult> verify() {
    calls++;
    request = Completer<KycResult>();
    return request.future;
  }
}
