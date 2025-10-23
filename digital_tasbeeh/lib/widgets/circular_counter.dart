import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';

class CircularCounter extends StatefulWidget {
  const CircularCounter({super.key});

  @override
  State<CircularCounter> createState() => _CircularCounterState();
}

class _CircularCounterState extends State<CircularCounter>
    with TickerProviderStateMixin {
  DateTime _lastTapTime = DateTime.now();
  static const Duration _doubleTapProtection = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animations are handled by TweenAnimationBuilder in the display
  }

  void _handleCounterTap() async {
    final now = DateTime.now();
    if (now.difference(_lastTapTime) < _doubleTapProtection) {
      return; // Prevent double-tap
    }
    _lastTapTime = now;

    final counterProvider = Provider.of<CounterProvider>(
      context,
      listen: false,
    );
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    // Counter tap feedback handled by TweenAnimationBuilder in display

    // Provide haptic and audio feedback
    settingsProvider.provideHapticFeedback();
    settingsProvider.provideAudioFeedback();

    // Increment counter
    await counterProvider.increment();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Consumer<CounterProvider>(
      builder: (context, counterProvider, child) {
        return GestureDetector(
          onTap: _handleCounterTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Horizontal Action Bar
              _buildActionBar(isDark, counterProvider),
              const SizedBox(height: 24),

              // Clock-face Progress Ring with Counter
              ClockFaceProgressRing(
                progress: counterProvider.isUnlimited
                    ? counterProvider.currentCount /
                          100.0 // Non-resetting continuous progress
                    : counterProvider.progressPercentage,
                endpointProgress: counterProvider.isUnlimited
                    ? counterProvider.currentCount /
                          100.0 // Non-resetting continuous progress
                    : counterProvider.progressPercentage,
                currentCount: counterProvider.currentCount,
                size: 280,
                strokeWidth: 22,
                showClockFace: true,
                showMilestones: !counterProvider.isUnlimited,
                milestones: const [100, 300, 500, 1000],
                isUnlimited: counterProvider.isUnlimited,
                child: _buildCounterDisplay(isDark, counterProvider),
              ),

              const SizedBox(height: 16),

              // Bottom Label (Tasbeeh name)
              _buildBottomLabel(isDark, counterProvider),
            ],
          ),
        );
      },
    );
  }

  // Action Bar with Sound, Vibrate, Undo, Restart, Rate buttons
  Widget _buildActionBar(bool isDark, CounterProvider counterProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sound button
              _buildActionButton(
                icon: CupertinoIcons.volume_up,
                isActive: settingsProvider.soundEnabled,
                onTap: () {
                  settingsProvider.toggleSound();
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(width: 8),

              // Vibrate button
              _buildActionButton(
                icon: CupertinoIcons.device_phone_portrait,
                isActive: settingsProvider.vibrationEnabled,
                onTap: () {
                  settingsProvider.toggleVibration();
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(width: 8),

              // Undo button (minus)
              _buildActionButton(
                icon: CupertinoIcons.minus,
                isEnabled: counterProvider.currentCount > 0,
                alwaysBlue: true,
                onTap: () async {
                  await counterProvider.decrement();
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(width: 8),

              // Restart button
              _buildActionButton(
                icon: CupertinoIcons.arrow_clockwise,
                isEnabled: counterProvider.currentCount > 0,
                alwaysBlue: true,
                onTap: () {
                  _showResetDialog();
                },
              ),
              const SizedBox(width: 8),

              // Rate button
              _buildActionButton(
                icon: CupertinoIcons.star,
                alwaysBlue: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Implement rate app functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isEnabled = true,
    bool isActive = false,
    bool alwaysBlue = false,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Icon(
        icon,
        size: 20,
        color: (isActive || alwaysBlue)
            ? const Color(0xFF1E90FF)
            : Colors.white.withValues(alpha: 0.8),
      ),
    );
  }

  // Counter Display inside Progress Ring
  Widget _buildCounterDisplay(bool isDark, CounterProvider counterProvider) {
    final isUnlimited = counterProvider.isUnlimited;
    final hasTarget = !isUnlimited && counterProvider.targetCount != null;
    final showRounds = !isUnlimited && counterProvider.roundNumber > 1;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0.95, end: 1.0),
      key: ValueKey<int>(counterProvider.currentCount),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Large count number
                Text(
                  '${counterProvider.currentCount}',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: Color(0xFF1E90FF),
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),

                // Target count
                if (hasTarget)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '/ ${counterProvider.targetCount}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8A8A8A),
                        letterSpacing: 0,
                        height: 1.2,
                      ),
                    ),
                  ),

                // Rounds display
                if (showRounds)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Round ${counterProvider.roundNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E90FF),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Bottom Label (Tasbeeh name)
  Widget _buildBottomLabel(bool isDark, CounterProvider counterProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        counterProvider.currentTasbeeh?.name ??
            'صَلَّى ٱللّٰهُ عَلَيْهِ وَآلِهِ وَسَلَّمَ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showResetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Counter?'),
        content: const Text('This will reset your current count to zero.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              Navigator.pop(context);
              final counterProvider = Provider.of<CounterProvider>(
                context,
                listen: false,
              );
              counterProvider.reset();
            },
          ),
        ],
      ),
    );
  }
}

