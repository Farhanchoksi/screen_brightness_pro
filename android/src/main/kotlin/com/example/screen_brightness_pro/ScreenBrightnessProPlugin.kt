package com.example.screen_brightness_pro

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.BatteryManager
import android.os.Build

/** ScreenBrightnessProPlugin */
class ScreenBrightnessProPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private var activity: Activity? = null
  private var context: Context? = null
  private var eventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "screen_brightness_pro")
    channel.setMethodCallHandler(this)
    
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "screen_brightness_pro_events")
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getBrightness" -> {
        val brightness = activity?.window?.attributes?.screenBrightness ?: -1f
        if (brightness < 0) {
          try {
            val systemBrightness = Settings.System.getInt(context?.contentResolver, Settings.System.SCREEN_BRIGHTNESS)
            result.success(systemBrightness / 255.0)
          } catch (e: Exception) {
            result.error("ERROR", "Could not get brightness", null)
          }
        } else {
          result.success(brightness.toDouble())
        }
      }
      "setBrightness" -> {
        val brightness = call.arguments as? Double
        if (brightness != null) {
          activity?.let { act ->
            val layoutParams = act.window.attributes
            layoutParams.screenBrightness = brightness.toFloat()
            act.window.attributes = layoutParams
            result.success(null)
          } ?: result.error("NO_ACTIVITY", "Activity is null", null)
        } else {
          result.error("INVALID_ARGUMENT", "Brightness must be a double", null)
        }
      }
      "isAutoModeEnabled" -> {
        try {
          val mode = Settings.System.getInt(context?.contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE)
          result.success(mode == Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC)
        } catch (e: Exception) {
          result.success(false)
        }
      }
      "setAutoMode" -> {
        val enabled = call.arguments as? Boolean ?: false
        val mode = if (enabled) Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC else Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
        try {
          if (Settings.System.canWrite(context)) {
            Settings.System.putInt(context?.contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, mode)
            result.success(null)
          } else {
            result.error("PERMISSION_DENIED", "WRITE_SETTINGS permission not granted", null)
          }
        } catch (e: Exception) {
          result.error("ERROR", e.message, null)
        }
      }
      "hasWriteSettingsPermission" -> {
        result.success(Settings.System.canWrite(context))
      }
      "requestWriteSettingsPermission" -> {
        val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
        intent.data = Uri.parse("package:" + (context?.packageName ?: ""))
        
        val startContext = activity ?: context
        if (activity == null) {
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        
        try {
          startContext?.startActivity(intent)
          result.success(null)
        } catch (e: Exception) {
          result.error("ERROR", "Could not open settings: ${e.message}", null)
        }
      }
      "resetBrightness" -> {
        activity?.let { act ->
          val layoutParams = act.window.attributes
          layoutParams.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
          act.window.attributes = layoutParams
          result.success(null)
        } ?: result.error("NO_ACTIVITY", "Activity is null", null)
      }
      "setSystemBrightness" -> {
        val brightness = (call.arguments as? Double ?: -1.0)
        if (brightness in 0.0..1.0) {
          try {
            if (Settings.System.canWrite(context)) {
              Settings.System.putInt(context?.contentResolver, Settings.System.SCREEN_BRIGHTNESS, (brightness * 255).toInt())
              result.success(null)
            } else {
              result.error("PERMISSION_DENIED", "WRITE_SETTINGS permission not granted", null)
            }
          } catch (e: Exception) {
            result.error("ERROR", e.message, null)
          }
        } else {
          result.error("INVALID_ARGUMENT", "Brightness must be between 0.0 and 1.0", null)
        }
      }
      "setKeepScreenOn" -> {
        val enabled = call.arguments as? Boolean ?: false
        activity?.let { act ->
          if (enabled) {
            act.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
          } else {
            act.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
          }
          result.success(null)
        } ?: result.error("NO_ACTIVITY", "Activity is null", null)
      }
      "getBatteryLevel" -> {
        val bm = context?.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
        if (bm != null) {
          val level = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
          result.success(level / 100.0)
        } else {
          result.success(-1.0)
        }
      }
      "isLowPowerModeEnabled" -> {
        val pm = context?.getSystemService(Context.POWER_SERVICE) as? PowerManager
        result.success(pm?.isPowerSaveMode ?: false)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  // EventChannel
  private val brightnessObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
    override fun onChange(selfChange: Boolean) {
      super.onChange(selfChange)
      val brightness = Settings.System.getInt(context?.contentResolver, Settings.System.SCREEN_BRIGHTNESS, 0)
      eventSink?.success(brightness / 255.0)
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    context?.contentResolver?.registerContentObserver(
      Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS),
      false,
      brightnessObserver
    )
  }

  override fun onCancel(arguments: Any?) {
    context?.contentResolver?.unregisterContentObserver(brightnessObserver)
    eventSink = null
  }
}
