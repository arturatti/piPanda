import 'package:flutter_test/flutter_test.dart';
import 'package:syllables_apk/models/progress.dart';

void main() {
  group('ProgressEntry.addRound', () {
    test('increments plays and accumulates mistakes', () {
      var entry = ProgressEntry.empty('Ворона');
      entry = entry.addRound(mistakes: {'Ро': 2}, starsForRound: 2);
      entry = entry.addRound(mistakes: {'Ро': 1, 'На': 3}, starsForRound: 1);

      expect(entry.plays, 2);
      expect(entry.mistakesPerSyllable, {'Ро': 3, 'На': 3});
      expect(entry.stars, [2, 1]);
      expect(entry.totalMistakes, 6);
      expect(entry.averageStars, 1.5);
    });
  });

  group('OverallProgress', () {
    test('withRound creates entry and bumps totals', () {
      final p = OverallProgress.empty.withRound(
        wordKey: 'Малина',
        mistakes: {'Ли': 1},
        starsForRound: 3,
      );
      expect(p.entries.length, 1);
      expect(p.totalRounds, 1);
      expect(p.entries['Малина']!.stars, [3]);
    });

    test('round-trip JSON', () {
      var p = OverallProgress.empty
          .withRound(wordKey: 'Ма', mistakes: const {}, starsForRound: 3)
          .withRound(wordKey: 'Ро', mistakes: {'Ро': 2}, starsForRound: 1);

      final json = p.toJson();
      final restored = OverallProgress.fromJson(json);

      expect(restored.totalRounds, p.totalRounds);
      expect(restored.entries.length, p.entries.length);
      expect(restored.entries['Ро']!.totalMistakes, 2);
    });
  });
}
