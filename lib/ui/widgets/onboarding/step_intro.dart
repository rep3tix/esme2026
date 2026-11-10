import 'package:flutter/material.dart';

/// En-tête commun à chaque étape : pastille d'icône, titre et sous-titre.
class StepIntro extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;

  const StepIntro({super.key, this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 28, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
        ],
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
        ],
        const SizedBox(height: 28),
      ],
    );
  }
}
