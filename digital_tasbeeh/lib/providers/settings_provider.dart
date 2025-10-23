import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = false;

  // Audio player for tap sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

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

      // Configure audio player for optimal performance
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setVolume(1.0);
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
  void provideHapticFeedback({
    HapticFeedbackType type = HapticFeedbackType.light,
  }) {
    if (!_vibrationEnabled) return;

    switch (type) {
      case HapticFeedbackType.light:
        _triggerVibration(50); // Light vibration - 50ms
        break;
      case HapticFeedbackType.medium:
        _triggerVibration(100); // Medium vibration - 100ms
        break;
      case HapticFeedbackType.heavy:
        _triggerVibration(200); // Heavy vibration - 200ms
        break;
      case HapticFeedbackType.selection:
        _triggerVibration(30); // Selection vibration - 30ms
        break;
    }
  }

  // Provide audio feedback based on current settings
  void provideAudioFeedback() async {
    if (!_soundEnabled) return;

    try {
      // Stop any currently playing sound first
      await _audioPlayer.stop();

      // Play the tap sound from assets (don't await to allow rapid taps)
      _audioPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      debugPrint('Error playing tap sound: $e');
      // Fallback to system sound if custom sound fails
      HapticFeedback.selectionClick();
    }
  }

  // Private method to trigger vibration
  void _triggerVibration(int duration) async {
    try {
      // Check if device has vibration capability
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: duration);
      } else {
        // Fallback to system haptic feedback if vibration not available
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error triggering vibration: $e');
      // Fallback to system haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Open app store for rating
  Future<void> openAppStoreForRating() async {
    // Provide haptic feedback
    provideHapticFeedback(type: HapticFeedbackType.light);

    // Android Play Store URL (replace with actual package name)
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.example.digital_tasbeeh';

    try {
      final Uri url = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
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

enum HapticFeedbackType { light, medium, heavy, selection }
