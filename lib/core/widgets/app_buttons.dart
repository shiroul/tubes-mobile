import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Common button styles used throughout the app
class AppButtons {
  /// Primary elevated button
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = AppDimensions.buttonHeightMedium,
  }) {
    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Text('Memproses...'),
        ],
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: AppDimensions.paddingSmall),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
          elevation: AppDimensions.elevationSmall,
        ),
        child: buttonChild,
      ),
    );
  }

  /// Secondary outlined button
  static Widget secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = AppDimensions.buttonHeightMedium,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.primaryRed;
    
    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: buttonColor,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Text('Memproses...'),
        ],
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: AppDimensions.paddingSmall),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
        ),
        child: buttonChild,
      ),
    );
  }

  /// Success button (green)
  static Widget success({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = AppDimensions.buttonHeightMedium,
  }) {
    return primary(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      width: width,
      height: height,
    );
  }

  /// Danger button (red)
  static Widget danger({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = AppDimensions.buttonHeightMedium,
  }) {
    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Text('Memproses...'),
        ],
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: AppDimensions.paddingSmall),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
          elevation: AppDimensions.elevationSmall,
        ),
        child: buttonChild,
      ),
    );
  }

  /// Text button
  static Widget text({
    required String text,
    required VoidCallback? onPressed,
    Color? color,
    IconData? icon,
  }) {
    final buttonColor = color ?? AppColors.primaryRed;
    
    Widget buttonChild;
    
    if (icon != null) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSmall),
          SizedBox(width: AppDimensions.paddingSmall),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
      ),
      child: buttonChild,
    );
  }
}
