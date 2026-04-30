import 'package:flutter/material.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/responsive.dart';

class SyllableCard extends StatefulWidget {
  final Syllable syllable;
  final bool draggable;
  final VoidCallback? onDragStart;
  final double? width;
  final double? height;

  const SyllableCard({
    super.key,
    required this.syllable,
    this.draggable = true,
    this.onDragStart,
    this.width,
    this.height,
  });

  @override
  State<SyllableCard> createState() => _SyllableCardState();
}

class _SyllableCardState extends State<SyllableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(
      context,
      widget.syllable.text.toUpperCase(),
      pressed: _pressed,
    );

    if (!widget.draggable) return card;

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: Draggable<Syllable>(
        data: widget.syllable,
        onDragStarted: () {
          setState(() => _pressed = false);
          widget.onDragStart?.call();
        },
        feedback: Material(
          type: MaterialType.transparency,
          child: Transform.scale(
            scale: 1.12,
            child: _buildCard(
              context,
              widget.syllable.text.toUpperCase(),
              elevated: true,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: _buildCard(context, widget.syllable.text.toUpperCase()),
        ),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: card,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String text, {
    bool pressed = false,
    bool elevated = false,
  }) {
    final s = tabletScale(context);
    final w = widget.width ?? 84 * s;
    final h = widget.height ?? 72 * s;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF1DB)],
        ),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppTheme.primary, width: 2.5),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  offset: const Offset(0, 10),
                  blurRadius: 22,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: pressed ? 0.10 : 0.18),
                  offset: Offset(0, pressed ? 2 : 5),
                  blurRadius: pressed ? 6 : 12,
                ),
              ],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 6 * s,
            top: 4 * s,
            child: Icon(
              Icons.eco_rounded,
              size: h * 0.22,
              color: AppTheme.success.withValues(alpha: 0.09),
            ),
          ),
          Positioned(
            left: 4 * s,
            bottom: 4 * s,
            child: Icon(
              Icons.star_rounded,
              size: h * 0.18,
              color: AppTheme.sunshine.withValues(alpha: 0.11),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 4 * s),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: h * 0.58,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: 2,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
