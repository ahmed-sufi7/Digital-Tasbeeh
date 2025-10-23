import 'package:flutter/cupertino.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ManageTasbeehScreen extends StatelessWidget {
  const ManageTasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceColor(isDark),
        middle: Text(
          'Manage Tasbeehs',
          style: AppTextStyles.navigationTitle(isDark),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.plus_circle,
                size: 64,
                color: AppColors.textSecondaryColor(isDark),
              ),
              const SizedBox(height: 16),
              Text(
                'Manage Tasbeehs',
                style: AppTextStyles.navigationLargeTitle(isDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon...',
                style: AppTextStyles.bodyMedium(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}