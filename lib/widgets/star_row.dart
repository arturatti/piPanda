import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syllables_apk/theme/app_theme.dart';

class StarRow extends StatelessWidget {
  final int filled;
  final int total;
  final double size;
  final bool animate;
  final Duration startDelay;

  const StarRow({
    super.key,
    required this.filled,
    this.total = 3,
    this.size = 56,
    this.animate = false,
    this.startDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        final star = _Star(size: size, filled: isFilled);
        if (!animate || !isFilled) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.08),
            child: star,
          );
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.08),
          child: star
              .animate(delay: startDelay + (i * 350).ms)
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
                duration: 600.ms,
              )
              .fadeIn(duration: 200.ms),
        );
      }),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;
  final bool filled;

  const _Star({required this.size, required this.filled});

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE082), Color(0xFFFF9800)],
        ).createShader(rect),
        child: Icon(Icons.star_rounded, size: size, color: Colors.white),
      );
    }
    return Icon(Icons.star_rounded, size: size, color: AppTheme.starEmpty);
  }
}
