import 'package:flutter/material.dart';

final navigationScaffoldKey = GlobalKey<ScaffoldState>();

class AppBottomNavigation extends StatelessWidget {
	const AppBottomNavigation({required this.selectedIndex, required this.onSelected, super.key});

	final int selectedIndex;
	final ValueChanged<int> onSelected;

	@override
	Widget build(BuildContext context) => NavigationBar(
			selectedIndex: selectedIndex,
			onDestinationSelected: onSelected,
			destinations: const [
				NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
				NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Herd'),
				NavigationDestination(icon: Icon(Icons.grass_outlined), label: 'Feed'),
				NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
			],
		);
}
