import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final String title;
  final ValueNotifier<bool> darkMode;
  final VoidCallback onToggleDarkMode;
  final Widget child;

  const AppShell({
    super.key,
    required this.title,
    required this.darkMode,
    required this.onToggleDarkMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: darkMode,
            builder: (context, isDarkMode, _) => IconButton(
              tooltip: isDarkMode
                  ? 'Activer le mode clair'
                  : 'Activer le mode sombre',
              onPressed: onToggleDarkMode,
              icon: Icon(
                isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),
        ],
      ),
      body: child,
    );
  }
}
