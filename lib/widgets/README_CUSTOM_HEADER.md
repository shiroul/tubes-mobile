# Custom App Header Widget

A reusable header component for consistent navigation across the LINA app.

## Usage

Import the widget:
```dart
import '../widgets/custom_app_header.dart';
```

Replace your existing AppBar with CustomAppHeader:

```dart
Scaffold(
  appBar: CustomAppHeader(
    title: 'Your Screen Title',
    showLogo: true,           // Show LINA logo on left
    showProfileIcon: true,    // Show profile icon on right
  ),
  body: YourContent(),
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | required | The title text to display |
| `showLogo` | `bool` | `false` | Whether to show the LINA logo on the left |
| `showProfileIcon` | `bool` | `true` | Whether to show the profile icon on the right |
| `onProfileTap` | `VoidCallback?` | `null` | Custom callback for profile icon tap |
| `actions` | `List<Widget>?` | `null` | Custom action widgets (overrides profile icon) |

## Examples

### Dashboard Header (Logo + Title + Profile)
```dart
CustomAppHeader(
  title: 'Dashboard',
  showLogo: true,
  showProfileIcon: true,
)
```

### Profile Page Header (Logo + Title, No Profile Icon)
```dart
CustomAppHeader(
  title: 'Profil',
  showLogo: true,
  showProfileIcon: false,
)
```

### Simple Header (Title Only)
```dart
CustomAppHeader(
  title: 'Events',
  showLogo: false,
  showProfileIcon: true,
)
```

### Custom Actions Header
```dart
CustomAppHeader(
  title: 'Settings',
  showLogo: true,
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => openSettings(),
    ),
    IconButton(
      icon: Icon(Icons.logout),
      onPressed: () => logout(),
    ),
  ],
)
```

## Visual Layout

```
┌─────────────────────────────────────────────────┐
│ [Logo] Title                    [Profile Icon] │
└─────────────────────────────────────────────────┘
```

- **Logo**: LINA heart logo (32x32px) with fallback icon
- **Title**: Screen title in bold black text
- **Profile Icon**: Circular grey avatar that navigates to profile

## Styling

- **Background**: White (`Colors.white`)
- **Elevation**: 0 (flat design)
- **Height**: Standard toolbar height (`kToolbarHeight`)
- **Text Color**: Black for title
- **Logo**: Rounded corners (8px radius)

## Implementation Status

✅ **Dashboard Screen** - Logo + Title + Profile Icon  
✅ **Profile Screen** - Logo + Title (no profile icon)  
🔄 **Other Screens** - Can be updated to use this component

## Benefits

1. **Consistency**: Same header style across all screens
2. **Reusability**: Single component for all header needs
3. **Flexibility**: Configurable logo, title, and actions
4. **Maintainability**: Easy to update styling in one place
5. **Accessibility**: Proper navigation and icon handling
