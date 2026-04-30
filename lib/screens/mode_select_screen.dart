import 'package:flutter/material.dart';
import 'package:syllables_apk/models/game_mode.dart';
import 'package:syllables_apk/screens/game_screen.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/page_transitions.dart';
import 'package:syllables_apk/utils/responsive.dart';
import 'package:syllables_apk/widgets/screen_background.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Выбери режим')),
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
                  for (final mode in GameMode.all) _ModeCard(mode: mode),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final GameMode mode;
  const _ModeCard({required this.mode});

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    final mode = widget.mode;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24 * s),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: () => Navigator.of(
            context,
          ).push(fadeScalePageRoute((_) => GameScreen(mode: mode))),
          child: Container(
            padding: EdgeInsets.all(16 * s),
            decoration: BoxDecoration(
              gradient: AppTheme.modeGradient(mode.color),
              borderRadius: BorderRadius.circular(24 * s),
              boxShadow: [
                BoxShadow(
                  color: mode.color.withValues(alpha: 0.45),
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
                  width: 72 * s,
                  height: 72 * s,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(mode.icon, color: Colors.white, size: 40 * s),
                ),
                SizedBox(height: 14 * s),
                Text(
                  mode.title,
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
                  mode.description,
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
