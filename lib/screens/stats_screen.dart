import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllables_apk/models/progress.dart';
import 'package:syllables_apk/models/word.dart';
import 'package:syllables_apk/models/word_set.dart';
import 'package:syllables_apk/state/providers.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/responsive.dart';
import 'package:syllables_apk/widgets/mascot.dart';
import 'package:syllables_apk/widgets/screen_background.dart';
import 'package:syllables_apk/widgets/star_row.dart';

(WordSet?, String) _splitWordKey(String key) {
  final i = key.indexOf(':');
  if (i < 0) return (null, key);
  final setName = key.substring(0, i);
  final wordText = key.substring(i + 1);
  return (WordSet.byName(setName), wordText);
}

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider);
    final allWords = ref.watch(allWordsProvider).valueOrNull ?? const <String, Word>{};
    final s = tabletScale(context);

    final entries = progress.entries.values.toList()
      ..sort((a, b) => b.plays.compareTo(a.plays));

    final problematic = entries.toList()
      ..sort((a, b) => b.totalMistakes.compareTo(a.totalMistakes));
    final top5Problematic =
        problematic.where((e) => e.totalMistakes > 0).take(5).toList();
    final maxMistakes = top5Problematic.isEmpty ? 1 : top5Problematic.first.totalMistakes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Прогресс'),
        actions: [
          IconButton(
            tooltip: 'Сбросить прогресс',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ScreenBackground(
        name: 'home',
        child: SafeArea(
          child: progress.entries.isEmpty
              ? _Empty()
              : ListView(
                  padding: EdgeInsets.all(16 * s),
                  children: [
                    _Summary(progress: progress),
                    if (top5Problematic.isNotEmpty) ...[
                      SizedBox(height: 24 * s),
                      const _SectionTitle('Сложные слова'),
                      SizedBox(height: 8 * s),
                      for (final e in top5Problematic)
                        _ProblematicCard(
                          entry: e,
                          word: allWords[e.wordKey] ?? allWords['standard:${e.wordKey}'],
                          maxMistakes: maxMistakes,
                        ),
                    ],
                    SizedBox(height: 24 * s),
                    const _SectionTitle('Все пройденные слова'),
                    SizedBox(height: 8 * s),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10 * s,
                      crossAxisSpacing: 10 * s,
                      childAspectRatio: 2.4,
                      children: [
                        for (final e in entries)
                          _WordCard(entry: e, word: allWords[e.wordKey] ?? allWords['standard:${e.wordKey}']),
                      ],
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

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(pose: MascotPose.idle, size: 160),
            const SizedBox(height: 16),
            const Text(
              'Пока нет статистики.\nСыграй пару раундов!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final OverallProgress progress;
  const _Summary({required this.progress});

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    final totalStars = progress.entries.values.fold<int>(
      0,
      (sum, e) => sum + e.stars.fold<int>(0, (s, n) => s + n),
    );
    final totalRounds = progress.totalRounds;

    return Container(
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        gradient: AppTheme.modeGradient(AppTheme.primary),
        borderRadius: BorderRadius.circular(24 * s),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          const Mascot(pose: MascotPose.smile, size: 88),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Молодец!',
                  style: TextStyle(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(label: 'Раундов', value: '$totalRounds'),
                    _StatItem(label: 'Слов', value: '${progress.entries.length}'),
                    _StatItem(label: 'Звёзд', value: '$totalStars'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final ProgressEntry entry;
  final Word? word;
  const _WordCard({required this.entry, required this.word});

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    final avg = entry.averageStars.round().clamp(0, 3);
    final (set, wordText) = _splitWordKey(entry.wordKey);
    final accent = set?.color ?? AppTheme.primary;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border(left: BorderSide(color: accent, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          if (word != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10 * s),
              child: Image.asset(
                'assets/images/words/${word!.imageFile}',
                width: 40 * s,
                height: 40 * s,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 40 * s,
                  height: 40 * s,
                  color: AppTheme.softYellow,
                ),
              ),
            ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  wordText,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'x${entry.plays}',
                  style: TextStyle(
                    fontSize: 11 * s,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2 * s),
                StarRow(filled: avg, total: 3, size: 16 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblematicCard extends StatelessWidget {
  final ProgressEntry entry;
  final Word? word;
  final int maxMistakes;

  const _ProblematicCard({
    required this.entry,
    required this.word,
    required this.maxMistakes,
  });

  @override
  Widget build(BuildContext context) {
    final s = tabletScale(context);
    final ratio = entry.totalMistakes / maxMistakes;
    final indicatorColor = ratio > 0.7
        ? AppTheme.secondary
        : ratio > 0.4
            ? AppTheme.sunshine
            : AppTheme.success;
    final worst = entry.mistakesPerSyllable.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * s),
                bottomLeft: Radius.circular(16 * s),
              ),
            ),
          ),
          if (word != null)
            Padding(
              padding: EdgeInsets.all(8 * s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10 * s),
                child: Image.asset(
                  'assets/images/words/${word!.imageFile}',
                  width: 40 * s,
                  height: 40 * s,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    width: 40 * s,
                    height: 40 * s,
                    color: AppTheme.softYellow,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _splitWordKey(entry.wordKey).$2,
                    style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    'ошибок: ${entry.totalMistakes}'
                    '${worst.isNotEmpty ? " · ${worst.take(3).map((e) => '${e.key}:${e.value}').join(', ')}" : ""}',
                    style: TextStyle(fontSize: 12 * s, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
