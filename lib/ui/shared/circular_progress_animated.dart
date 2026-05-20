import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CircularProgressAnimated extends StatelessWidget {
  final double percentage; // 0.0 to 100.0
  final double size;
  final double strokeWidth;

  const CircularProgressAnimated({
    super.key,
    required this.percentage,
    this.size = 80.0,
    this.strokeWidth = 8.0,
  });

  Color _getProgressColor() {
    if (percentage < 30) return const Color(0xFFEF4444); // Red
    if (percentage < 70) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFF10B981); // Green
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: percentage / 100),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              );
            },
          ),
          Text(
            '${percentage.toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: size * 0.25,
            ),
          ).animate().fade(delay: 500.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
