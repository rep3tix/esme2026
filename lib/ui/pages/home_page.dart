import 'package:esme26/application/settings_controller.dart';
import 'package:esme26/domain/models/theme_preference.dart';
import 'package:esme26/domain/models/user.dart';
import 'package:esme26/ui/widgets/responsive_body.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final UserRole role;
  final String firstName;

  /// Si fourni, le menu propose de changer de thème.
  final SettingsController? settings;

  /// Si fourni, le menu propose d'oublier l'utilisateur et de recommencer.
  final Future<void> Function()? onSignOut;

  const HomePage({super.key, required this.role, required this.firstName, this.settings, this.onSignOut});

  bool get _isArtisan => role == UserRole.artisan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = firstName.trim();

    // Raccourcis à venir : les écrans correspondants ne sont pas encore développés.
    final shortcuts = _isArtisan
        ? const [
            (Icons.calendar_month_outlined, 'Mon agenda'),
            (Icons.inbox_outlined, 'Demandes reçues'),
            (Icons.photo_library_outlined, 'Mes réalisations'),
            (Icons.star_outline_rounded, 'Avis clients'),
          ]
        : const [
            (Icons.search_rounded, 'Trouver un artisan'),
            (Icons.event_outlined, 'Mes rendez-vous'),
            (Icons.favorite_outline_rounded, 'Favoris'),
            (Icons.chat_bubble_outline_rounded, 'Messages'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          if (settings != null || onSignOut != null) _AccountMenu(settings: settings, onSignOut: onSignOut),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_isArtisan ? Icons.handyman_outlined : Icons.home_outlined, size: 40, color: scheme.onPrimary),
                    const SizedBox(height: 16),
                    Text(
                      name.isEmpty ? 'Bienvenue dans votre espace artisan !' : 'Bienvenue $name !',
                      style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre parcours de découverte est terminé.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Bientôt disponible', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              // Deux colonnes à hauteur libre : pas de débordement sur petit écran.
              LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final (icon, label) in shortcuts)
                        SizedBox(width: tileWidth, child: _Shortcut(icon: icon, label: label)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Shortcut({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Volontairement non cliquable tant que la fonctionnalité n'existe pas.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 16),
          Text(label, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

enum _MenuAction { system, light, dark, signOut }

class _AccountMenu extends StatelessWidget {
  final SettingsController? settings;
  final Future<void> Function()? onSignOut;

  const _AccountMenu({required this.settings, required this.onSignOut});

  static const _themes = {
    _MenuAction.system: (ThemePreference.system, Icons.brightness_auto_outlined, 'Comme l’appareil'),
    _MenuAction.light: (ThemePreference.light, Icons.light_mode_outlined, 'Clair'),
    _MenuAction.dark: (ThemePreference.dark, Icons.dark_mode_outlined, 'Sombre'),
  };

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommencer l’inscription ?'),
        content: const Text('Les informations saisies pendant l’onboarding seront effacées de cet appareil.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Recommencer')),
        ],
      ),
    );
    if (confirmed ?? false) await onSignOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    final current = settings?.themePreference;
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Réglages',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) {
        final theme = _themes[action];
        if (theme != null) {
          settings?.setThemePreference(theme.$1);
        } else {
          _confirmSignOut(context);
        }
      },
      itemBuilder: (context) => [
        if (settings != null) ...[
          const PopupMenuItem(enabled: false, height: 32, child: Text('Thème')),
          for (final MapEntry(key: action, value: (pref, icon, label)) in _themes.entries)
            CheckedPopupMenuItem(
              value: action,
              checked: pref == current,
              child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Flexible(child: Text(label))]),
            ),
        ],
        if (settings != null && onSignOut != null) const PopupMenuDivider(),
        if (onSignOut != null)
          const PopupMenuItem(
            value: _MenuAction.signOut,
            child: Row(
              children: [
                Icon(Icons.restart_alt_rounded, size: 20),
                SizedBox(width: 12),
                Flexible(child: Text('Recommencer l’inscription')),
              ],
            ),
          ),
      ],
    );
  }
}
