import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      top: 60.0, // 60dp from top center
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 430.0,
          height: 80.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.glassColor(isDark),
            boxShadow: [
              BoxShadow(
                color: const Color(0x15000000),
                blurRadius: 10.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glassColor(isDark),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      type: _ActionButtonType.sound,
                      icon: _SoundIcon(),
                    ),
                    _ActionButton(
                      type: _ActionButtonType.vibration,
                      icon: _VibrationIcon(),
                    ),
                    _ActionButton(
                      type: _ActionButtonType.undo,
                      icon: _UndoIcon(),
                    ),
                    _ActionButton(
                      type: _ActionButtonType.reset,
                      icon: _ResetIcon(),
                    ),
                    _ActionButton(
                      type: _ActionButtonType.rate,
                      icon: _RateIcon(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ActionButtonType {
  sound,
  vibration,
  undo,
  reset,
  rate,
}

class _ActionButton extends StatefulWidget {
  final _ActionButtonType type;
  final Widget icon;
  
  const _ActionButton({
    required this.type,
    required this.icon,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Scale animation with spring physics
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    // Rotation animation for reset button
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTap() async {
    // Trigger animation
    await _animationController.forward();
    await _animationController.reverse();
    
    if (!mounted) return;
    
    // Handle button action based on type
    switch (widget.type) {
      case _ActionButtonType.sound:
        _handleSoundToggle();
        break;
      case _ActionButtonType.vibration:
        _handleVibrationToggle();
        break;
      case _ActionButtonType.undo:
        _handleUndo();
        break;
      case _ActionButtonType.reset:
        _handleReset();
        break;
      case _ActionButtonType.rate:
        _handleRate();
        break;
    }
  }
  
  void _handleSoundToggle() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.toggleSound();
  }
  
  void _handleVibrationToggle() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.toggleVibration();
  }
  
  void _handleUndo() {
    final counterProvider = Provider.of<CounterProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    settingsProvider.provideHapticFeedback();
    counterProvider.decrement();
  }
  
  void _handleReset() {
    final counterProvider = Provider.of<CounterProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    settingsProvider.provideHapticFeedback();
    counterProvider.reset();
  }
  
  void _handleRate() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.openAppStoreForRating();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 60.0, // 60dp circular touch target
        height: 60.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              Widget animatedIcon = Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.icon,
              );
              
              // Apply rotation for reset button
              if (widget.type == _ActionButtonType.reset) {
                animatedIcon = Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159, // 360 degrees
                  child: animatedIcon,
                );
              }
              
              return animatedIcon;
            },
          ),
        ),
      ),
    );
  }
}

// Sound Toggle Icon
class _SoundIcon extends StatelessWidget {
  const _SoundIcon();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isActive = settingsProvider.soundEnabled;
        final color = isActive ? AppColors.buttonActive : AppColors.buttonInactive;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            CupertinoIcons.volume_up,
            size: 32.0,
            color: color,
          ),
        );
      },
    );
  }
}

// Vibration Toggle Icon
class _VibrationIcon extends StatelessWidget {
  const _VibrationIcon();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isActive = settingsProvider.vibrationEnabled;
        final color = isActive ? AppColors.buttonActive : AppColors.buttonInactive;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            CupertinoIcons.phone_circle,
            size: 28.0,
            color: color,
          ),
        );
      },
    );
  }
}

// Undo Icon
class _UndoIcon extends StatelessWidget {
  const _UndoIcon();

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, counterProvider, child) {
        final canUndo = counterProvider.currentCount > 0;
        final color = canUndo ? AppColors.buttonActive : AppColors.buttonInactive;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            CupertinoIcons.minus,
            size: 32.0,
            color: color,
          ),
        );
      },
    );
  }
}

// Reset Icon
class _ResetIcon extends StatelessWidget {
  const _ResetIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.refresh_circled,
      size: 36.0,
      color: AppColors.buttonActive,
    );
  }
}

// Rate App Icon
class _RateIcon extends StatelessWidget {
  const _RateIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.star,
      size: 36.0,
      color: AppColors.buttonActive,
    );
  }
}