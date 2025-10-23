import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style and enable full screen mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: CupertinoColors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: CupertinoColors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Hide system navigation bar for full screen experience
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // Keep status bar, hide navigation bar
  );

  runApp(const DigitalTasbeehApp());
}

class DigitalTasbeehApp extends StatelessWidget {
  const DigitalTasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CounterProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (context) => TasbeehProvider()..initialize(),
        ),
      ],
      child: CupertinoApp(
        title: 'Digital Tasbeeh',
        debugShowCheckedModeBanner: false,
        theme: _buildCupertinoTheme(),
        home: const MainAppScreen(),
        localizationsDelegates: const [DefaultCupertinoLocalizations.delegate],
      ),
    );
  }

  CupertinoThemeData _buildCupertinoTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: AppColors.lightBackground,
      barBackgroundColor: AppColors.lightSurface,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.lightTextPrimary,
        textStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextPrimary,
        ),
        actionTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.lightTextSecondary,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 21,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextPrimary,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 21,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}
