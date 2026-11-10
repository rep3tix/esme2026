import 'package:esme26/application/onboarding_controller.dart';
import 'package:esme26/data/repositories/kyc_repository.dart' as data;
import 'package:esme26/domain/repositories/kyc_repository.dart';
import 'package:esme26/ui/widgets/onboarding/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  final KycRepository? kycRepository;

  const OnboardingPage({super.key, this.kycRepository});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingController _controller;
  var _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(kycRepository: widget.kycRepository ?? data.KycRepository.instance);
    _controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (_controller.isCompleted && !_hasNavigated && _controller.role != null) {
      _hasNavigated = true;
      context.go('/homepage', extra: (role: _controller.role, firstName: _controller.firstName));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _controller.isCompleted ? const SizedBox.shrink() : OnboardingView(controller: _controller),
    );
  }
}
