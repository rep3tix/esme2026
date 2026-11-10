import 'package:esme26/ui/widgets/onboarding/step_intro.dart';
import 'package:flutter/material.dart';

class NameStep extends StatefulWidget {
  final String firstName;
  final String lastName;
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final VoidCallback onNext;

  const NameStep({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onNext,
  });

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StepIntro(
              icon: Icons.badge_outlined,
              title: 'Comment vous appelez-vous ?',
              subtitle: 'Les artisans verront ce nom lors de vos prises de rendez-vous.',
            ),
            TextFormField(
              initialValue: widget.firstName,
              decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person_outline_rounded)),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              onChanged: widget.onFirstNameChanged,
              validator: _requiredName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.lastName,
              decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person_outline_rounded)),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.familyName],
              onChanged: widget.onLastNameChanged,
              onFieldSubmitted: (_) => _submit(),
              validator: _requiredName,
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _submit, child: const Text('Continuer')),
          ],
        ),
      ),
    );
  }

  String? _requiredName(String? value) => value == null || value.trim().isEmpty
      ? 'Ce champ est obligatoire.'
      : null;
}
