import Flutter
import UIKit

public class ScreenBrightnessProPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "screen_brightness_pro", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "screen_brightness_pro_events", binaryMessenger: registrar.messenger())
    
    let instance = ScreenBrightnessProPlugin()
    
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBrightness":
      result(UIScreen.main.brightness)
    case "setBrightness":
      if let brightness = call.arguments as? Double {
        UIScreen.main.brightness = CGFloat(brightness)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Brightness must be a double", details: nil))
      }
    case "isAutoModeEnabled":
      result(false)
    case "setAutoMode":
      result(nil) // Unsupported on iOS
    case "hasWriteSettingsPermission":
      result(true) // Not required on iOS
    case "requestWriteSettingsPermission":
      result(nil)
    case "resetBrightness":
      result(nil) // No-op on iOS
    case "setSystemBrightness":
      if let brightness = call.arguments as? Double {
        UIScreen.main.brightness = CGFloat(brightness)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Brightness must be a double", details: nil))
      }
    case "setKeepScreenOn":
      if let enabled = call.arguments as? Bool {
        UIApplication.shared.isIdleTimerDisabled = enabled
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Enabled must be a boolean", details: nil))
      }
    case "getBatteryLevel":
      UIDevice.current.isBatteryMonitoringEnabled = true
      result(Double(UIDevice.current.batteryLevel))
    case "isLowPowerModeEnabled":
      result(ProcessInfo.processInfo.isLowPowerModeEnabled)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    NotificationCenter.default.addObserver(self, selector: #selector(brightnessDidChange), name: UIScreen.brightnessDidChangeNotification, object: nil)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    self.eventSink = nil
    return nil
  }

  @objc private func brightnessDidChange() {
    eventSink?(UIScreen.main.brightness)
  }
}
