import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/pig_world_icon.dart';

final navigationScaffoldKey = GlobalKey<ScaffoldState>();

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    this.showHerd = true,
    this.showFeed = true,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showHerd;
  final bool showFeed;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    destinations: [
      NavigationDestination(
        icon: const PigWorldIcon('farm'),
        selectedIcon: const PigWorldIcon('farm', size: 26),
        label: AppLocalizations.of(context).home,
      ),
      if (showHerd)
        NavigationDestination(
          icon: const PigWorldIcon('Boar'),
          label: AppLocalizations.of(context).herd,
        ),
      if (showFeed)
        NavigationDestination(
          icon: const PigWorldIcon('Feed stock'),
          label: AppLocalizations.of(context).feed,
        ),
      NavigationDestination(
        icon: const PigWorldIcon('profile'),
        selectedIcon: const PigWorldIcon('profile', size: 26),
        label: AppLocalizations.of(context).profile,
      ),
    ],
  );
}
