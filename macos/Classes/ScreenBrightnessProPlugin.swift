import Cocoa
import FlutterMacOS
import IOKit

public class ScreenBrightnessProPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "screen_brightness_pro", binaryMessenger: registrar.messenger)
    let instance = ScreenBrightnessProPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBrightness":
      result(getBrightness())
    case "setBrightness":
      if let brightness = call.arguments as? Double {
        setBrightness(brightness: brightness)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Brightness must be a double", details: nil))
      }
    case "isAutoModeEnabled":
      result(false)
    case "setAutoMode":
      result(nil)
    case "hasWriteSettingsPermission":
      result(true)
    case "requestWriteSettingsPermission":
      result(nil)
    case "resetBrightness":
      result(nil)
    case "setSystemBrightness":
      if let brightness = call.arguments as? Double {
        setBrightness(brightness: brightness)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Brightness must be a double", details: nil))
      }
    case "setKeepScreenOn":
      if let enabled = call.arguments as? Bool {
        setKeepScreenOn(enabled: enabled)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Enabled must be a boolean", details: nil))
      }
    case "getBatteryLevel":
      result(getMacOSBatteryLevel())
    case "isLowPowerModeEnabled":
      if #available(macOS 12.0, *) {
        result(ProcessInfo.processInfo.isLowPowerModeEnabled)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getMacOSBatteryLevel() -> Double {
    let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
    let sources = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as [CFTypeRef]
    
    for ps in sources {
      if let desc = IOPSGetPowerSourceDescription(blob, ps).takeUnretainedValue() as? [String: Any] {
        if let level = desc[kIOPSCurrentCapacityKey] as? Double,
           let max = desc[kIOPSMaxCapacityKey] as? Double {
          return level / max
        }
      }
    }
    return -1.0
  }

  private var assertionID: IOPMAssertionID = 0

  private func setKeepScreenOn(enabled: Bool) {
    if enabled {
      if assertionID == 0 {
        IOPMAssertionCreateWithDescription(
          kIOPMAssertionTypeNoDisplaySleep as CFString,
          "ScreenBrightnessPro keeping screen awake" as CFString,
          nil, nil, nil, 0, nil, &assertionID
        )
      }
    } else {
      if assertionID != 0 {
        IOPMAssertionRelease(assertionID)
        assertionID = 0
      }
    }
  }

  private func getBrightness() -> Double {
    var brightness: Float = 0.5
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"))
    if service != 0 {
      var level: Float = 0.0
      IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &level)
      brightness = level
      IOObjectRelease(service)
    }
    return Double(brightness)
  }

  private func setBrightness(brightness: Double) {
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"))
    if service != 0 {
      IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, Float(brightness))
      IOObjectRelease(service)
    }
  }
}
