import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Centralized theme configuration for the app
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Color Scheme
      primarySwatch: MaterialColor(
        0xFFDC2626, // AppColors.primaryRed as int
        <int, Color>{
          50: AppColors.primaryLight,
          100: AppColors.primaryLight,
          200: AppColors.primaryLight,
          300: AppColors.primaryLight,
          400: AppColors.primaryRed,
          500: AppColors.primaryRed,
          600: AppColors.primaryRed,
          700: AppColors.primaryDark,
          800: AppColors.primaryDark,
          900: AppColors.primaryDark,
        },
      ),
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.backgroundGrey,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: AppDimensions.elevationSmall,
          padding: AppSpacing.verticalMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          side: BorderSide(color: AppColors.primaryRed),
          padding: AppSpacing.verticalMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.primaryRed),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.medium,
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: AppSpacing.paddingMedium,
        hintStyle: TextStyle(color: AppColors.textSecondary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: AppDimensions.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.medium,
        ),
        margin: AppSpacing.paddingSmall,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceGrey,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.primaryLight,
        padding: AppSpacing.paddingSmall,
        labelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
        secondaryLabelStyle: TextStyle(
          color: AppColors.primaryRed,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevationLarge,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.paddingMedium,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: AppDimensions.iconMedium,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryRed,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.medium,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.large,
        ),
      ),
    );
  }
}
