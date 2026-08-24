import 'package:flutter/material.dart';

class HerdPage extends StatelessWidget {
	const HerdPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Herd')),
			body: const Center(child: Text('Herd management will be available in Phase 3.')),
		);
	}
}
