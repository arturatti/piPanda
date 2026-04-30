import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syllables_apk/models/game_mode.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/state/providers.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/responsive.dart';
import 'package:syllables_apk/widgets/celebration_overlay.dart';
import 'package:syllables_apk/widgets/round_progress.dart';
import 'package:syllables_apk/widgets/screen_background.dart';
import 'package:syllables_apk/widgets/syllable_card.dart';
import 'package:syllables_apk/widgets/syllable_slot.dart';
import 'package:syllables_apk/widgets/word_image.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameMode mode;

  const GameScreen({super.key, required this.mode});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _scheduledNext = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameNotifierProvider(widget.mode));
    final notifier = ref.read(gameNotifierProvider(widget.mode).notifier);
    final animationsEnabled = ref.watch(
      settingsNotifierProvider.select((s) => s.animations),
    );
    final scale = tabletScale(context);

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.finished && !_scheduledNext) {
      _scheduledNext = true;
      Future.delayed(const Duration(milliseconds: 3200), () {
        if (mounted) {
          notifier.nextRound();
          setState(() => _scheduledNext = false);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: RoundProgress(
          currentIndex: state.roundIndex,
          total: state.roundsPerSession,
          sessionStars: state.sessionStars,
          modeTitle: widget.mode.title,
        ),
        actions: [
          IconButton(
            tooltip: 'Другое слово',
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: () {
              setState(() => _scheduledNext = false);
              notifier.nextRound();
            },
          ),
        ],
      ),
      body: ScreenBackground(
        name: 'game',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxH = constraints.maxHeight;
              final maxW = constraints.maxWidth;
              final imageSize = (maxH * 0.34).clamp(120.0, maxW * 0.55);
              final wordFontSize = (maxH * 0.18).clamp(56.0, 160.0 * scale);
              final spacing = (maxH * 0.012).clamp(6.0, 14.0 * scale);
              final speakerSize = (maxH * 0.10).clamp(40.0, 72.0 * scale);

              final totalCards =
                  state.word.syllables.length + widget.mode.extraSyllables;
              final cardW = ((maxW - 24 - (totalCards - 1) * 8) / totalCards)
                  .clamp(54.0, 110.0 * scale);
              final cardH = cardW * 0.86;
              final slotsCount = state.word.syllables.length;
              final slotW = ((maxW - 32 - (slotsCount - 1) * 12) / slotsCount)
                  .clamp(70.0, 130.0 * scale);
              final slotH = slotW * 0.86;

              final slotsRow = _SlotsRow(
                syllables: state.word.syllables,
                filled: state.filledSlots,
                hintIndex: state.hintSlotIndex,
                highlightIndex: state.highlightedSyllableIndex,
                animationsEnabled: animationsEnabled,
                onAccept: notifier.tryDropSyllable,
                slotW: slotW,
                slotH: slotH,
              );

              final tray = _SyllableTray(
                syllables: state.availableSyllables,
                onDragStart: notifier.onSyllableDragStart,
                animationsEnabled: animationsEnabled,
                cardW: cardW,
                cardH: cardH,
              );

              final placedFlags = [
                for (final slot in state.filledSlots) slot != null,
              ];
              final nextSlotIndex = state.filledSlots.indexWhere(
                (s) => s == null,
              );
              final wordRow = widget.mode.showWord
                  ? _WordRow(
                      syllables: state.word.syllables,
                      highlightIndex: state.highlightedSyllableIndex,
                      placedFlags: placedFlags,
                      nextIndex: nextSlotIndex >= 0 ? nextSlotIndex : null,
                      fontSize: wordFontSize,
                      animationsEnabled: animationsEnabled,
                    )
                  : const SizedBox.shrink();

              final isLandscape = maxW > maxH;
              List<Widget> children;
              if (widget.mode.showImage) {
                final image = _TappableImage(
                  imageSize: imageSize,
                  imageFile: state.word.imageFile,
                  fallbackText: state.word.text,
                  onTap: notifier.replayWordBySyllables,
                  animationsEnabled: animationsEnabled,
                );
                if (isLandscape && widget.mode.showWord) {
                  children = [
                    SizedBox(height: spacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        image,
                        SizedBox(width: spacing * 2),
                        Flexible(child: wordRow),
                      ],
                    ),
                    const Spacer(),
                    slotsRow,
                    const Spacer(),
                    tray,
                    SizedBox(height: spacing),
                  ];
                } else {
                  children = [
                    SizedBox(height: spacing),
                    image,
                    SizedBox(height: spacing),
                    if (widget.mode.showWord) wordRow,
                    const Spacer(),
                    slotsRow,
                    const Spacer(),
                    tray,
                    SizedBox(height: spacing),
                  ];
                }
              } else if (widget.mode.showWord) {
                children = [
                  const Spacer(flex: 2),
                  Center(child: wordRow),
                  SizedBox(height: spacing * 1.5),
                  Center(child: slotsRow),
                  const Spacer(flex: 2),
                  Center(child: tray),
                  SizedBox(height: spacing),
                ];
              } else {
                children = [
                  const Spacer(flex: 3),
                  Center(child: slotsRow),
                  SizedBox(height: spacing * 1.6),
                  Center(
                    child: _SpeakerButton(
                      size: speakerSize,
                      onTap: notifier.replayWordBySyllables,
                    ),
                  ),
                  const Spacer(flex: 2),
                  Center(child: tray),
                  SizedBox(height: spacing),
                ];
              }

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                  CelebrationOverlay(
                    show: state.finished,
                    stars: state.lastEarnedStars ?? 0,
                    word: state.word.text,
                    imageFile: state.word.imageFile,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TappableImage extends StatefulWidget {
  final double imageSize;
  final String imageFile;
  final String fallbackText;
  final VoidCallback onTap;
  final bool animationsEnabled;

  const _TappableImage({
    required this.imageSize,
    required this.imageFile,
    required this.fallbackText,
    required this.onTap,
    required this.animationsEnabled,
  });

  @override
  State<_TappableImage> createState() => _TappableImageState();
}

class _TappableImageState extends State<_TappableImage> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Widget image = SizedBox(
      height: widget.imageSize,
      child: WordImage(
        imageFile: widget.imageFile,
        fallbackText: widget.fallbackText,
        baseSize: widget.imageSize,
      ),
    );

    if (widget.animationsEnabled) {
      image = image
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: 1800.ms, curve: Curves.easeInOut);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: image,
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  final List<Syllable> syllables;
  final int? highlightIndex;
  final List<bool> placedFlags;
  final int? nextIndex;
  final double fontSize;
  final bool animationsEnabled;

  const _WordRow({
    required this.syllables,
    required this.highlightIndex,
    required this.placedFlags,
    required this.nextIndex,
    required this.fontSize,
    required this.animationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < syllables.length; i++) ...[
              _OutlinedSyllable(
                text: syllables[i].text.toUpperCase(),
                fontSize: fontSize,
                highlighted: highlightIndex == i,
                placed: i < placedFlags.length && placedFlags[i],
                isNext: nextIndex == i,
                animationsEnabled: animationsEnabled,
              ),
              if (i < syllables.length - 1)
                SizedBox(
                  width: fontSize * 0.18,
                  child: Center(
                    child: Container(
                      width: fontSize * 0.10,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutlinedSyllable extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool highlighted;
  final bool placed;
  final bool isNext;
  final bool animationsEnabled;

  const _OutlinedSyllable({
    required this.text,
    required this.fontSize,
    required this.highlighted,
    required this.placed,
    required this.isNext,
    required this.animationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final Color fillColor;
    if (placed) {
      fillColor = AppTheme.success;
    } else if (highlighted) {
      fillColor = AppTheme.primary;
    } else {
      fillColor = AppTheme.textDark;
    }

    final strokeWidth = (fontSize * 0.10).clamp(3.0, 10.0);
    final showGlow = isNext && !placed;
    final scale = placed
        ? 1.0
        : highlighted
        ? 1.1
        : isNext
        ? 1.05
        : 1.0;

    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 6,
      height: 1.0,
    );

    Widget text1 = Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.comfortaa(textStyle: base).copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth.toDouble()
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.white,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.comfortaa(textStyle: base).copyWith(
            color: fillColor,
            shadows: showGlow
                ? [
                    Shadow(
                      color: AppTheme.sunshine.withValues(alpha: 0.85),
                      blurRadius: fontSize * 0.35,
                    ),
                    Shadow(
                      color: AppTheme.primary.withValues(alpha: 0.55),
                      blurRadius: fontSize * 0.55,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );

    if (showGlow && animationsEnabled) {
      text1 = text1
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.06,
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: text1,
    );
  }
}

class _SpeakerButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const _SpeakerButton({required this.size, required this.onTap});

  @override
  State<_SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<_SpeakerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient(AppTheme.secondary),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondary.withValues(alpha: 0.45),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.volume_up_rounded,
            color: Colors.white,
            size: widget.size * 0.55,
          ),
        ),
      ),
    );
  }
}

class _SlotsRow extends StatelessWidget {
  final List<Syllable> syllables;
  final List<Syllable?> filled;
  final int? hintIndex;
  final int? highlightIndex;
  final bool animationsEnabled;
  final bool Function(int, Syllable) onAccept;
  final double slotW;
  final double slotH;

  const _SlotsRow({
    required this.syllables,
    required this.filled,
    required this.hintIndex,
    required this.highlightIndex,
    required this.animationsEnabled,
    required this.onAccept,
    required this.slotW,
    required this.slotH,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: List.generate(syllables.length, (index) {
        return SyllableSlot(
          filledWith: filled[index],
          isHinted: hintIndex == index,
          isHighlighted: highlightIndex == index,
          animationsEnabled: animationsEnabled,
          onAccept: (s) => onAccept(index, s),
          width: slotW,
          height: slotH,
        );
      }),
    );
  }
}

class _SyllableTray extends StatelessWidget {
  final List<Syllable> syllables;
  final void Function(Syllable) onDragStart;
  final bool animationsEnabled;
  final double cardW;
  final double cardH;

  const _SyllableTray({
    required this.syllables,
    required this.onDragStart,
    required this.animationsEnabled,
    required this.cardW,
    required this.cardH,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < syllables.length; i++)
            _animated(
              SyllableCard(
                key: ValueKey('$i:${syllables[i].text}'),
                syllable: syllables[i],
                onDragStart: () => onDragStart(syllables[i]),
                width: cardW,
                height: cardH,
              ),
              i,
            ),
        ],
      ),
    );
  }

  Widget _animated(Widget child, int index) {
    if (!animationsEnabled) return child;
    return child
        .animate()
        .fadeIn(duration: 250.ms, delay: (40 * index).ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
