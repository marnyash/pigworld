import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

class AppTutorialPage extends StatefulWidget {
  const AppTutorialPage({super.key});

  @override
  State<AppTutorialPage> createState() => _AppTutorialPageState();
}

class _AppTutorialPageState extends State<AppTutorialPage> {
  static const _missions = [
    _TutorialMission(
      title: 'Build your herd',
      subtitle: 'Your farm adventure starts with your pigs.',
      description:
          'Add each pig once, then keep its tag, age, weight, and details together in your digital herd.',
      icon: Icons.pets_outlined,
      reward: 'HERD KEEPER',
      color: AppColors.primaryGreen,
      background: AppColors.primaryContainer,
    ),
    _TutorialMission(
      title: 'Keep every pig healthy',
      subtitle: 'Small check-ins make a big difference.',
      description:
          'Log treatments, medication, vaccinations, and checkups to build a health timeline for every animal.',
      icon: Icons.health_and_safety_outlined,
      reward: 'CARE CHAMPION',
      color: AppColors.pigPink,
      background: AppColors.secondaryContainer,
    ),
    _TutorialMission(
      title: 'Make daily care a routine',
      subtitle: 'Turn good habits into easy wins.',
      description:
          'Plan feeding, breeding, and farm tasks, then check them off as your team gets the work done.',
      icon: Icons.task_alt_outlined,
      reward: 'ROUTINE BUILDER',
      color: AppColors.aqua,
      background: AppColors.infoContainer,
    ),
    _TutorialMission(
      title: 'Watch your farm grow',
      subtitle: 'See the progress behind your hard work.',
      description:
          'Follow sales, expenses, and reports in one place. Your dashboard turns farm records into a clearer picture.',
      icon: Icons.trending_up_rounded,
      reward: 'SMART FARMER',
      color: AppColors.warmGold,
      background: AppColors.warningContainer,
    ),
  ];

  int _currentMission = 0;

  void _continue() {
    if (_currentMission == _missions.length - 1) {
      context.go(AppRoutes.language);
      return;
    }
    setState(() => _currentMission++);
  }

  @override
  Widget build(BuildContext context) {
    final mission = _missions[_currentMission];
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spacingSmall,
                AppDimensions.pagePadding,
                0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_esports_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: AppDimensions.spacingSmall),
                  Text(
                    'YOUR FARM QUEST',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.language),
                    child: const Text('Skip tour'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                child: _MissionCard(
                  key: ValueKey(_currentMission),
                  mission: mission,
                  index: _currentMission,
                  total: _missions.length,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spacingSmall,
                AppDimensions.pagePadding,
                AppDimensions.spacingLarge,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _missions.length,
                      (index) => AnimatedContainer(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        width: index == _currentMission ? 28 : 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentMission
                              ? AppColors.primaryGreen
                              : AppColors.outline,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _continue,
                      icon: Icon(
                        _currentMission == _missions.length - 1
                            ? Icons.rocket_launch_outlined
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _currentMission == _missions.length - 1
                            ? 'Start your journey'
                            : 'Next mission',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.index,
    required this.total,
    super.key,
  });

  final _TutorialMission mission;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.spacingSmall,
        AppDimensions.pagePadding,
        AppDimensions.spacingSmall,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 19,
                    color: AppColors.warmGold,
                  ),
                  const SizedBox(width: AppDimensions.spacingSmall),
                  Text(
                    'MISSION ${index + 1} OF $total',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.stars_rounded, color: AppColors.warmGold),
                  const SizedBox(width: 4),
                  Text(
                    '+${(index + 1) * 25} TOUR XP',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (index + 1) / total,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceMuted,
                  color: AppColors.leaf,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepGreen.withValues(alpha: 0.09),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            mission.background,
                            mission.background.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                      child: Icon(mission.icon, size: 70, color: mission.color),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Text(
                      mission.title,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    Text(
                      mission.subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.titleSmall?.copyWith(
                        color: mission.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    Text(
                      mission.description,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: mission.background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 18,
                            color: mission.color,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'TOUR BADGE  ·  ${mission.reward}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              Text(
                'Complete the tour at your own pace. You can explore every feature after setup.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialMission {
  const _TutorialMission({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.reward,
    required this.color,
    required this.background,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String reward;
  final Color color;
  final Color background;
}
