import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'providers/counter_provider.dart';
import 'widgets/widgets.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CounterProvider()..initialize(),
        ),
      ],
      child: CupertinoApp(
        title: 'Digital Tasbeeh',
        debugShowCheckedModeBanner: false,
        theme: _buildCupertinoTheme(),
        home: const HomeScreen(),
        localizationsDelegates: const [
          DefaultCupertinoLocalizations.delegate,
        ],
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

// Temporary home screen placeholder - will be implemented in subsequent tasks
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      child: SafeArea(
        child: Consumer<CounterProvider>(
          builder: (context, counterProvider, child) {
            if (counterProvider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (counterProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${counterProvider.error}',
                      style: AppTextStyles.bodyMedium(isDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      onPressed: () => counterProvider.initialize(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tasbeeh name display
                  Text(
                    counterProvider.currentTasbeeh?.name ?? 'Digital Tasbeeh',
                    style: AppTextStyles.tasbeehName(isDark),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Main circular counter component
                  const CircularCounter(),
                  
                  const SizedBox(height: 60),
                  
                  // Temporary action buttons (will be replaced by ActionBar in task 5)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        onPressed: counterProvider.currentCount > 0 
                            ? () => counterProvider.decrement()
                            : null,
                        child: const Text('Undo'),
                      ),
                      CupertinoButton(
                        onPressed: () => counterProvider.reset(),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}