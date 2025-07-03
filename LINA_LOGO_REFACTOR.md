# LinaLogo Widget Documentation

## Overview
The `LinaLogo` widget is a reusable component that displays the LINA brand logo with configurable styling options. It replaces the hardcoded logo containers throughout the app with a consistent, customizable widget.

## Usage

### Basic Usage
```dart
import '../widgets/lina_logo.dart';

LinaLogo()
```

### Customized Usage
```dart
LinaLogo(
  fontSize: 18,
  subtitleFontSize: 8,
  titleColor: Colors.blue[800],
  subtitleColor: Colors.grey[600],
  padding: EdgeInsets.symmetric(vertical: 4),
  showSubtitle: true,
  showHeart: true,
  heartSize: 24,
  letterSpacing: 1.0,
  crossAxisAlignment: CrossAxisAlignment.center,
)
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `fontSize` | `double?` | `24` | Font size for "LINA" text |
| `subtitleFontSize` | `double?` | `12` | Font size for "PEDULI BENCANA" text |
| `titleColor` | `Color?` | `Colors.blue[800]` | Color for "LINA" text |
| `subtitleColor` | `Color?` | `Colors.grey[600]` | Color for "PEDULI BENCANA" text |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.symmetric(vertical: 16)` | Padding around the logo |
| `mainAxisAlignment` | `MainAxisAlignment` | `MainAxisAlignment.center` | Vertical alignment of logo elements |
| `crossAxisAlignment` | `CrossAxisAlignment` | `CrossAxisAlignment.center` | Horizontal alignment of logo elements |
| `showSubtitle` | `bool` | `true` | Whether to show "PEDULI BENCANA" subtitle |
| `showHeart` | `bool` | `true` | Whether to show the heart logo image |
| `heartSize` | `double?` | `fontSize * 1.2` | Size of the heart logo (auto-calculated if not provided) |
| `letterSpacing` | `double?` | `1.5` | Letter spacing for subtitle text |

## Implementation Examples

### Dashboard Content (Large Logo)
```dart
LinaLogo(
  fontSize: 24,
  subtitleFontSize: 12,
  padding: EdgeInsets.symmetric(vertical: 16),
  showHeart: true,
  heartSize: 32,
)
```

### Header Logo (Compact)
```dart
LinaLogo(
  fontSize: 18,
  subtitleFontSize: 8,
  padding: EdgeInsets.symmetric(vertical: 4),
  showSubtitle: true,
  showHeart: true,
  heartSize: 24,
  letterSpacing: 1.0,
  crossAxisAlignment: CrossAxisAlignment.center,
)
```

### Title Only (No Heart, No Subtitle)
```dart
LinaLogo(
  fontSize: 20,
  showSubtitle: false,
  showHeart: false,
  padding: EdgeInsets.zero,
)
```

## Integration

### Dashboard Screen
The dashboard now uses `showLogo: true` in the `CustomAppHeader` to display the logo in the header instead of in the content area.

### Custom App Header
The `CustomAppHeader` widget now uses `LinaLogo` when `showLogo: true`, providing a compact header-appropriate version of the brand logo.

## Benefits

1. **Consistency**: Single source of truth for LINA branding
2. **Reusability**: Can be used in headers, splash screens, footers, etc.
3. **Customizable**: Flexible styling options for different contexts
4. **Maintainable**: Easy to update branding across the entire app

## Migration

### Before (Hardcoded)
```dart
Container(
  padding: EdgeInsets.symmetric(vertical: 16),
  child: Column(
    children: [
      // Heart logo image
      Container(
        width: 32,
        height: 32,
        child: Image.asset('lib/src/heart.png'),
      ),
      SizedBox(height: 8),
      Text(
        'LINA',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
      Text(
        'PEDULI BENCANA',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          letterSpacing: 1.5,
        ),
      ),
    ],
  ),
)
```

### After (Reusable Widget)
```dart
LinaLogo()
```

## Files Modified

1. `lib/widgets/lina_logo.dart` - New reusable logo widget
2. `lib/widgets/custom_app_header.dart` - Updated to use LinaLogo for header branding
3. `lib/screens/dashboard_screen.dart` - Updated to show logo in header instead of content

## Result

The LINA app now has a consistent, reusable logo component that can be easily customized for different contexts while maintaining brand consistency across the application.
