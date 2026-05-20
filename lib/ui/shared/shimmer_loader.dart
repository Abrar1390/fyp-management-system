import 'package:flutter/material.dart';

/// Shimmer loading placeholder for skeleton UI.
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1E2D45) : const Color(0xFFE2E8F0);
    final highlightColor =
        isDark ? const Color(0xFF2D3F5E) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Full-screen shimmer skeleton for dashboard cards.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(height: 32, width: 220),
          const SizedBox(height: 8),
          const ShimmerLoader(height: 16, width: 160),
          const SizedBox(height: 28),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
                4,
                (i) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerLoader(height: 36, width: 36,
                              borderRadius: BorderRadius.all(Radius.circular(10))),
                          const Spacer(),
                          const ShimmerLoader(height: 24, width: 48),
                          const SizedBox(height: 4),
                          ShimmerLoader(height: 12, width: 60 + i * 10.0),
                        ],
                      ),
                    )),
          ),
          const SizedBox(height: 24),
          const ShimmerLoader(height: 200),
          const SizedBox(height: 24),
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const ShimmerLoader(
                        height: 48, width: 48,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerLoader(height: 14, width: double.infinity),
                          const SizedBox(height: 6),
                          ShimmerLoader(height: 11, width: 100 + i * 20.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer list item for project card skeleton.
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoader(
                  height: 44, width: 44,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoader(height: 16, width: double.infinity),
                    const SizedBox(height: 6),
                    const ShimmerLoader(height: 12, width: 100),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerLoader(height: 12, width: double.infinity),
          const SizedBox(height: 4),
          const ShimmerLoader(height: 12, width: 240),
          const SizedBox(height: 14),
          const ShimmerLoader(height: 6),
        ],
      ),
    );
  }
}
