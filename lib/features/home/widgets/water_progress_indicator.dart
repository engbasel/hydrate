import 'package:flutter/material.dart';
import 'dart:math';

class WaterProgressIndicator extends StatefulWidget {
  final double currentIntake;
  final double dailyGoal;

  const WaterProgressIndicator({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
  });

  @override
  State<WaterProgressIndicator> createState() => _WaterProgressIndicatorState();
}

class _WaterProgressIndicatorState extends State<WaterProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.currentIntake / widget.dailyGoal,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(WaterProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIntake != widget.currentIntake ||
        oldWidget.dailyGoal != widget.dailyGoal) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.currentIntake / widget.dailyGoal,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentIntake / widget.dailyGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Daily Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: CircularProgressPainter(
                      progress: _animation.value.clamp(0.0, 1.0),
                      backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      progressColor: _getProgressColor(progress),
                      strokeWidth: 12,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            progress >= 1.0 ? Icons.celebration : Icons.water_drop,
                            color: _getProgressColor(progress),
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$percentage%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(progress),
                            ),
                          ),
                          if (progress >= 1.0)
                            Text(
                              'Goal Achieved! 🎉',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getProgressColor(progress),
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              '${((1.0 - progress) * 100).toInt()}% to go',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (progress >= 1.0) {
      return isDark ? Colors.green.shade400 : Colors.green.shade600;
    }
    if (progress >= 0.75) {
      return isDark ? Colors.lightGreen.shade400 : Colors.lightGreen.shade600;
    }
    if (progress >= 0.5) {
      return Theme.of(context).colorScheme.primary;
    }
    if (progress >= 0.25) {
      return isDark ? Colors.orange.shade400 : Colors.orange.shade600;
    }
    return isDark ? Colors.red.shade400 : Colors.red.shade600;
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
