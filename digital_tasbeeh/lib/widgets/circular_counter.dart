import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/counter_provider.dart';

class CircularCounter extends StatefulWidget {
  const CircularCounter({super.key});

  @override
  State<CircularCounter> createState() => _CircularCounterState();
}

class _CircularCounterState extends State<CircularCounter>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _countController;
  late AnimationController _roundController;
  late AnimationController _unlimitedController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _countScaleAnimation;
  late Animation<double> _roundScaleAnimation;
  late Animation<double> _unlimitedRotationAnimation;
  
  DateTime _lastTapTime = DateTime.now();
  static const Duration _doubleTapProtection = Duration(milliseconds: 100);
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Progress ring animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Counter scale animation controller
    _countController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Round completion animation controller
    _roundController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Unlimited mode rotation controller
    _unlimitedController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Progress animation with ease-out curve
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    
    // Count scale-pulse animation
    _countScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOut,
    ));
    
    // Round scale-bounce animation
    _roundScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _roundController,
      curve: Curves.elasticOut,
    ));
    
    // Unlimited rotation animation
    _unlimitedRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _unlimitedController,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _countController.dispose();
    _roundController.dispose();
    _unlimitedController.dispose();
    super.dispose();
  }
  
  double _getCounterDiameter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive scaling based on screen width
    if (screenWidth < 360) {
      return 320.0; // Small screens
    } else if (screenWidth > 480) {
      return 420.0; // Large screens
    } else {
      return 380.0; // Medium screens (default)
    }
  }
  
  void _handleTap() async {
    final now = DateTime.now();
    if (now.difference(_lastTapTime) < _doubleTapProtection) {
      return; // Prevent double-tap
    }
    _lastTapTime = now;
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    final counterProvider = Provider.of<CounterProvider>(context, listen: false);
    final wasRoundCompleted = counterProvider.isRoundCompleted;
    
    // Increment counter
    final success = await counterProvider.increment();
    
    if (success) {
      // Trigger count scale animation
      _countController.forward().then((_) {
        _countController.reverse();
      });
      
      // Update progress animation
      if (!counterProvider.isUnlimited) {
        _progressController.animateTo(counterProvider.progressPercentage);
      }
      
      // Handle round completion animation
      if (wasRoundCompleted) {
        _roundController.forward().then((_) {
          _roundController.reverse();
        });
      }
      
      // Handle unlimited mode rotation
      if (counterProvider.isUnlimited) {
        _unlimitedController.animateTo(counterProvider.unlimitedProgress);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final diameter = _getCounterDiameter(context);
    
    return Consumer<CounterProvider>(
      builder: (context, counterProvider, child) {
        return GestureDetector(
          onTap: _handleTap,
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom painted counter with progress ring
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _progressAnimation,
                    _unlimitedRotationAnimation,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(diameter, diameter),
                      painter: CounterPainter(
                        progress: counterProvider.isUnlimited 
                            ? _unlimitedRotationAnimation.value
                            : _progressAnimation.value,
                        completedSegments: counterProvider.completedSegments,
                        isUnlimited: counterProvider.isUnlimited,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
                
                // Counter text display
                AnimatedBuilder(
                  animation: _countScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _countScaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Current count
                          Text(
                            '${counterProvider.currentCount}',
                            style: AppTextStyles.getCounterStyle(
                              counterProvider.currentCount,
                              isDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Target count (if applicable)
                          if (counterProvider.targetDisplayText.isNotEmpty)
                            Text(
                              counterProvider.targetDisplayText,
                              style: AppTextStyles.targetCount(isDark),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Round number display (positioned below counter)
                if (counterProvider.roundDisplayText.isNotEmpty)
                  Positioned(
                    bottom: diameter * 0.15,
                    child: AnimatedBuilder(
                      animation: _roundScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _roundScaleAnimation.value,
                          child: Text(
                            counterProvider.roundDisplayText,
                            style: AppTextStyles.roundNumber(isDark),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CounterPainter extends CustomPainter {
  final double progress;
  final int completedSegments;
  final bool isUnlimited;
  final bool isDark;
  
  CounterPainter({
    required this.progress,
    required this.completedSegments,
    required this.isUnlimited,
    required this.isDark,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    _drawBackground(canvas, center, radius);
    _drawTickMarks(canvas, center, radius);
    _drawProgressRing(canvas, center, radius);
    _drawProgressDots(canvas, center, radius);
    _drawProgressHandle(canvas, center, radius);
    _drawInnerCircle(canvas, center, radius);
  }
  
  void _drawBackground(Canvas canvas, Offset center, double radius) {
    // Outer background track
    final trackPaint = Paint()
      ..color = AppColors.progressTrackColor(isDark)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius - 7, trackPaint);
  }
  
  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = AppColors.textSecondaryColor(isDark).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    const tickCount = 100;
    const tickLength = 12.0;
    final tickRadius = 166.0;
    
    for (int i = 0; i < tickCount; i++) {
      final angle = (i / tickCount) * 2 * math.pi - math.pi / 2;
      final startX = center.dx + math.cos(angle) * (tickRadius - tickLength / 2);
      final startY = center.dy + math.sin(angle) * (tickRadius - tickLength / 2);
      final endX = center.dx + math.cos(angle) * (tickRadius + tickLength / 2);
      final endY = center.dy + math.sin(angle) * (tickRadius + tickLength / 2);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        tickPaint,
      );
    }
  }
  
  void _drawProgressRing(Canvas canvas, Offset center, double radius) {
    if (progress <= 0) return;
    
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;
    
    if (isUnlimited) {
      // Continuous rotation for unlimited mode
      final gradient = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: AppColors.primaryGradient,
        transform: GradientRotation(progress * 2 * math.pi),
      );
      
      progressPaint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius - 7),
      );
      
      canvas.drawCircle(center, radius - 7, progressPaint);
    } else {
      // Progress arc for limited mode
      progressPaint.color = AppColors.progressActive;
      
      final rect = Rect.fromCircle(center: center, radius: radius - 7);
      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = progress * 2 * math.pi;
      
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }
  
  void _drawProgressDots(Canvas canvas, Offset center, double radius) {
    if (isUnlimited || completedSegments <= 0) return;
    
    final dotPaint = Paint()
      ..color = AppColors.progressActive
      ..style = PaintingStyle.fill;
    
    const totalDots = 33;
    const dotRadius = 3.0;
    final dotCircleRadius = radius - 7;
    
    for (int i = 0; i < completedSegments && i < totalDots; i++) {
      final angle = (i / totalDots) * 2 * math.pi - math.pi / 2;
      final dotX = center.dx + math.cos(angle) * dotCircleRadius;
      final dotY = center.dy + math.sin(angle) * dotCircleRadius;
      
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }
  }
  
  void _drawProgressHandle(Canvas canvas, Offset center, double radius) {
    if (progress <= 0 && !isUnlimited) return;
    
    final handleRadius = radius - 7;
    final angle = isUnlimited 
        ? progress * 2 * math.pi - math.pi / 2
        : progress * 2 * math.pi - math.pi / 2;
    
    final handleX = center.dx + math.cos(angle) * handleRadius;
    final handleY = center.dy + math.sin(angle) * handleRadius;
    final handleCenter = Offset(handleX, handleY);
    
    // Handle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(
      Offset(handleCenter.dx, handleCenter.dy + 2),
      10.0,
      shadowPaint,
    );
    
    // Handle
    final handlePaint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(handleCenter, 10.0, handlePaint);
  }
  
  void _drawInnerCircle(Canvas canvas, Offset center, double radius) {
    final innerRadius = 176.0; // 352dp diameter = 176dp radius
    
    // Inner circle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    canvas.drawCircle(
      Offset(center.dx, center.dy - 5),
      innerRadius,
      shadowPaint,
    );
    
    // Inner circle
    final innerPaint = Paint()
      ..color = isDark ? AppColors.darkSurface : CupertinoColors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
  
  @override
  bool shouldRepaint(CounterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.completedSegments != completedSegments ||
           oldDelegate.isUnlimited != isUnlimited ||
           oldDelegate.isDark != isDark;
  }
}