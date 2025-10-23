import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: CupertinoColors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: CupertinoColors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const DigitalTasbeehApp());
}

class DigitalTasbeehApp extends StatelessWidget {
  const DigitalTasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Digital Tasbeeh',
        debugShowCheckedModeBanner: false,
        theme: _buildCupertinoTheme(),
        home: const HomeScreen(),
        localizationsDelegates: const [
          DefaultCupertinoLocalizations.delegate,
        ],
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

// Temporary home screen placeholder - will be implemented in subsequent tasks
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Digital Tasbeeh',
                style: AppTextStyles.navigationLargeTitle(isDark),
              ),
              const SizedBox(height: 20),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                style: AppTextStyles.bodyLarge(isDark),
              ),
              const SizedBox(height: 40),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceColor(isDark),
                  border: Border.all(
                    color: AppColors.borderColor(isDark),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor(isDark),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '0',
                    style: AppTextStyles.counterLarge(isDark),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Coming Soon...',
                style: AppTextStyles.bodyMedium(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}