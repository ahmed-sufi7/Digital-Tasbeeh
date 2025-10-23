import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/navigation_provider.dart';

class FloatingNavigationBar extends StatelessWidget {
  final Function(NavigationTab) onTabSelected;

  const FloatingNavigationBar({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 30.0, // 30dp from bottom center
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 280.0,
          height: 70.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35.0),
            color: isDark ? const Color(0xF21C1C1E) : const Color(0xF2FFFFFF),
            border: Border.all(
              color: isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x20000000),
                blurRadius: 20.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xF21C1C1E)
                      : const Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.circular(35.0),
                ),
                child: Consumer<NavigationProvider>(
                  builder: (context, navigationProvider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavigationButton(
                          tab: NavigationTab.home,
                          icon: CupertinoIcons.house_fill,
                          size: 28.0,
                          isActive: navigationProvider.isTabActive(
                            NavigationTab.home,
                          ),
                          onTap: () => onTabSelected(NavigationTab.home),
                        ),
                        _NavigationButton(
                          tab: NavigationTab.manage,
                          icon: CupertinoIcons.plus_circle_fill,
                          size: 32.0,
                          isActive: navigationProvider.isTabActive(
                            NavigationTab.manage,
                          ),
                          onTap: () => onTabSelected(NavigationTab.manage),
                        ),
                        _NavigationButton(
                          tab: NavigationTab.stats,
                          icon: CupertinoIcons.chart_bar_fill,
                          size: 28.0,
                          isActive: navigationProvider.isTabActive(
                            NavigationTab.stats,
                          ),
                          onTap: () => onTabSelected(NavigationTab.stats),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final NavigationTab tab;
  final IconData icon;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.tab,
    required this.icon,
    required this.size,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavigationButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate color change when active state changes
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _handleTap() async {
    // Scale animation on tap
    await _animationController.forward();
    await _animationController.reverse();

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 50.0, // Touch target with proper spacing
        height: 50.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  widget.icon,
                  size: widget.size,
                  color: widget.isActive
                      ? AppColors.buttonActive
                      : AppColors.buttonInactive,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
