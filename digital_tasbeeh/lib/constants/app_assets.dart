/// Asset paths for the Digital Tasbeeh app
class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // Base paths
  static const String _imagesPath = 'assets/images/';
  static const String _iconsPath = 'assets/icons/';
  static const String _soundsPath = 'assets/sounds/';

  // Images
  static const String logo = '${_imagesPath}logo.png';
  static const String background = '${_imagesPath}background.png';

  // Icons
  static const String homeIcon = '${_iconsPath}home.png';
  static const String settingsIcon = '${_iconsPath}settings.png';
  static const String statsIcon = '${_iconsPath}stats.png';

  // Sounds
  static const String tapSound = '${_soundsPath}tap.mp3';
  static const String completeSound = '${_soundsPath}complete.mp3';
  static const String notificationSound = '${_soundsPath}notification.mp3';

  // Helper method to get image asset
  static String image(String name) => '$_imagesPath$name';

  // Helper method to get icon asset
  static String icon(String name) => '$_iconsPath$name';

  // Helper method to get sound asset
  static String sound(String name) => '$_soundsPath$name';
}
