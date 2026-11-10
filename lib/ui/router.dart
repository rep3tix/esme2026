import 'package:esme26/ui/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const onboarding = '/';
}

/// Le passage onboarding -> accueil reste géré par [OnboardingPage]
/// (elle observe le contrôleur). Les futures routes (recherche d'artisans,
/// rendez-vous, profil…) viendront s'ajouter ici.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [GoRoute(path: AppRoutes.onboarding, name: 'onboarding', builder: (context, state) => const OnboardingPage())],
    errorBuilder: (context, state) => _NotFoundPage(location: state.uri.path),
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_off_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Page introuvable', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(location, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => context.go(AppRoutes.onboarding), child: const Text("Retour à l'accueil")),
            ],
          ),
        ),
      ),
    );
  }
}
