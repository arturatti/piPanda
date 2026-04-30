import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/widgets/mascot.dart';
import 'package:syllables_apk/widgets/star_row.dart';

class CelebrationOverlay extends StatefulWidget {
  final bool show;
  final int stars;
  final String word;
  final String? imageFile;

  const CelebrationOverlay({
    super.key,
    required this.show,
    this.stars = 0,
    this.word = '',
    this.imageFile,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.show) _controller.play();
  }

  @override
  void didUpdateWidget(covariant CelebrationOverlay old) {
    super.didUpdateWidget(old);
    if (widget.show && !old.show) _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _title(int stars) {
    switch (stars) {
      case 3:
        return 'Великолепно!';
      case 2:
        return 'Молодец!';
      case 1:
        return 'Получилось!';
      default:
        return 'Отлично!';
    }
  }

  MascotPose _mascotPose(int stars) {
    switch (stars) {
      case 3:
        return MascotPose.cheer;
      case 2:
        return MascotPose.smile;
      default:
        return MascotPose.think;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return IgnorePointer(
        child: SizedBox.shrink(
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
          ),
        ),
      );
    }

    final stars = widget.stars;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.black.withValues(alpha: 0.18)),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 36,
            maxBlastForce: 32,
            minBlastForce: 14,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [
              AppTheme.primary,
              AppTheme.mint,
              AppTheme.sunshine,
              AppTheme.secondary,
              AppTheme.violet,
              AppTheme.sky,
            ],
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            constraints: const BoxConstraints(maxWidth: 460),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.30),
                  offset: const Offset(0, 12),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Mascot(pose: _mascotPose(stars), size: 140)
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 600.ms,
                    ),
                const SizedBox(height: 8),
                Text(
                  _title(stars),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 300.ms).moveY(begin: 8, end: 0),
                const SizedBox(height: 16),
                StarRow(
                  filled: stars,
                  size: 56,
                  animate: true,
                  startDelay: 350.ms,
                ),
                if (widget.word.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    widget.word.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ).animate(delay: 1500.ms).fadeIn(duration: 400.ms),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
