import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/country_radio_tile.dart';
import '../widgets/onboarding_header.dart';

class CountryPage extends ConsumerWidget {
  const CountryPage({super.key});

  static const countries = ['Kenya', 'Uganda', 'Tanzania', 'Rwanda', 'Burundi', 'Ethiopia', 'South Sudan'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).country;
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
      const OnboardingHeader(title: 'Select your country', subtitle: 'This helps us set currency, dates, phone codes, and regional reports.'),
      const SizedBox(height: 24),
      RadioGroup<String>(
        groupValue: selected,
        onChanged: (country) {
          if (country != null) ref.read(onboardingProvider.notifier).setCountry(country);
        },
        child: Column(children: countries.map((country) => CountryRadioTile(country: country)).toList()),
      ),
      const SizedBox(height: 16),
      FilledButton(onPressed: selected == null ? null : () => context.go(AppRoutes.login), child: const Text('Continue')),
      TextButton(onPressed: () => context.go(AppRoutes.language), child: const Text('Back')),
    ])));
  }
}