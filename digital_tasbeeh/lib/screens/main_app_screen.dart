import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floating_navigation_bar.dart';
import 'home_screen.dart';
import 'manage_tasbeeh_screen.dart';
import 'stats_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Fade animation controller for smooth transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start with fade-in
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabSelected(NavigationTab tab) async {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );

    if (tab == NavigationTab.manage) {
      // Open manage screen as modal with slide-up transition
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => const ManageTasbeehScreen(),
          fullscreenDialog: true,
        ),
      );
      return;
    }

    if (navigationProvider.currentTab != tab) {
      // Fade out current screen
      await _fadeController.reverse();

      // Update navigation state
      navigationProvider.setTab(tab);

      // Navigate to new page (only for home and stats now)
      final pageIndex = tab == NavigationTab.home ? 0 : 1;
      await _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Fade in new screen
      await _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Stack(
          children: [
            // Main content with page view
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe navigation
                    children: const [HomeScreen(), StatsScreen()],
                  ),
                );
              },
            ),

            // Floating navigation bar
            FloatingNavigationBar(onTabSelected: _onTabSelected),
          ],
        );
      },
    );
  }
}
