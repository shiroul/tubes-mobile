import 'package:flutter/material.dart';

/// Consistent spacing and sizing constants for the app
class AppDimensions {
  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Margin
  static const double marginXSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 50.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;

  // Card Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // App Bar
  static const double appBarHeight = 56.0;

  // Bottom Navigation
  static const double bottomNavHeight = 60.0;

  // Common Widget Sizes
  static const double chipHeight = 32.0;
  static const double badgeSize = 20.0;
  static const double dividerThickness = 1.0;
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // Screen Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
}

/// Common EdgeInsets for consistent spacing
class AppSpacing {
  static const EdgeInsets zero = EdgeInsets.zero;
  
  // Symmetric Padding
  static const EdgeInsets paddingXSmall = EdgeInsets.all(AppDimensions.paddingXSmall);
  static const EdgeInsets paddingSmall = EdgeInsets.all(AppDimensions.paddingSmall);
  static const EdgeInsets paddingMedium = EdgeInsets.all(AppDimensions.paddingMedium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(AppDimensions.paddingLarge);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(AppDimensions.paddingXLarge);

  // Horizontal Padding
  static const EdgeInsets horizontalXSmall = EdgeInsets.symmetric(horizontal: AppDimensions.paddingXSmall);
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge);
  static const EdgeInsets horizontalXLarge = EdgeInsets.symmetric(horizontal: AppDimensions.paddingXLarge);

  // Vertical Padding
  static const EdgeInsets verticalXSmall = EdgeInsets.symmetric(vertical: AppDimensions.paddingXSmall);
  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge);
  static const EdgeInsets verticalXLarge = EdgeInsets.symmetric(vertical: AppDimensions.paddingXLarge);

  // Page Padding
  static const EdgeInsets page = EdgeInsets.all(20.0);
  static const EdgeInsets card = EdgeInsets.all(16.0);
  static const EdgeInsets listItem = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
}

/// Common BorderRadius configurations
class AppBorderRadius {
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius small = BorderRadius.all(Radius.circular(AppDimensions.radiusSmall));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(AppDimensions.radiusMedium));
  static const BorderRadius large = BorderRadius.all(Radius.circular(AppDimensions.radiusLarge));
  static const BorderRadius xLarge = BorderRadius.all(Radius.circular(AppDimensions.radiusXLarge));
  static const BorderRadius circular = BorderRadius.all(Radius.circular(AppDimensions.radiusCircular));

  // Top Only
  static const BorderRadius topSmall = BorderRadius.only(
    topLeft: Radius.circular(AppDimensions.radiusSmall),
    topRight: Radius.circular(AppDimensions.radiusSmall),
  );
  static const BorderRadius topMedium = BorderRadius.only(
    topLeft: Radius.circular(AppDimensions.radiusMedium),
    topRight: Radius.circular(AppDimensions.radiusMedium),
  );
  static const BorderRadius topLarge = BorderRadius.only(
    topLeft: Radius.circular(AppDimensions.radiusLarge),
    topRight: Radius.circular(AppDimensions.radiusLarge),
  );
}
