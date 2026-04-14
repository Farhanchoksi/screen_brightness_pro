import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screen_brightness_pro_platform_interface.dart';

/// An implementation of [ScreenBrightnessProPlatform] that uses method channels.
class MethodChannelScreenBrightnessPro extends ScreenBrightnessProPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screen_brightness_pro');

  /// The event channel used to listen for brightness changes.
  final eventChannel = const EventChannel('screen_brightness_pro_events');

  @override
  Future<double?> getBrightness() async {
    final brightness = await methodChannel.invokeMethod<double>('getBrightness');
    return brightness;
  }

  @override
  Future<void> setBrightness(double brightness) async {
    await methodChannel.invokeMethod('setBrightness', brightness);
  }

  @override
  Stream<double> get onBrightnessChanged {
    return eventChannel.receiveBroadcastStream().map((event) => event as double);
  }

  @override
  Future<bool> isAutoModeEnabled() async {
    return await methodChannel.invokeMethod<bool>('isAutoModeEnabled') ?? false;
  }

  @override
  Future<void> setAutoMode(bool enabled) async {
    await methodChannel.invokeMethod('setAutoMode', enabled);
  }

  @override
  Future<bool> hasWriteSettingsPermission() async {
    return await methodChannel.invokeMethod<bool>('hasWriteSettingsPermission') ?? false;
  }

  @override
  Future<void> requestWriteSettingsPermission() async {
    await methodChannel.invokeMethod('requestWriteSettingsPermission');
  }

  @override
  Future<void> resetBrightness() async {
    await methodChannel.invokeMethod('resetBrightness');
  }

  @override
  Future<void> setSystemBrightness(double brightness) async {
    await methodChannel.invokeMethod('setSystemBrightness', brightness);
  }

  @override
  Future<void> setKeepScreenOn(bool enabled) async {
    await methodChannel.invokeMethod('setKeepScreenOn', enabled);
  }

  @override
  Future<double> getBatteryLevel() async {
    return await methodChannel.invokeMethod<double>('getBatteryLevel') ?? -1.0;
  }

  @override
  Future<bool> isLowPowerModeEnabled() async {
    return await methodChannel.invokeMethod<bool>('isLowPowerModeEnabled') ?? false;
  }
}
