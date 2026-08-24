import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/language_card.dart';
import '../widgets/onboarding_header.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  static const languages = [('🇬🇧', 'English', 'English', 'en'), ('🇰🇪', 'Kiswahili', 'Swahili', 'sw'), ('🇫🇷', 'Français', 'French', 'fr'), ('🇩🇪', 'Deutsch', 'German', 'de'), ('🇨🇳', '中文', 'Chinese', 'zh'), ('🇪🇸', 'Español', 'Spanish', 'es')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).language;
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
      const OnboardingHeader(title: 'Choose your language', subtitle: 'You can change this later in Settings.'),
      const SizedBox(height: 24),
      ...languages.map((item) => LanguageCard(
        flag: item.$1,
        nativeName: item.$2,
        translation: item.$3,
        selected: selected == item.$2,
            onTap: () => ref.read(onboardingProvider.notifier).setLanguage(name: item.$2, code: item.$4),
          )),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => context.go(AppRoutes.country), child: const Text('Continue')),
      TextButton(onPressed: () => context.go(AppRoutes.permissions), child: const Text('Back')),
    ])));
  }
}