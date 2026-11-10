import 'package:esme26/domain/models/user.dart';
import 'package:esme26/ui/widgets/responsive_body.dart';
import 'package:flutter/material.dart';

/// Contenu de l'accueil. La barre du haut (titre, mode sombre) est
/// fournie par `AppShell`.
class HomePage extends StatelessWidget {
  final UserRole role;
  final String firstName;

  /// Si fourni, un bouton permet d'oublier l'utilisateur et de recommencer.
  final Future<void> Function()? onSignOut;

  const HomePage({super.key, required this.role, required this.firstName, this.onSignOut});

  bool get _isArtisan => role == UserRole.artisan;

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

    return SafeArea(
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
            if (onSignOut != null) ...[
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmSignOut(context),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Recommencer l’inscription'),
                ),
              ),
            ],
          ],
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
