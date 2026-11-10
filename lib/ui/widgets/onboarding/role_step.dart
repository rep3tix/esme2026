import 'package:esme26/domain/models/user.dart';
import 'package:flutter/material.dart';

class RoleStep extends StatelessWidget {
  final ValueChanged<UserRole> onSelected;

  const RoleStep({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Bienvenue !', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Comment souhaitez-vous utiliser notre application ?',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        _RoleCard(
          icon: Icons.handyman_outlined,
          title: 'Je suis artisan',
          description: 'Faites découvrir votre métier et votre savoir-faire.',
          onTap: () => onSelected(UserRole.artisan),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.home_outlined,
          title: 'Je suis particulier',
          description: 'Trouvez des artisans pour donner vie à vos projets.',
          onTap: () => onSelected(UserRole.customer),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.title, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 3,
      shadowColor: scheme.shadow.withValues(alpha: 0.25),
      color: scheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, size: 28, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
