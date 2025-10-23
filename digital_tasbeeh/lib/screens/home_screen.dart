import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/counter_provider.dart';
import '../widgets/circular_counter.dart';
import '../widgets/action_bar.dart';

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

            return Stack(
              children: [
                // Main content with perfect vertical layout
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, // 20dp horizontal padding
                    vertical: 40.0,   // 40dp vertical padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Space for ActionBar (60dp margin + 80dp height + spacing)
                      const SizedBox(height: 100.0),
                      
                      // Main circular counter component
                      const CircularCounter(),
                      
                      // 40dp spacing below counter
                      const SizedBox(height: 40.0),
                      
                      // Tasbeeh name display with precise specifications
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300.0), // Max width 300dp
                        child: Text(
                          counterProvider.currentTasbeeh?.name ?? 'Digital Tasbeeh',
                          style: AppTextStyles.tasbeehName(isDark), // SF Pro Display medium 500, 24pt, 0.5 letter spacing
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis, // Ellipsis truncation
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ActionBar positioned at top with 60dp margin from safe area
                const ActionBar(),
              ],
            );
          },
        ),
      ),
    );
  }
}