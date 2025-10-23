import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = false;
  
  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isLoading => _isLoading;
  
  // Initialize settings from SharedPreferences
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
      _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      // Use default values if loading fails
      _soundEnabled = true;
      _vibrationEnabled = true;
    } finally {
      _setLoading(false);
    }
  }
  
  // Toggle sound setting
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
    
    // Provide haptic feedback for the toggle action
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    
    await _saveSoundSetting();
  }
  
  // Toggle vibration setting
  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
    
    // Provide haptic feedback for the toggle action (if still enabled)
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    
    await _saveVibrationSetting();
  }
  
  // Provide haptic feedback based on current settings
  void provideHapticFeedback({HapticFeedbackType type = HapticFeedbackType.light}) {
    if (!_vibrationEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
  
  // Provide audio feedback based on current settings
  void provideAudioFeedback() {
    if (!_soundEnabled) return;
    
    // Play system sound for counter increment
    // Using HapticFeedback as a substitute for now - can be enhanced later with custom sounds
    HapticFeedback.selectionClick();
  }
  
  // Open app store for rating
  Future<void> openAppStoreForRating() async {
    // Provide haptic feedback
    provideHapticFeedback(type: HapticFeedbackType.light);
    
    // Android Play Store URL (replace with actual package name)
    const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.digital_tasbeeh';
    
    try {
      final Uri url = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch app store URL');
      }
    } catch (e) {
      debugPrint('Error opening app store: $e');
    }
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  Future<void> _saveSoundSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
    } catch (e) {
      debugPrint('Failed to save sound setting: $e');
    }
  }
  
  Future<void> _saveVibrationSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
    } catch (e) {
      debugPrint('Failed to save vibration setting: $e');
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}