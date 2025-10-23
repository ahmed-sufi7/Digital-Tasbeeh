import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/circular_counter.dart';
import '../widgets/ios_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleScreenTap(BuildContext context) async {
    final counterProvider = Provider.of<CounterProvider>(
      context,
      listen: false,
    );
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    // Provide haptic and audio feedback
    settingsProvider.provideHapticFeedback();
    settingsProvider.provideAudioFeedback();

    // Increment counter
    await counterProvider.increment();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
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

          return Column(
            children: [
              // iOS-style header
              IOSHeader(
                title: 'Digital Tasbeeh',
                trailing: [
                  IOSHeaderButton(
                    icon: CupertinoIcons.settings,
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ],
              ),

              // Main content with full-screen tap detection
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleScreenTap(context),
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 8.0,
                      bottom: 120.0, // Space for floating nav bar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Main Arabic heading at the top
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32,
                            right: 32,
                            top: 12,
                          ),
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

                        // Centered counter and action bar
                        Expanded(child: Center(child: const CircularCounter())),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
