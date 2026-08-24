import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

abstract final class AppTheme {
	static ThemeData get light => ThemeData(
				useMaterial3: true,
				scaffoldBackgroundColor: AppColors.background,
				colorScheme: ColorScheme.fromSeed(
					seedColor: AppColors.primaryGreen,
					primary: AppColors.primaryGreen,
					secondary: AppColors.pigPink,
					error: AppColors.danger,
				),
				textTheme: AppTypography.textTheme.apply(bodyColor: AppColors.text),
				appBarTheme: const AppBarTheme(
					centerTitle: false,
					elevation: 0,
					backgroundColor: AppColors.background,
					foregroundColor: AppColors.text,
				),
				cardTheme: CardThemeData(
					elevation: 0,
					margin: EdgeInsets.zero,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(AppDimensions.radius),
					),
				),
				inputDecorationTheme: InputDecorationTheme(
					filled: true,
					fillColor: Colors.white,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(AppDimensions.radius),
						borderSide: BorderSide.none,
					),
				),
				elevatedButtonTheme: ElevatedButtonThemeData(
					style: ElevatedButton.styleFrom(
						minimumSize: const Size.fromHeight(AppDimensions.controlHeight),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(AppDimensions.radius),
						),
					),
				),
			);

	static ThemeData get dark => ThemeData.dark(useMaterial3: true).copyWith(
			colorScheme: ColorScheme.fromSeed(
				seedColor: AppColors.primaryGreen,
				brightness: Brightness.dark,
			),
			textTheme: AppTypography.textTheme,
		);
}
