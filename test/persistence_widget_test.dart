import 'package:esme26/data/repositories/in_memory_current_user_repository.dart';
import 'package:esme26/data/repositories/in_memory_settings_repository.dart';
import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Simule un redémarrage : nouvelle app, même stockage.
Future<void> restart(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a completed onboarding is skipped on the next launch', (tester) async {
    final users = InMemoryCurrentUserRepository();
    await tester.pumpWidget(MyApp(userRepository: users));
    await completeCustomerOnboarding(tester);

    expect(find.text('Bienvenue Camille !'), findsOneWidget);
    expect(users.currentUser?.firstName, 'Camille');
    expect(users.currentUser?.interests, {'Décoration'});
    expect(users.currentUser?.city, 'Paris');

    await restart(tester, MyApp(userRepository: users));
    expect(find.text('Je suis particulier'), findsNothing);
    expect(find.text('Bienvenue Camille !'), findsOneWidget);
  });

  testWidgets('restarting the sign-up forgets the user', (tester) async {
    final users = InMemoryCurrentUserRepository();
    await tester.pumpWidget(MyApp(userRepository: users));
    await completeCustomerOnboarding(tester);

    await tester.tap(find.byTooltip('Réglages'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Recommencer l’inscription');
    await tapText(tester, 'Recommencer');

    expect(users.currentUser, isNull);
    expect(find.text('Je suis particulier'), findsOneWidget);
  });

  testWidgets('the chosen theme is applied and kept across launches', (tester) async {
    final users = InMemoryCurrentUserRepository();
    final settings = InMemorySettingsRepository();
    await tester.pumpWidget(MyApp(userRepository: users, settingsRepository: settings));
    await completeCustomerOnboarding(tester);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.system);

    await tester.tap(find.byTooltip('Réglages'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Sombre');

    expect(settings.themePreference, ThemePreference.dark);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);

    await restart(tester, MyApp(userRepository: users, settingsRepository: settings));
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
  });
}
