import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// iOS-style typography system with SF Pro Display font family
class AppTextStyles {
  // Font Family
  static const String fontFamily = 'SF Pro Display';
  static const String fallbackFontFamily = 'Roboto';
  
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  
  // Counter Text Styles
  static TextStyle counterLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 120,
    fontWeight: light,
    letterSpacing: -2.0,
    color: AppColors.primary,
    height: 1.0,
  );
  
  static TextStyle counterMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 96,
    fontWeight: light,
    letterSpacing: -1.5,
    color: AppColors.primary,
    height: 1.0,
  );
  
  static TextStyle counterSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: light,
    letterSpacing: -1.0,
    color: AppColors.primary,
    height: 1.0,
  );
  
  // Target Count Text Style
  static TextStyle targetCount(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: regular,
    letterSpacing: 0,
    color: AppColors.textSecondaryColor(isDark),
    height: 1.2,
  );
  
  // Round Number Text Style
  static TextStyle roundNumber(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 42,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: AppColors.primary,
    height: 1.2,
  );
  
  // Tasbeeh Name Text Style
  static TextStyle tasbeehName(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: AppColors.textPrimaryColor(isDark).withValues(alpha: 0.8),
    height: 1.3,
  );
  
  // Navigation Text Styles
  static TextStyle navigationTitle(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: semibold,
    letterSpacing: 0.37,
    color: AppColors.textPrimaryColor(isDark),
    height: 1.2,
  );
  
  static TextStyle navigationLargeTitle(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: semibold,
    letterSpacing: 0.36,
    color: AppColors.textPrimaryColor(isDark),
    height: 1.2,
  );
  
  // Body Text Styles
  static TextStyle bodyLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: regular,
    letterSpacing: -0.41,
    color: AppColors.textPrimaryColor(isDark),
    height: 1.29,
  );
  
  static TextStyle bodyMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: regular,
    letterSpacing: -0.24,
    color: AppColors.textPrimaryColor(isDark),
    height: 1.33,
  );
  
  static TextStyle bodySmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: regular,
    letterSpacing: -0.08,
    color: AppColors.textSecondaryColor(isDark),
    height: 1.38,
  );
  
  // Label Text Styles
  static TextStyle labelLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: AppColors.textPrimaryColor(isDark),
    height: 1.29,
  );
  
  static TextStyle labelMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: AppColors.textPrimaryColor(isDark),
    height: 1.33,
  );
  
  static TextStyle labelSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: AppColors.textSecondaryColor(isDark),
    height: 1.38,
  );
  
  // Button Text Styles
  static TextStyle buttonLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: CupertinoColors.white,
    height: 1.29,
  );
  
  static TextStyle buttonMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: CupertinoColors.white,
    height: 1.33,
  );
  
  // Caption Text Styles
  static TextStyle caption1(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0,
    color: AppColors.textSecondaryColor(isDark),
    height: 1.33,
  );
  
  static TextStyle caption2(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: regular,
    letterSpacing: 0.07,
    color: AppColors.textSecondaryColor(isDark),
    height: 1.36,
  );
  
  // Helper method to get counter text style based on count magnitude
  static TextStyle getCounterStyle(int count, bool isDark) {
    if (count >= 10000) {
      return counterSmall(isDark);
    } else if (count >= 1000) {
      return counterMedium(isDark);
    } else {
      return counterLarge(isDark);
    }
  }
  
  // Helper method to create text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  // Helper method to create text style with custom opacity
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }
}