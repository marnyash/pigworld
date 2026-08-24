import 'package:flutter/material.dart';

abstract final class AppTypography {
	static const textTheme = TextTheme(
		displaySmall: TextStyle(fontWeight: FontWeight.w700),
		headlineMedium: TextStyle(fontWeight: FontWeight.w700),
		titleLarge: TextStyle(fontWeight: FontWeight.w700),
		titleMedium: TextStyle(fontWeight: FontWeight.w600),
		bodyLarge: TextStyle(height: 1.4),
		bodyMedium: TextStyle(height: 1.35),
	);
}
