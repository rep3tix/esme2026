import 'package:esme26/ui/widgets/onboarding/step_intro.dart';
import 'package:flutter/material.dart';

class TradeStep extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const TradeStep({super.key, required this.initialValue, required this.onChanged, required this.onNext});

  @override
  State<TradeStep> createState() => _TradeStepState();
}

class _TradeStepState extends State<TradeStep> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepIntro(
            icon: Icons.construction_rounded,
            title: 'Quel est votre métier ?',
            subtitle: 'Il sera affiché sur votre profil pour que les clients vous trouvent.',
          ),
          TextFormField(
            initialValue: widget.initialValue,
            decoration: const InputDecoration(
              labelText: 'Métier',
              hintText: 'Ex. : menuisier, potier, électricien…',
              prefixIcon: Icon(Icons.work_outline_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: widget.onChanged,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) => value == null || value.trim().isEmpty ? 'Indiquez votre métier.' : null,
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: _submit, child: const Text('Continuer')),
        ],
      ),
    );
  }
}
