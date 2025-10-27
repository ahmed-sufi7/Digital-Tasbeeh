import 'package:flutter/cupertino.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class ChartLoadingAnimation extends StatefulWidget {
  final bool isDark;
  final String? message;
  final double height;

  const ChartLoadingAnimation({
    super.key,
    required this.isDark,
    this.message,
    this.height = 280,
  });

  @override
  State<ChartLoadingAnimation> createState() => _ChartLoadingAnimationState();
}

class _ChartLoadingAnimationState extends State<ChartLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(widget.isDark).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingIndicator(),
            const SizedBox(height: 16),
            _buildLoadingText(),
            if (widget.message != null) ...[
              const SizedBox(height: 8),
              _buildMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_pulseAnimation.value - 0.8) * 1.25,
          child: Text(
            'Loading chart data...',
            style: AppTextStyles.bodyMedium(widget.isDark).copyWith(
              color: AppColors.textSecondaryColor(widget.isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage() {
    return Text(
      widget.message!,
      style: AppTextStyles.bodySmall(widget.isDark).copyWith(
        color: AppColors.textSecondaryColor(widget.isDark).withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ChartErrorState extends StatelessWidget {
  final bool isDark;
  final String error;
  final VoidCallback? onRetry;
  final double height;

  const ChartErrorState({
    super.key,
    required this.isDark,
    required this.error,
    this.onRetry,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(isDark).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading chart',
              style: AppTextStyles.bodyLarge(isDark).copyWith(
                color: AppColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium(
                isDark,
              ).copyWith(color: AppColors.textSecondaryColor(isDark)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: onRetry,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary,
                child: Text(
                  'Retry',
                  style: AppTextStyles.bodyMedium(false).copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
