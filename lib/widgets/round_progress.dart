import 'package:flutter/material.dart';
import 'package:syllables_apk/theme/app_theme.dart';

class RoundProgress extends StatelessWidget {
  final int currentIndex;
  final int total;
  final List<int> sessionStars;
  final String modeTitle;

  const RoundProgress({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.sessionStars,
    required this.modeTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$modeTitle · ${(currentIndex + 1).clamp(1, total)} / $total',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (i) => _buildDot(i)),
        ),
      ],
    );
  }

  Widget _buildDot(int i) {
    final hasStar = i < sessionStars.length;
    final isCurrent = i == sessionStars.length && !hasStar;
    Widget content;
    if (hasStar) {
      final stars = sessionStars[i];
      Color color;
      if (stars >= 3) {
        color = AppTheme.starGold;
      } else if (stars == 2) {
        color = AppTheme.sunshine;
      } else {
        color = AppTheme.primary;
      }
      content = Icon(Icons.star_rounded, size: 18, color: color);
    } else if (isCurrent) {
      content = Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
      );
    } else {
      content = Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppTheme.starEmpty,
          shape: BoxShape.circle,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(width: 18, height: 18, child: Center(child: content)),
    );
  }
}
