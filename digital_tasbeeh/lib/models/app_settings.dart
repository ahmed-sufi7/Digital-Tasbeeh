import 'package:flutter/material.dart';

class NotificationSchedule {
  final String id;
  final TimeOfDay time;
  final List<int> weekdays; // 1-7 (Monday-Sunday)
  final bool isEnabled;
  final String message;

  const NotificationSchedule({
    required this.id,
    required this.time,
    required this.weekdays,
    this.isEnabled = true,
    this.message = 'Time for dhikr! 🤲',
  });

  NotificationSchedule copyWith({
    String? id,
    TimeOfDay? time,
    List<int>? weekdays,
    bool? isEnabled,
    String? message,
  }) {
    return NotificationSchedule(
      id: id ?? this.id,
      time: time ?? this.time,
      weekdays: weekdays ?? this.weekdays,
      isEnabled: isEnabled ?? this.isEnabled,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'weekdays': weekdays.join(','),
      'is_enabled': isEnabled ? 1 : 0,
      'message': message,
    };
  }

  factory NotificationSchedule.fromMap(Map<String, dynamic> map) {
    return NotificationSchedule(
      id: map['id'] as String,
      time: TimeOfDay(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      ),
      weekdays: (map['weekdays'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList(),
      isEnabled: (map['is_enabled'] as int?) == 1,
      message: map['message'] as String? ?? 'Time for dhikr! 🤲',
    );
  }

  @override
  String toString() {
    return 'NotificationSchedule{id: $id, time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}, weekdays: $weekdays, isEnabled: $isEnabled}';
  }
}

class AppSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;
  final ThemeMode themeMode;
  final List<NotificationSchedule> reminderSchedules;
  final String? selectedTasbeehId;
  final bool analyticsEnabled;

  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = true,
    this.themeMode = ThemeMode.system,
    this.reminderSchedules = const [],
    this.selectedTasbeehId,
    this.analyticsEnabled = true,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    ThemeMode? themeMode,
    List<NotificationSchedule>? reminderSchedules,
    String? selectedTasbeehId,
    bool? analyticsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      reminderSchedules: reminderSchedules ?? this.reminderSchedules,
      selectedTasbeehId: selectedTasbeehId ?? this.selectedTasbeehId,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  // Convert to Map for storage (flattened for SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'notifications_enabled': notificationsEnabled,
      'theme_mode': themeMode.index,
      'selected_tasbeeh_id': selectedTasbeehId,
      'analytics_enabled': analyticsEnabled,
    };
  }

  // Create from Map (SharedPreferences)
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      soundEnabled: map['sound_enabled'] as bool? ?? true,
      vibrationEnabled: map['vibration_enabled'] as bool? ?? true,
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      themeMode: ThemeMode.values[map['theme_mode'] as int? ?? ThemeMode.system.index],
      selectedTasbeehId: map['selected_tasbeeh_id'] as String?,
      analyticsEnabled: map['analytics_enabled'] as bool? ?? true,
    );
  }

  // Default settings
  static const AppSettings defaultSettings = AppSettings();

  // Check if dark mode should be used
  bool isDarkMode(BuildContext context) {
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  @override
  String toString() {
    return 'AppSettings{soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, notificationsEnabled: $notificationsEnabled, themeMode: $themeMode, selectedTasbeehId: $selectedTasbeehId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.notificationsEnabled == notificationsEnabled &&
        other.themeMode == themeMode &&
        other.selectedTasbeehId == selectedTasbeehId &&
        other.analyticsEnabled == analyticsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      soundEnabled,
      vibrationEnabled,
      notificationsEnabled,
      themeMode,
      selectedTasbeehId,
      analyticsEnabled,
    );
  }
}