import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
	const AppErrorWidget({required this.message, this.onRetry, super.key});

	final String message;
	final VoidCallback? onRetry;

	@override
	Widget build(BuildContext context) => Center(
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					const Icon(Icons.error_outline, color: Colors.red, size: 48),
					Text(message),
					if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry')),
				],
			),
		);
}
