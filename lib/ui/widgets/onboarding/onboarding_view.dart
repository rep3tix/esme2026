import 'package:esme26/application/onboarding_controller.dart';
import 'package:esme26/ui/widgets/onboarding/onboarding_step_view.dart';
import 'package:esme26/ui/widgets/responsive_body.dart';
import 'package:flutter/material.dart';

/// Contenu de l'onboarding. La barre du haut (titre, mode sombre) est
/// fournie par `AppShell`.
class OnboardingView extends StatelessWidget {
  final OnboardingController controller;

  const OnboardingView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: controller.isChoosingRole,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.requestBack();
      },
      child: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              if (controller.isChoosingRole)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Votre profil', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                )
              else
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Retour',
                      onPressed: controller.canGoBack ? controller.requestBack : null,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProgressHeader(step: controller.stepNumber, total: controller.stepCount, progress: controller.progress),
                    ),
                  ],
                ),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: KeyedSubtree(
                  key: ValueKey(controller.step),
                  child: OnboardingStepView(controller: controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int step;
  final int total;
  final double progress;

  const _ProgressHeader({required this.step, required this.total, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Étape $step sur $total', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 6, borderRadius: BorderRadius.circular(3)),
        ),
      ],
    );
  }
}