// Clock Face Progress Ring Widget
class ClockFaceProgressRing extends StatelessWidget {
  final double progress;
  final double endpointProgress;
  final int currentCount;
  final double size;
  final double strokeWidth;
  final bool showClockFace;
  final bool showMilestones;
  final List<int> milestones;
  final bool isUnlimited;
  final Widget child;

  const ClockFaceProgressRing({
    super.key,
    required this.progress,
    required this.endpointProgress,
    required this.currentCount,
    required this.size,
    required this.strokeWidth,
    required this.showClockFace,
    required this.showMilestones,
    required this.milestones,
    required this.isUnlimited,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom painted progress ring
          CustomPaint(
            size: Size(size, size),
            painter: ClockFaceProgressPainter(
              progress: progress,
              endpointProgress: endpointProgress,
              strokeWidth: strokeWidth,
              showClockFace: showClockFace,
              showMilestones: showMilestones,
              milestones: milestones,
              currentCount: currentCount,
              isUnlimited: isUnlimited,
            ),
          ),

          // Center content
          child,
        ],
      ),
    );
  }
}

// Clock Face Progress Painter
class ClockFaceProgressPainter extends CustomPainter {
  final double progress;
  final double endpointProgress;
  final double strokeWidth;
  final bool showClockFace;
  final bool showMilestones;
  final List<int> milestones;
  final int currentCount;
  final bool isUnlimited;

