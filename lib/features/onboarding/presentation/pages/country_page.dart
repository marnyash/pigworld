import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/country_radio_tile.dart';
import '../widgets/onboarding_header.dart';
import '../../data/country_catalog.dart';

class CountryPage extends ConsumerStatefulWidget {
  const CountryPage({super.key});

  static const countries = ['Kenya', 'Uganda', 'Tanzania', 'Rwanda', 'Burundi', 'Ethiopia', 'South Sudan'];

  @override
  ConsumerState<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends ConsumerState<CountryPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingProvider).country;
    final countries = countryCatalog.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
    if (query.isEmpty) {
      countries.sort((first, second) {
        if (first.name == 'Kenya') return -1;
        if (second.name == 'Kenya') return 1;
        return first.name.compareTo(second.name);
      });
    }
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
      const OnboardingHeader(title: 'Select your country', subtitle: 'This helps us set currency, dates, phone codes, and regional reports.'),
      const SizedBox(height: 24),
      TextField(onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search countries')),
      const SizedBox(height: 16),
      RadioGroup<String>(
        groupValue: selected,
        onChanged: (country) {
          if (country != null) ref.read(onboardingProvider.notifier).setCountry(country);
        },
        child: Column(children: countries.map((country) => CountryRadioTile(country: '${country.flag}  ${country.name}')).toList()),
      ),
    ])),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        TextButton(onPressed: () => context.go(AppRoutes.language), child: const Text('Back')),
        const Spacer(),
        FilledButton(onPressed: selected == null ? null : () => context.go(AppRoutes.accountType), child: const Text('Continue')),
      ]))),
    );
  }
}