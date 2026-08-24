import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
	const AppBottomNavigation({required this.selectedIndex, required this.onSelected, super.key});

	final int selectedIndex;
	final ValueChanged<int> onSelected;

	@override
	Widget build(BuildContext context) => NavigationBar(
			selectedIndex: selectedIndex,
			onDestinationSelected: onSelected,
			destinations: const [
				NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
				NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Herd'),
				NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Breeding'),
			],
		);
}
