import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/language_card.dart';
import '../widgets/onboarding_header.dart';
import '../../data/language_catalog.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  static const languages = [('🇬🇧', 'English', 'English', 'en'), ('🇰🇪', 'Kiswahili', 'Swahili', 'sw'), ('🇫🇷', 'Français', 'French', 'fr'), ('🇩🇪', 'Deutsch', 'German', 'de'), ('🇨🇳', '中文', 'Chinese', 'zh'), ('🇪🇸', 'Español', 'Spanish', 'es')];

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingProvider).language;
    final languages = languageCatalog.where((item) => '${item.name} ${item.nativeName}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
      const OnboardingHeader(title: 'Choose your language', subtitle: 'You can change this later in Settings.'),
      const SizedBox(height: 24),
      TextField(onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search languages')),
      const SizedBox(height: 16),
      ...languages.map((item) => LanguageCard(
        flag: item.flag,
        nativeName: item.nativeName,
        translation: item.name,
        selected: selected == item.name,
        onTap: () => ref.read(onboardingProvider.notifier).setLanguage(name: item.name, code: item.code),
          )),
    ])),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        TextButton(onPressed: () => context.go(AppRoutes.permissions), child: const Text('Back')),
        const Spacer(),
        FilledButton(onPressed: () => context.go(AppRoutes.country), child: const Text('Continue')),
      ]))),
    );
  }
}