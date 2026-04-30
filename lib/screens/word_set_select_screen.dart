import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllables_apk/models/word_set.dart';
import 'package:syllables_apk/screens/mode_select_screen.dart';
import 'package:syllables_apk/state/providers.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/page_transitions.dart';
import 'package:syllables_apk/utils/responsive.dart';
import 'package:syllables_apk/widgets/screen_background.dart';

class WordSetSelectScreen extends ConsumerWidget {
  const WordSetSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Выбери набор')),
      body: ScreenBackground(
        name: 'home',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final isWide = constraints.maxWidth >= 720;
              final crossAxisCount = (isLandscape || isWide) ? 3 : 2;
              final s = tabletScale(context);
              return GridView.count(
                padding: EdgeInsets.all(16 * s),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14 * s,
                mainAxisSpacing: 14 * s,
                childAspectRatio: 0.95,
                children: [
                  for (final set in WordSet.all) _SetCard(set: set, ref: ref),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SetCard extends StatefulWidget {
  final WordSet set;
  final WidgetRef ref;
  const _SetCard({required this.set, required this.ref});

  @override
  State<_SetCard> createState() => _SetCardState();
}

class _SetCardState extends State<_SetCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    final set = widget.set;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24 * s),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: () {
            widget.ref.read(currentWordSetProvider.notifier).state = set;
            Navigator.of(
              context,
            ).push(fadeScalePageRoute((_) => const ModeSelectScreen()));
          },
          child: Container(
            padding: EdgeInsets.all(16 * s),
            decoration: BoxDecoration(
              gradient: AppTheme.modeGradient(set.color),
              borderRadius: BorderRadius.circular(24 * s),
              boxShadow: [
                BoxShadow(
                  color: set.color.withValues(alpha: 0.45),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 110 * s,
                  height: 110 * s,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.30),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8 * s),
                  alignment: Alignment.center,
                  child: set.heroImage != null
                      ? Image.asset(
                          set.heroImage!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              Icon(set.icon, color: Colors.white, size: 56 * s),
                        )
                      : Icon(set.icon, color: Colors.white, size: 56 * s),
                ),
                SizedBox(height: 14 * s),
                Text(
                  set.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  set.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
