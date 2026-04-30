import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllables_apk/state/providers.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/responsive.dart';
import 'package:syllables_apk/widgets/screen_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final s = tabletScale(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Настройки')),
      body: ScreenBackground(
        name: 'home',
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16 * s),
            children: [
              _Section(
                title: 'Громкость',
                icon: Icons.volume_up_rounded,
                color: AppTheme.sky,
                child: Row(
                  children: [
                    const Icon(Icons.volume_down, color: AppTheme.textMuted),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primary,
                          thumbColor: AppTheme.primary,
                          overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                          inactiveTrackColor: AppTheme.starEmpty,
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: settings.volume,
                          onChanged: notifier.setVolume,
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up, color: AppTheme.textMuted),
                  ],
                ),
              ),
              _Section(
                title: 'Звуковые эффекты',
                icon: Icons.music_note_rounded,
                color: AppTheme.sunshine,
                child: Switch(
                  value: settings.soundEffects,
                  onChanged: notifier.setSoundEffects,
                  activeThumbColor: AppTheme.sunshine,
                ),
              ),
              _Section(
                title: 'Анимации',
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.violet,
                child: Switch(
                  value: settings.animations,
                  onChanged: notifier.setAnimations,
                  activeThumbColor: AppTheme.violet,
                ),
              ),
              _Section(
                title: 'Фоновая музыка',
                icon: Icons.library_music_rounded,
                color: AppTheme.mint,
                child: Switch(
                  value: settings.backgroundMusic,
                  onChanged: notifier.setBackgroundMusic,
                  activeThumbColor: AppTheme.mint,
                ),
              ),
              SizedBox(height: 24 * s),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16 * s),
                  foregroundColor: AppTheme.secondary,
                  side: const BorderSide(color: AppTheme.secondary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * s),
                  ),
                ),
                onPressed: () => _confirmReset(context, ref),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Сбросить прогресс'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text('Вся статистика будет удалена. Это нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(progressNotifierProvider.notifier).reset();
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12 * s),
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14 * s),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17 * s,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
