import 'package:flutter/cupertino.dart';

/// iOS-style color palette for the Digital Tasbeeh app
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF5AC8FA);
  
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightBorder = Color(0xFFC8C8C8);
  static const Color lightShadow = Color(0x15000000);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF98989D);
  static const Color darkBorder = Color(0xFF3A3A3C);
  static const Color darkShadow = Color(0x20000000);
  
  // Progress Ring Colors
  static const Color progressTrackLight = Color(0xFFC8C8C8);
  static const Color progressTrackDark = Color(0xFF3A3A3C);
  static const Color progressActive = primary;
  
  // Button States
  static const Color buttonActive = primary;
  static const Color buttonInactive = Color(0xFF8E8E93);
  
  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF007AFF),
    Color(0xFF5AC8FA),
  ];
  
  // Frosted Glass Effect
  static const Color glassLight = Color(0xF0C8C8C8);
  static const Color glassDark = Color(0xF03A3A3C);
  
  // Helper methods for theme-aware colors
  static Color backgroundColor(bool isDark) {
    return isDark ? darkBackground : lightBackground;
  }
  
  static Color surfaceColor(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }
  
  static Color textPrimaryColor(bool isDark) {
    return isDark ? darkTextPrimary : lightTextPrimary;
  }
  
  static Color textSecondaryColor(bool isDark) {
    return isDark ? darkTextSecondary : lightTextSecondary;
  }
  
  static Color borderColor(bool isDark) {
    return isDark ? darkBorder : lightBorder;
  }
  
  static Color shadowColor(bool isDark) {
    return isDark ? darkShadow : lightShadow;
  }
  
  static Color progressTrackColor(bool isDark) {
    return isDark ? progressTrackDark : progressTrackLight;
  }
  
  static Color glassColor(bool isDark) {
    return isDark ? glassDark : glassLight;
  }
}