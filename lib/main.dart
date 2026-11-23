import 'dart:async';

import 'package:esme26/data/repositories/local_current_user_repository.dart';
import 'package:esme26/data/shared_preferences/shared_preference_keys.dart';
import 'package:esme26/ui/router.dart';
import 'package:esme26/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(MyApp(preferences: preferences));
}

class MyApp extends StatefulWidget {
  final SharedPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ValueNotifier<ThemeMode> _themeMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeMode = ValueNotifier(_readThemeMode(widget.preferences));
    _router = createRouter(
      themeMode: _themeMode,
      onThemeModeChanged: _setThemeMode,
      // L'utilisateur est enregistré dans les mêmes préférences que le thème.
      userRepository: LocalCurrentUserRepository(widget.preferences),
    );
  }

  /// Par défaut le thème suit le système (jour/nuit de l'appareil).
  /// L'ancien booléen `is_dark_mode` est relu pour ne pas perdre le choix.
  static ThemeMode _readThemeMode(SharedPreferences preferences) {
    final stored = preferences.getString(themeMode);
    for (final mode in ThemeMode.values) {
      if (mode.name == stored) return mode;
    }
    return switch (preferences.getBool(isDarkMode)) {
      true => ThemeMode.dark,
      false => ThemeMode.light,
      null => ThemeMode.system,
    };
  }

  void _setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    unawaited(_saveThemeMode(mode));
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final saved = await widget.preferences.setString(themeMode, mode.name);
    if (!saved) {
      throw StateError('Unable to save the selected theme mode.');
    }
    await widget.preferences.remove(isDarkMode);
  }

  @override
  void dispose() {
    _router.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) => MaterialApp.router(
        title: 'Artisanat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        routerConfig: _router,
      ),
    );
  }
}
