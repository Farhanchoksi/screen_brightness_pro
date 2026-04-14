# Screen Brightness Pro

[![pub package](https://img.shields.io/pub/v/screen_brightness_pro.svg)](https://pub.dev/packages/screen_brightness_pro)
[![license](https://img.shields.io/github/license/Farhanchoksi/screen_brightness_pro.svg)](https://opensource.org/licenses/MIT)

A professional, high-performance Flutter plugin for controlling screen brightness, managing native wakelocks, and monitoring battery status across mobile and desktop platforms.

## Why Screen Brightness Pro?

Most existing brightness plugins only support mobile platforms or require separate plugins for wakelock and battery features. **Screen Brightness Pro** is a unified, all-in-one solution designed for production-grade apps.

| Feature | Screen Brightness Pro | Others |
|---------|-----------------------|--------|
| **Multi-Platform** | Android, iOS, macOS, Windows | ❌ Mobile Only |
| **Native Wakelock** | ✅ Integrated | ❌ Requires extra plugin |
| **Battery Awareness**| ✅ Built-in | ❌ Not available |
| **Smooth Transitions**| ✅ Native & Dart support | ❌ Instant only |
| **System Brightness**| ✅ All 4 platforms | ❌ Limited |

## Features

- 📱 **Universal Support**: Android, iOS, macOS, and Windows.
- 💡 **Brightness Control**: Change application-level or system-wide brightness.
- ⚡ **Native Wakelock**: Keep the screen awake during critical tasks without extra dependencies.
- 🔋 **Battery Monitor**: Detect battery level and Low Power Mode to auto-optimize brightness.
- 🌊 **Smooth Transitions**: Gradually change brightness for a premium user experience.
- 🔄 **Auto-Reset**: Clean up brightness overrides when the app is paused or closed.

## Platform Support & Requirements

| Platform | Minimum Version | Specifics |
|----------|-----------------|-----------|
| **Android** | API 21+ | Requires `WRITE_SETTINGS` for system brightness. |
| **iOS** | 12.0+ | No permissions required. |
| **macOS** | 10.11+ | Low Power Mode requires macOS 12.0+. |
| **Windows** | Windows 10+ | Uses Win32 & WMI APIs. |

## Installation

Add `screen_brightness_pro` to your `pubspec.yaml`:

```yaml
dependencies:
  screen_brightness_pro: ^1.0.0
```

### Android Setup
To change **system-wide** brightness (optional), add this to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_SETTINGS" tools:ignore="ProtectedPermissions"/>
```

## Usage

### Simple Brightness Control
```dart
import 'package:screen_brightness_pro/screen_brightness_pro.dart';

// Set brightness to 70%
ScreenBrightnessPro.setBrightness(0.7);

// Set with smooth transition (500ms)
ScreenBrightnessPro.setBrightness(0.7, smooth: true);

// Get current brightness
double current = await ScreenBrightnessPro.getBrightness();
```

### Native Wakelock
```dart
// Keep screen on
ScreenBrightnessPro.setKeepScreenOn(true);

// Allow screen to sleep again
ScreenBrightnessPro.setKeepScreenOn(false);
```

### Battery Aware Optimization
```dart
// Check battery status
double level = await ScreenBrightnessPro.getBatteryLevel();
bool isLowPower = await ScreenBrightnessPro.isLowPowerModeEnabled();

// Manually optimize (will reduce brightness if battery < 20%)
ScreenBrightnessPro.optimizeForLowBattery();
```

### Reset to Default
```dart
// Revert all app-level overrides
ScreenBrightnessPro.resetBrightness();
```

## Contributing & Issues

Found a bug or have a feature request? We'd love to hear from you!

1.  **Check existing issues**: Before opening a new one, please check if someone else has already reported it.
2.  **Report a Bug**: Provide clear reproduction steps, expected vs. actual behavior, and details about your platform (Android/iOS/Desktop).
3.  **Suggest a Feature**: Clearly explain the use case and how it would benefit other developers.

Report issues on the [GitHub Issue Tracker](https://github.com/Farhanchoksi/screen_brightness_pro/issues).

## Maintainer
Maintained by **Farhan Choksi**. Feel free to support the project by giving it a ⭐ on GitHub!

## License
Licensed under the [MIT License](LICENSE).