  ClockFaceProgressPainter({
    required this.progress,
    required this.endpointProgress,
    required this.strokeWidth,
    required this.showClockFace,
    required this.showMilestones,
    required this.milestones,
    required this.currentCount,
    required this.isUnlimited,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    _drawBackground(canvas, center, radius);

    // Draw clock face marks
    if (showClockFace) {
      _drawClockFace(canvas, center, radius);
    }

    // Draw progress arc
    _drawProgressArc(canvas, center, radius);

    // Draw progress dots along the arc
    _drawProgressDots(canvas, center, radius);

    // Draw milestones
    if (showMilestones) {
      _drawMilestones(canvas, center, radius);
    }

    // Draw progress endpoint
    _drawProgressEndpoint(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    // Draw grey background track for unprogressed ring
    final backgroundPaint = Paint()
      ..color = const Color(0xFF8E8E93)
          .withValues(alpha: 0.3) // Grey color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  void _drawClockFace(Canvas canvas, Offset center, double radius) {
    // Draw 120 tick marks around the ring (exactly as in your design)
    for (int i = 0; i < 120; i++) {
      final isMajorTick = i % 10 == 0; // Every 10th tick is a major tick
      final angle =
          (i * 3 - 90) * math.pi / 180; // 3 degrees per tick, start at top

      final tickPaint = Paint()
        ..color = const Color(0xFF2A2A2A)
            .withValues(alpha: 0.4) // Dark grey with 40% opacity
        ..strokeWidth = isMajorTick
            ? 2
            : 1 // Major ticks are thicker
        ..strokeCap = StrokeCap.round;

      final tickLength = isMajorTick ? 12.0 : 8.0; // Major ticks are longer
      final innerRadius = radius - strokeWidth / 2 - 10; // 10px gap from ring
      final outerRadius = innerRadius - tickLength; // Tick extends inward

      // Start point (closer to ring)
      final startPoint = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      // End point (extends inward toward center)
      final endPoint = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      // Draw the tick line
      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  void _drawProgressArc(Canvas canvas, Offset center, double radius) {
    double actualProgress = progress;

    // If unlimited mode, show continuous revolving progress
    if (isUnlimited) {
      // Show continuous non-resetting progress - keeps growing beyond 100%
      actualProgress = currentCount / 100.0;

      // Draw completed full revolutions as background rings
      final completedRevolutions = (currentCount / 100).floor();
      if (completedRevolutions > 0) {
        final backgroundPaint = Paint()
          ..color = const Color(0xFF1E90FF).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        final rect = Rect.fromCircle(center: center, radius: radius);
        const startAngle = -math.pi / 2;
        const fullCircle = 2 * math.pi;

        // Draw the background ring showing completed revolutions
        canvas.drawArc(rect, startAngle, fullCircle, false, backgroundPaint);
      }
    }

    // For testing: show minimum progress if there's any count
    if (actualProgress <= 0 && currentCount > 0) {
      actualProgress = 0.05; // Show 5% minimum progress for visibility
    }

    if (actualProgress <= 0) return;

    // ===== BLUE PROGRESS ARC =====
    // Main progress arc in blue (#1E90FF)
    final progressPaint = Paint()
      ..color =
          const Color(0xFF1E90FF) // Primary accent blue
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          strokeWidth // Same width as background ring
      ..strokeCap = StrokeCap.round; // Rounded ends

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw the arc from 12 o'clock position, clockwise
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at top (12 o'clock = -90 degrees)
      2 *
          math.pi *
          actualProgress, // Sweep angle - NO RESET, continuous progress
      false, // Don't use center (creates arc, not pie slice)
      progressPaint,
    );
  }

  void _drawProgressDots(Canvas canvas, Offset center, double radius) {
    if (progress <= 0) return; // Don't draw if no progress

    // ===== WHITE DOTS ON PROGRESS RING =====
    // Small white dots layered on top of the blue arc
    final dotCount = 120; // 120 dots around the full circle
    final dotRadius = 1.5; // Small dots (1.5px radius)
    final dotPaint = Paint()
      ..color = Colors
          .white // White to stand out on blue
      ..style = PaintingStyle.fill;

    // Calculate actual progress for dot display
    double actualProgress = progress;
    if (isUnlimited) {
      actualProgress =
          currentCount / 100.0; // Continuous progress without reset
    }

    // Draw dots only where progress exists
    // For continuous progress > 1.0, we need to handle multiple revolutions
    final totalDotsToShow = (actualProgress * dotCount).floor();

    for (int i = 0; i < totalDotsToShow; i++) {
      final dotIndex = i % dotCount; // Wrap around for multiple revolutions
      final dotProgress =
          dotIndex / dotCount; // Position of this dot (0.0 to 1.0)

      final angle = -math.pi / 2 + (2 * math.pi * dotProgress);
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }
  }

  void _drawMilestones(Canvas canvas, Offset center, double radius) {
    final milestonePaint = Paint()
      ..color = const Color(0xFF1E90FF)
      ..style = PaintingStyle.fill;

    for (final milestone in milestones) {
      if (currentCount >= milestone) {
        final angle = -math.pi / 2; // Position at top for now
        final milestoneX = center.dx + math.cos(angle) * radius;
        final milestoneY = center.dy + math.sin(angle) * radius;

        canvas.drawCircle(Offset(milestoneX, milestoneY), 4, milestonePaint);
      }
    }
  }

  void _drawProgressEndpoint(Canvas canvas, Offset center, double radius) {
    // ===== ENDPOINT BADGE (PROGRESS INDICATOR) =====
    // Blue circular badge with white center dot at the end of progress arc
    if (endpointProgress > 0) {
      // Use modulo to handle values > 1.0 (for continuous rotation)
      final normalizedProgress = endpointProgress % 1.0;
      final endAngle = -math.pi / 2 + (2 * math.pi * normalizedProgress);
      final badgeRadius = radius;
      final badgeX = center.dx + badgeRadius * math.cos(endAngle);
      final badgeY = center.dy + badgeRadius * math.sin(endAngle);

      // Outer blue circle (badge container)
      final badgePaint = Paint()
        ..color =
            const Color(0xFF1E90FF) // Same blue as progress arc
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(badgeX, badgeY),
        16, // 16px radius for outer circle
        badgePaint,
      );

      // Inner white circle (indicator dot)
      final iconPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(badgeX, badgeY),
        4, // 4px radius for inner white dot
        iconPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ClockFaceProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.endpointProgress != endpointProgress ||
        oldDelegate.currentCount != currentCount ||
        oldDelegate.isUnlimited != isUnlimited;
  }
}
