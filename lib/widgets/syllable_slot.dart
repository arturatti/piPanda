import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/responsive.dart';

class SyllableSlot extends StatelessWidget {
  final Syllable? filledWith;
  final bool isHinted;
  final bool isHighlighted;
  final bool animationsEnabled;
  final ValueChanged<Syllable> onAccept;
  final double? width;
  final double? height;

  const SyllableSlot({
    super.key,
    required this.filledWith,
    required this.isHinted,
    this.isHighlighted = false,
    required this.animationsEnabled,
    required this.onAccept,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    final w = width ?? 84 * s;
    final h = height ?? 72 * s;
    return DragTarget<Syllable>(
      onWillAcceptWithDetails: (_) => filledWith == null,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final hovered = candidate.isNotEmpty;
        final filled = filledWith != null;

        final highlight = isHighlighted && !filled;
        Widget child = AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: w,
          height: h,
          decoration: BoxDecoration(
            gradient: filled
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFD9B8), Color(0xFFFFB997)],
                  )
                : (hovered || highlight)
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFEFC1), Color(0xFFFFE08A)],
                  )
                : null,
            color: filled || hovered || highlight ? null : AppTheme.slotEmpty,
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(
              color: filled
                  ? AppTheme.primary
                  : (hovered || highlight)
                  ? AppTheme.sunshine
                  : AppTheme.primary.withValues(alpha: 0.35),
              width: filled ? 3 : (highlight ? 3 : 2.5),
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.30),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : highlight
                ? [
                    BoxShadow(
                      color: AppTheme.sunshine.withValues(alpha: 0.50),
                      offset: const Offset(0, 0),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (childW, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: childW),
            ),
            child: filled
                ? Padding(
                    key: ValueKey(filledWith!.text),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * s,
                      vertical: 4 * s,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        filledWith!.text.toUpperCase(),
                        style: TextStyle(
                          fontSize: h * 0.58,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: 2,
                          height: 1.0,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );

        if (isHinted && animationsEnabled) {
          child = child
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 900.ms, color: AppTheme.sunshine);
        } else if (!filled && animationsEnabled) {
          child = child
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn()
              .scaleXY(
                begin: 1.0,
                end: 1.025,
                duration: 1400.ms,
                curve: Curves.easeInOut,
              );
        }

        return child;
      },
    );
  }
}
