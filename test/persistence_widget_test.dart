import 'package:esme26/data/repositories/local_current_user_repository.dart';
import 'package:esme26/data/shared_preferences/shared_preference_keys.dart';
import 'package:esme26/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<void> completeCustomerOnboarding(WidgetTester tester) async {
  await tapText(tester, 'Je suis particulier');
  await tapText(tester, 'Décoration');
  await tapText(tester, 'Continuer');
  await enterField(tester, 'Prénom', 'Camille');
  await enterField(tester, 'Nom', 'Martin');
  await tapText(tester, 'Continuer');
  await enterField(tester, 'Ville', 'Paris');
  await enterField(tester, 'Code postal', '75001');
  await tapText(tester, 'Continuer');
}

/// Simule un redémarrage : nouvelle app, mêmes préférences sur l'appareil.
Future<void> restart(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(MyApp(preferences: prefs));
  await tester.pumpAndSettle();
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('a completed onboarding is skipped on the next launch', (tester) async {
    await tester.pumpWidget(MyApp(preferences: prefs));
    await completeCustomerOnboarding(tester);
    expect(find.text('Bienvenue Camille !'), findsOneWidget);

    final saved = LocalCurrentUserRepository(prefs).currentUser;
    expect(saved?.firstName, 'Camille');
    expect(saved?.interests, {'Décoration'});
    expect(saved?.city, 'Paris');

    await restart(tester, prefs);
    expect(find.text('Je suis particulier'), findsNothing);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Bienvenue Camille !'), findsOneWidget);
  });

  testWidgets('an unfinished onboarding is not saved', (tester) async {
    await tester.pumpWidget(MyApp(preferences: prefs));
    await tapText(tester, 'Je suis particulier');
    await tapText(tester, 'Décoration');

    await restart(tester, prefs);
    expect(find.text('Je suis particulier'), findsOneWidget);
  });

  testWidgets('restarting the sign-up forgets the user', (tester) async {
    await tester.pumpWidget(MyApp(preferences: prefs));
    await completeCustomerOnboarding(tester);

    await tapText(tester, 'Recommencer l’inscription');
    await tapText(tester, 'Recommencer');

    expect(LocalCurrentUserRepository(prefs).currentUser, isNull);
    expect(find.text('Je suis particulier'), findsOneWidget);

    await restart(tester, prefs);
    expect(find.text('Je suis particulier'), findsOneWidget);
  });

  testWidgets('user and dark mode are both restored', (tester) async {
    await tester.pumpWidget(MyApp(preferences: prefs));
    await completeCustomerOnboarding(tester);
    await tester.tap(find.byTooltip('Activer le mode sombre'));
    await tester.pumpAndSettle();
    expect(prefs.getBool(isDarkMode), isTrue);

    await restart(tester, prefs);
    expect(find.text('Bienvenue Camille !'), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
  });
}
