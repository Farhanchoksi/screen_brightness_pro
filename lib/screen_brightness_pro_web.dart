import 'dart:async';
import 'dart:js_interop';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;
import 'screen_brightness_pro_platform_interface.dart';

/// The web implementation of the [ScreenBrightnessProPlatform] of the ScreenBrightnessPro plugin.
class ScreenBrightnessProWeb extends ScreenBrightnessProPlatform {
  /// Constructs a [ScreenBrightnessProWeb].
  ScreenBrightnessProWeb();

  /// Registers this class as the default instance of [ScreenBrightnessProPlatform].
  static void registerWith(Registrar registrar) {
    ScreenBrightnessProPlatform.instance = ScreenBrightnessProWeb();
  }

  double _simulatedBrightness = 1.0;
  web.HTMLElement? _dimmerElement;
  web.WakeLockSentinel? _wakeLockSentinel;
  final _brightnessController = StreamController<double>.broadcast();

  void _ensureDimmer() {
    if (_dimmerElement != null) return;
    
    _dimmerElement = web.document.createElement('div') as web.HTMLElement;
    _dimmerElement!.id = 'screen-brightness-pro-dimmer';
    _dimmerElement!.style.position = 'fixed';
    _dimmerElement!.style.top = '0';
    _dimmerElement!.style.left = '0';
    _dimmerElement!.style.width = '100vw';
    _dimmerElement!.style.height = '100vh';
    _dimmerElement!.style.backgroundColor = 'black';
    _dimmerElement!.style.pointerEvents = 'none';
    _dimmerElement!.style.zIndex = '999999';
    _dimmerElement!.style.opacity = '0';
    
    web.document.body?.appendChild(_dimmerElement!);
  }

  @override
  Future<double?> getBrightness() async {
    return _simulatedBrightness;
  }

  @override
  Future<void> setBrightness(double brightness) async {
    _simulatedBrightness = brightness.clamp(0.0, 1.0);
    _ensureDimmer();
    
    // We invert the value because 1.0 brightness = 0.0 opacity (clear)
    // and 0.0 brightness = 1.0 opacity (black)
    // However, 100% black makes the screen unreadable. We cap it at 0.9.
    final opacity = (1.0 - _simulatedBrightness) * 0.9;
    _dimmerElement!.style.opacity = opacity.toString();
    _brightnessController.add(_simulatedBrightness);
  }

  @override
  Stream<double> get onBrightnessChanged => _brightnessController.stream;

  @override
  Future<void> setKeepScreenOn(bool enabled) async {
    if (enabled) {
      try {
        // Use .toDart to convert JSPromise to Future
        final promise = web.window.navigator.wakeLock.request('screen');
        _wakeLockSentinel = await promise.toDart;
      } catch (e) {
        web.console.warn('WakeLock not supported or failed: $e'.toJS);
      }
    } else {
      if (_wakeLockSentinel != null) {
        await _wakeLockSentinel!.release().toDart;
        _wakeLockSentinel = null;
      }
    }
  }

  @override
  Future<double> getBatteryLevel() async {
    try {
      final battery = await web.window.navigator.getBattery().toDart;
      return battery.level.toDouble();
    } catch (e) {
      return -1.0;
    }
  }

  @override
  Future<bool> isLowPowerModeEnabled() async {
    // Browsers don't generally expose low power mode status.
    return false;
  }

  @override
  Future<void> resetBrightness() async {
    await setBrightness(1.0);
  }

  @override
  Future<void> setSystemBrightness(double brightness) async {
    // Web cannot change system brightness. We fallback to simulated brightness.
    await setBrightness(brightness);
  }

  @override
  Future<bool> isAutoModeEnabled() async => false;

  @override
  Future<void> setAutoMode(bool enabled) async {}

  @override
  Future<bool> hasWriteSettingsPermission() async => true;

  @override
  Future<void> requestWriteSettingsPermission() async {}
}

extension on String {
  web.JSString get toJS => web.JSString(this);
}
