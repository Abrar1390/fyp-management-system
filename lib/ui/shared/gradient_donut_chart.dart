import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GradientDonutChart extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int pending;
  final String centerText;
  final String centerSubText;

  const GradientDonutChart({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.centerText,
    required this.centerSubText,
  });

  @override
  Widget build(BuildContext context) {
    int total = completed + inProgress + pending;
    
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 70,
              sections: _showingSections(context, total),
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                centerSubText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ).animate().fade(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(BuildContext context, int total) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.withOpacity(0.2),
          value: 100,
          title: '',
          radius: 20,
        )
      ];
    }
    
    return [
      PieChartSectionData(
        color: const Color(0xFF10B981), // Emerald
        value: completed.toDouble(),
        title: completed > 0 ? '$completed' : '',
        radius: 25,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: const Color(0xFFF59E0B), // Amber
        value: inProgress.toDouble(),
        title: inProgress > 0 ? '$inProgress' : '',
        radius: 25,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: const Color(0xFFEF4444), // Red
        value: pending.toDouble(),
        title: pending > 0 ? '$pending' : '',
        radius: 25,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
}
