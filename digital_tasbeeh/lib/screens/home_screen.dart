import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/counter_provider.dart';
import '../widgets/circular_counter.dart';

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
              return const Center(child: CupertinoActivityIndicator());
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0, // 20dp horizontal padding
                vertical: 40.0, // 40dp vertical padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Arabic heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E90FF),
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main circular counter component (includes action bar)
                  const Expanded(child: CircularCounter()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
