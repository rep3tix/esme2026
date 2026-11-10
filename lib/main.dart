import 'package:esme26/application/settings_controller.dart';
import 'package:esme26/data/repositories/in_memory_current_user_repository.dart';
import 'package:esme26/data/repositories/in_memory_settings_repository.dart';
import 'package:esme26/data/repositories/local_current_user_repository.dart';
import 'package:esme26/data/repositories/local_settings_repository.dart';
import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/domain/repositories/current_user_repository.dart';
import 'package:esme26/domain/repositories/settings_repository.dart';
import 'package:esme26/ui/router.dart';
import 'package:esme26/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Chargé une fois au démarrage : les lectures sont ensuite synchrones.
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(userRepository: LocalCurrentUserRepository(prefs), settingsRepository: LocalSettingsRepository(prefs)));
}

class MyApp extends StatefulWidget {
  /// Sans valeur : version en mémoire, rien n'est conservé (tests).
  final CurrentUserRepository? userRepository;
  final SettingsRepository? settingsRepository;

  const MyApp({super.key, this.userRepository, this.settingsRepository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsController _settings = SettingsController(
    repository: widget.settingsRepository ?? InMemorySettingsRepository(),
  );

  // Créé une seule fois par instance de l'app : pas recréé à chaque build.
  late final GoRouter _router = createRouter(
    userRepository: widget.userRepository ?? InMemoryCurrentUserRepository(),
    settings: _settings,
  );

  @override
  void dispose() {
    _router.dispose();
    _settings.dispose();
    super.dispose();
  }

  static ThemeMode _toThemeMode(ThemePreference preference) => switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => MaterialApp.router(
        title: 'Artisanat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _toThemeMode(_settings.themePreference),
        routerConfig: _router,
      ),
    );
  }
}
