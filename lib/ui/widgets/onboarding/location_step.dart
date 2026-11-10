import 'package:esme26/ui/widgets/onboarding/step_intro.dart';
import 'package:flutter/material.dart';

class LocationStep extends StatefulWidget {
  final String city;
  final String postalCode;
  final String country;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onPostalCodeChanged;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onNext;

  const LocationStep({
    super.key,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.onCityChanged,
    required this.onPostalCodeChanged,
    required this.onCountryChanged,
    required this.onNext,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
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
              icon: Icons.location_on_outlined,
              title: 'Où êtes-vous situé ?',
              subtitle: 'Renseignez votre localisation pour découvrir les artisans et projets près de chez vous.',
            ),
            TextFormField(
              initialValue: widget.city,
              decoration: const InputDecoration(labelText: 'Ville', prefixIcon: Icon(Icons.location_city_outlined)),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.addressCity],
              onChanged: widget.onCityChanged,
              validator: _requiredLocation,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.postalCode,
              decoration: const InputDecoration(labelText: 'Code postal', prefixIcon: Icon(Icons.markunread_mailbox_outlined)),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.postalCode],
              onChanged: widget.onPostalCodeChanged,
              validator: _requiredLocation,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.country,
              decoration: const InputDecoration(labelText: 'Pays', prefixIcon: Icon(Icons.public_rounded)),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.countryName],
              onChanged: widget.onCountryChanged,
              onFieldSubmitted: (_) => _submit(),
              validator: _requiredLocation,
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _submit, child: const Text('Continuer')),
          ],
        ),
      ),
    );
  }

  String? _requiredLocation(String? value) =>
      value == null || value.trim().isEmpty
      ? 'Ce champ est obligatoire.'
      : null;
}
