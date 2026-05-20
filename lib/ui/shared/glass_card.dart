import 'package:flutter/material.dart';

/// A glassmorphism-style card with optional gradient border, blur, and glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? tintColor;
  final double tintOpacity;
  final bool showBorder;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.tintColor,
    this.tintOpacity = 0.06,
    this.showBorder = true,
    this.borderColor,
    this.shadows,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);
    final tint = tintColor ??
        (isDark ? Colors.white.withOpacity(tintOpacity) : Colors.white);
    final border = borderColor ??
        (isDark
            ? Colors.white.withOpacity(0.08)
            : Theme.of(context).dividerColor);

    final shadow = shadows ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            const BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
        ];

    Widget card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? tint : Colors.white,
        borderRadius: radius,
        border: showBorder ? Border.all(color: border, width: 1) : null,
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Gradient-bordered card for hero sections and featured elements.
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final double borderWidth;
  final Color? backgroundColor;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.borderWidth = 1.5,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final gradient = gradientColors ??
        [
          const Color(0xFF0F9D8A),
          const Color(0xFF10B981),
          const Color(0xFF14B8A6),
        ];
    final bg = backgroundColor ?? Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(colors: gradient),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius.topLeft.x - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
