import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

/// Floating footer navigation bar with a centered protruding add button.
///
/// Features:
/// - Rounded black container with border
/// - Home and Stats icons using image assets
/// - Centered protruding circular add button
/// - Responsive width (65% of screen, clamped to 200-280px)
/// - Shadow effects for depth
class FloatingNavigationBar extends StatelessWidget {
  final Function(NavigationTab) onTabSelected;

  const FloatingNavigationBar({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final computedWidth = (screenWidth * 0.65).clamp(200.0, 280.0);
    const barHeight = 58.0;
    const totalHeight = 75.0;

    return Positioned(
      bottom: 30.0, // 30dp from bottom center
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: computedWidth,
          height: totalHeight,
          child: Consumer<NavigationProvider>(
            builder: (context, navigationProvider, child) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background rounded bar
                  Container(
                    width: computedWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      border: Border.all(
                        color: const Color(0xFF3A3A3A),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Home icon (left)
                          Expanded(
                            child: _NavImageButton(
                              activeImage: 'assets/icons/home-active.png',
                              inactiveImage: 'assets/icons/home-inactive.png',
                              onTap: () => onTabSelected(NavigationTab.home),
                              isActive: navigationProvider.isTabActive(
                                NavigationTab.home,
                              ),
                            ),
                          ),
                          // Placeholder space for centered add button
                          const SizedBox(width: 50),
                          // Stats icon (right)
                          Expanded(
                            child: _NavImageButton(
                              activeImage: 'assets/icons/stats-active.png',
                              inactiveImage: 'assets/icons/stats-inacative.png',
                              onTap: () => onTabSelected(NavigationTab.stats),
                              isActive: navigationProvider.isTabActive(
                                NavigationTab.stats,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Protruding centered add button (circular white button)
                  Positioned(
                    top: 0, // Protrudes above the bar
                    child: GestureDetector(
                      onTap: () => onTabSelected(NavigationTab.manage),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: Color(0xFF1A1A1A),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Navigation icon button that switches between active/inactive images
class _NavImageButton extends StatelessWidget {
  final String activeImage;
  final String inactiveImage;
  final VoidCallback? onTap;
  final bool isActive;

  const _NavImageButton({
    super.key,
    required this.activeImage,
    required this.inactiveImage,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Image.asset(
          isActive ? activeImage : inactiveImage,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
