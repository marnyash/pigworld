import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/language_card.dart';
import '../widgets/onboarding_header.dart';
import '../../data/language_catalog.dart';
import '../widgets/onboarding_scaffold.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  static const languages = [
    ('🇬🇧', 'English', 'English', 'en'),
    ('🇰🇪', 'Kiswahili', 'Swahili', 'sw'),
    ('🇫🇷', 'Français', 'French', 'fr'),
    ('🇩🇪', 'Deutsch', 'German', 'de'),
    ('🇨🇳', '中文', 'Chinese', 'zh'),
    ('🇪🇸', 'Español', 'Spanish', 'es'),
  ];

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingProvider).language;
    final languages = languageCatalog
        .where(
          (item) => '${item.name} ${item.nativeName}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return OnboardingScaffold(
      body: OnboardingEntry(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          children: [
            const OnboardingHeader(
              eyebrow: 'Step 1 of 4',
              title: 'Choose your language',
              subtitle:
                  'Pick the language that feels most natural. You can change it later.',
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search languages',
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LanguageCard(
                  flag: item.code.toUpperCase(),
                  nativeName: item.nativeName,
                  translation: item.name,
                  selected: selected == item.name,
                  onTap: () => ref
                      .read(onboardingProvider.notifier)
                      .setLanguage(name: item.name, code: item.code),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: Row(
        children: [
          TextButton(
            onPressed: () => context.go(AppRoutes.permissions),
            child: const Text('Back'),
          ),
          const Spacer(),
          Flexible(
            child: FilledButton(
              onPressed: () {
                final isMobile =
                    !kIsWeb &&
                    (defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS);
                if (isMobile) unawaited(_requestRuntimePermissions());
                context.go(AppRoutes.country);
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestRuntimePermissions() async {
    try {
      await [Permission.notification, Permission.location].request();
    } on Exception {
      // A denied or unavailable permission must not block onboarding.
    }
  }
}
