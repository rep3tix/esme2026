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
  late final ValueNotifier<bool> _isDarkMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _isDarkMode = ValueNotifier(
      widget.preferences.getBool(isDarkMode) ?? false,
    );
    _router = createRouter(
      darkMode: _isDarkMode,
      onToggleDarkMode: _toggleDarkMode,
      // L'utilisateur est enregistré dans les mêmes préférences que le thème.
      userRepository: LocalCurrentUserRepository(widget.preferences),
    );
  }

  void _toggleDarkMode() {
    final nextValue = !_isDarkMode.value;
    _isDarkMode.value = nextValue;
    unawaited(_saveDarkMode(nextValue));
  }

  Future<void> _saveDarkMode(bool value) async {
    final saved = await widget.preferences.setBool(isDarkMode, value);
    if (!saved) {
      throw StateError('Unable to save the selected theme mode.');
    }
  }

  @override
  void dispose() {
    _router.dispose();
    _isDarkMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkMode,
      builder: (context, isDarkMode, _) => MaterialApp.router(
        title: 'Artisanat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
