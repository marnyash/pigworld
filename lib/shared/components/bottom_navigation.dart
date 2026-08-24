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
				NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Herd'),
				NavigationDestination(icon: Icon(Icons.grass_outlined), label: 'Feed'),
				NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Finance'),
				NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
			],
		);
}
