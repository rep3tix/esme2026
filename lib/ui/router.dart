import 'package:esme26/data/repositories/in_memory_current_user_repository.dart';
import 'package:esme26/domain/models/models.dart';
import 'package:esme26/domain/repositories/current_user_repository.dart';
import 'package:esme26/domain/repositories/kyc_repository.dart';
import 'package:esme26/ui/pages/home_page.dart';
import 'package:esme26/ui/pages/onboarding_page.dart';
import 'package:esme26/ui/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const onboarding = '/';
  static const home = '/homepage';
}

/// [userRepository] : sans valeur, rien n'est conservé entre deux lancements.
GoRouter createRouter({
  required ValueNotifier<bool> darkMode,
  required VoidCallback onToggleDarkMode,
  KycRepository? kycRepository,
  CurrentUserRepository? userRepository,
}) {
  final users = userRepository ?? InMemoryCurrentUserRepository();

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    // Utilisateur déjà enregistré : on saute l'onboarding.
    redirect: (context, state) =>
        state.matchedLocation == AppRoutes.onboarding && users.currentUser != null ? AppRoutes.home : null,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          title: state.uri.path == AppRoutes.home ? 'Accueil' : 'Faisons connaissance',
          darkMode: darkMode,
          onToggleDarkMode: onToggleDarkMode,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.onboarding,
            name: 'onboarding',
            builder: (context, state) => OnboardingPage(kycRepository: kycRepository, userRepository: users),
          ),
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) {
              Future<void> signOut() async {
                await users.clear();
                if (context.mounted) context.go(AppRoutes.onboarding);
              }

              if (state.extra case (role: UserRole role, firstName: String firstName)) {
                return HomePage(role: role, firstName: firstName, onSignOut: signOut);
              }

              if (users.currentUser case final user?) {
                return HomePage(role: user.role, firstName: user.firstName, onSignOut: signOut);
              }

              return HomePage(role: UserRole.customer, firstName: 'John Doe');
            },
          ),
        ],
      ),
    ],
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
