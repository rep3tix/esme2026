import 'package:esme26/ui/widgets/onboarding/step_intro.dart';
import 'package:flutter/material.dart';

class InterestsStep extends StatelessWidget {
  static const options = [
    'Bois et menuiserie',
    'Poterie et céramique',
    'Textile et couture',
    'Bijouterie',
    'Décoration',
    'Rénovation',
  ];

  static const _icons = <String, IconData>{
    'Bois et menuiserie': Icons.carpenter_outlined,
    'Poterie et céramique': Icons.local_florist_outlined,
    'Textile et couture': Icons.checkroom_outlined,
    'Bijouterie': Icons.diamond_outlined,
    'Décoration': Icons.chair_outlined,
    'Rénovation': Icons.format_paint_outlined,
  };

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  const InterestsStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro(
          icon: Icons.interests_outlined,
          title: 'Qu’est-ce qui vous intéresse ?',
          subtitle: 'Choisissez au moins un centre d’intérêt artisanal.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final option in options)
              FilterChip(
                avatar: selected.contains(option) ? null : Icon(_icons[option], size: 18),
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (_) => onToggle(option),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          selected.isEmpty ? 'Aucune sélection' : '${selected.length} sélectionné${selected.length > 1 ? 's' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton(onPressed: selected.isEmpty ? null : onNext, child: const Text('Continuer')),
      ],
    );
  }
}
