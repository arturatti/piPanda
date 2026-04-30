import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syllables_apk/screens/settings_screen.dart';
import 'package:syllables_apk/screens/stats_screen.dart';
import 'package:syllables_apk/screens/word_set_select_screen.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/page_transitions.dart';
import 'package:syllables_apk/utils/responsive.dart';
import 'package:syllables_apk/widgets/mascot.dart';
import 'package:syllables_apk/widgets/screen_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        name: 'home',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final s = tabletScale(context);
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final mascotSize = isLandscape
                  ? (constraints.maxHeight * 0.55).clamp(160.0, 320.0 * s)
                  : (constraints.maxHeight * 0.30).clamp(140.0, 240.0 * s);
              final mascot = Mascot(pose: MascotPose.idle, size: mascotSize)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: 0,
                    end: -8,
                    duration: 1600.ms,
                    curve: Curves.easeInOut,
                  );
              final content = _Menu(scale: s);

              if (isLandscape) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Row(
                    children: [
                      Expanded(child: Center(child: mascot)),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(vertical: 16 * s),
                          child: content,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 16 * s),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      mascot,
                      SizedBox(height: 8 * s),
                      content,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final double scale;
  const _Menu({required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20 * s),
          ),
          child: ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
            ).createShader(rect),
            child: Text(
              'piPanda',
              style: TextStyle(
                fontSize: 64 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(14 * s),
          ),
          child: Text(
            'Учимся читать по слогам',
            style: TextStyle(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        SizedBox(height: 28 * s),
        _ChunkyButton(
          label: 'Играть',
          icon: Icons.play_arrow_rounded,
          color: AppTheme.primary,
          onTap: () => Navigator.of(
            context,
          ).push(fadeScalePageRoute((_) => const WordSetSelectScreen())),
        ),
        SizedBox(height: 14 * s),
        _ChunkyButton(
          label: 'Прогресс',
          icon: Icons.emoji_events_rounded,
          color: AppTheme.mint,
          onTap: () => Navigator.of(
            context,
          ).push(fadeScalePageRoute((_) => const StatsScreen())),
        ),
        SizedBox(height: 14 * s),
        _ChunkyButton(
          label: 'Настройки',
          icon: Icons.settings_rounded,
          color: AppTheme.sky,
          onTap: () => Navigator.of(
            context,
          ).push(fadeScalePageRoute((_) => const SettingsScreen())),
        ),
      ],
    );
  }
}

class _ChunkyButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ChunkyButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<_ChunkyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 280 * s,
            height: 72 * s,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient(widget.color),
              borderRadius: BorderRadius.circular(36 * s),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.45),
                  offset: Offset(0, _pressed ? 2 : 6),
                  blurRadius: _pressed ? 6 : 14,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 30 * s),
                SizedBox(width: 12 * s),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 24 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
