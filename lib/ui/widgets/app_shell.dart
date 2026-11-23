import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final String title;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Widget child;

  const AppShell({
    super.key,
    required this.title,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (context, mode, _) =>
                ThemeModeMenu(selected: mode, onSelected: onThemeModeChanged),
          ),
        ],
      ),
      body: child,
    );
  }
}

/// Menu de l'app bar : thème du système, clair ou sombre.
class ThemeModeMenu extends StatelessWidget {
  static const tooltip = 'Choisir le thème';

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  const ThemeModeMenu({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static IconData iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  static String labelFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Système',
    ThemeMode.light => 'Clair',
    ThemeMode.dark => 'Sombre',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      tooltip: tooltip,
      initialValue: selected,
      onSelected: onSelected,
      icon: Icon(iconFor(selected)),
      itemBuilder: (context) => [
        for (final mode in ThemeMode.values)
          CheckedPopupMenuItem<ThemeMode>(
            value: mode,
            checked: mode == selected,
            child: Text(labelFor(mode)),
          ),
      ],
    );
  }
}
