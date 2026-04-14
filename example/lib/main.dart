import 'package:flutter/material.dart';
import 'dart:async';
import 'package:screen_brightness_pro/screen_brightness_pro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const BrightnessScreen(),
    );
  }
}

class BrightnessScreen extends StatefulWidget {
  const BrightnessScreen({super.key});

  @override
  State<BrightnessScreen> createState() => _BrightnessScreenState();
}

class _BrightnessScreenState extends State<BrightnessScreen> {
  double _currentBrightness = 0.5;
  bool _smoothTransitions = true;
  bool _keepScreenOn = false;
  bool _isAutoMode = false;
  double _batteryLevel = -1.0;
  bool _isLowPower = false;
  bool _autoOptimize = false;
  StreamSubscription<double>? _brightnessSubscription;
  Timer? _batteryTimer;

  @override
  void initState() {
    super.initState();
    _initData();
    _subscribeToChanges();
    _startBatteryMonitor();
  }

  Future<void> _initData() async {
    final brightness = await ScreenBrightnessPro.getBrightness();
    final autoMode = await ScreenBrightnessPro.isAutoModeEnabled();
    final battery = await ScreenBrightnessPro.getBatteryLevel();
    final lowPower = await ScreenBrightnessPro.isLowPowerModeEnabled();
    
    if (mounted) {
      setState(() {
        _currentBrightness = brightness;
        _isAutoMode = autoMode;
        _batteryLevel = battery;
        _isLowPower = lowPower;
      });
    }
  }

  void _startBatteryMonitor() {
    _batteryTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final level = await ScreenBrightnessPro.getBatteryLevel();
      final lowPower = await ScreenBrightnessPro.isLowPowerModeEnabled();
      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _isLowPower = lowPower;
        });
        if (_autoOptimize) {
          ScreenBrightnessPro.optimizeForLowBattery();
        }
      }
    });
  }

  void _subscribeToChanges() {
    _brightnessSubscription = ScreenBrightnessPro.onBrightnessChanged.listen((brightness) {
      if (mounted) {
        setState(() {
          _currentBrightness = brightness;
        });
      }
    });
  }

  @override
  void dispose() {
    _brightnessSubscription?.cancel();
    _batteryTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSystemBrightness(double val) async {
    final hasPermission = await ScreenBrightnessPro.hasWriteSettingsPermission();
    if (!hasPermission) {
      bool? request = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('To change system-wide brightness, this app needs "Write System Settings" permission. Open settings now?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Settings')),
          ],
        ),
      );
      if (request == true) {
        if (!mounted) return;
        await ScreenBrightnessPro.requestWriteSettingsPermission();
      }
      return;
    }
    await ScreenBrightnessPro.setSystemBrightness(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.blueGrey.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Brightness Pro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Professional brightness control',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: _currentBrightness * 0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: _currentBrightness),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${(_currentBrightness * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Battery Status
                  _buildControlPanel(
                    title: 'Battery Awareness',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              _batteryLevel > 0.2 ? Icons.battery_full : Icons.battery_alert,
                              color: _batteryLevel > 0.2 ? Colors.greenAccent : Colors.orangeAccent,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Level: ${_batteryLevel >= 0 ? (_batteryLevel * 100).toInt() : 'N/A'}%',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (_isLowPower)
                              const Chip(
                                label: Text('LOW POWER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.orangeAccent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildSwitchTile(
                          'Battery Auto-Optimize',
                          _autoOptimize,
                          (v) => setState(() => _autoOptimize = v),
                          icon: Icons.battery_saver,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main Control Panel
                  _buildControlPanel(
                    title: 'Brightness Control',
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Smooth Transitions',
                          _smoothTransitions,
                          (v) => setState(() => _smoothTransitions = v),
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blueAccent,
                            inactiveTrackColor: Colors.white10,
                            thumbColor: Colors.white,
                            overlayColor: Colors.blueAccent.withValues(alpha: 0.2),
                            trackHeight: 8,
                          ),
                          child: Slider(
                            value: _currentBrightness,
                            onChanged: (val) {
                              setState(() => _currentBrightness = val);
                              ScreenBrightnessPro.setBrightness(val, smooth: _smoothTransitions);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed: () => ScreenBrightnessPro.resetBrightness(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset to Default'),
                            ),
                            TextButton.icon(
                              onPressed: () => _handleSystemBrightness(_currentBrightness),
                              icon: const Icon(Icons.settings_system_daydream),
                              label: const Text('Apply to System'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pro Features Panel
                  _buildControlPanel(
                    title: 'Pro Features',
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Keep Screen On',
                          _keepScreenOn,
                          (v) {
                            setState(() => _keepScreenOn = v);
                            ScreenBrightnessPro.setKeepScreenOn(v);
                          },
                          icon: Icons.lightbulb,
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildSwitchTile(
                          'Auto Brightness Mode',
                          _isAutoMode,
                          (v) async {
                            final hasPermission = await ScreenBrightnessPro.hasWriteSettingsPermission();
                            if (!hasPermission) {
                               await _handleSystemBrightness(0);
                               return;
                            }
                            setState(() => _isAutoMode = v);
                            ScreenBrightnessPro.setAutoMode(v);
                          },
                          icon: Icons.brightness_auto,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: Colors.blueAccent), const SizedBox(width: 12)],
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
        ),
      ],
    );
  }
}
