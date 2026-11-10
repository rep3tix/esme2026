import 'package:esme26/ui/widgets/onboarding/step_intro.dart';
import 'package:flutter/material.dart';

class KycStep extends StatelessWidget {
  final bool busy;
  final bool rejected;
  final String? error;
  final VoidCallback onVerify;

  const KycStep({
    super.key,
    required this.busy,
    required this.rejected,
    required this.error,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final failed = rejected || error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sans pastille : écran déjà chargé (bandeaux), le bouton doit rester visible.
        const StepIntro(
          title: 'Vérification de votre identité',
          subtitle: 'Dernière étape avant d’accéder à votre espace artisan.',
        ),
        _Banner(
          icon: Icons.science_outlined,
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
          text: 'Mode démonstration : le prestataire KYC est simulé. '
              'Aucun document n’est demandé et aucune vérification réelle '
              'n’est effectuée.',
        ),
        const SizedBox(height: 16),
        if (busy) ...[
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          Text('Vérification simulée en cours…', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
        ],
        if (failed) ...[
          _Banner(
            icon: Icons.error_outline_rounded,
            background: scheme.errorContainer,
            foreground: scheme.onErrorContainer,
            text: rejected ? 'Vérification refusée. Vous pouvez réessayer.' : error!,
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 12),
        FilledButton(onPressed: busy ? null : onVerify, child: Text(failed ? 'Réessayer' : 'Simuler la vérification')),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final String text;

  const _Banner({required this.icon, required this.background, required this.foreground, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: foreground))),
        ],
      ),
    );
  }
}
