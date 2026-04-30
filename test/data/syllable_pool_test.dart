import 'package:flutter_test/flutter_test.dart';
import 'package:syllables_apk/data/syllable_pool.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/models/word.dart';

Word _w(String text, List<String> syls, [String img = 'x.png']) => Word(
      text: text,
      syllables: syls.map(Syllable.fromText).toList(),
      imageFile: img,
    );

void main() {
  group('SyllablePool.fromWords', () {
    test('collects unique syllables', () {
      final pool = SyllablePool.fromWords([
        _w('Мама', ['Ма', 'ма']),
        _w('Малина', ['Ма', 'ли', 'на']),
      ]);
      final texts = pool.all.map((s) => s.text.toLowerCase()).toSet();
      expect(texts, {'ма', 'ли', 'на'});
    });
  });

  group('SyllablePool.randomDistractors', () {
    test('excludes correct syllables', () {
      final pool = SyllablePool.fromWords([
        _w('Аптека', ['Ап', 'те', 'ка']),
        _w('Молоко', ['Мо', 'ло', 'ко']),
      ]);
      final correct = [Syllable.fromText('Ап'), Syllable.fromText('те')];
      final distractors = pool.randomDistractors(exclude: correct, count: 2);

      final excludeTexts = correct.map((s) => s.text).toSet();
      for (final d in distractors) {
        expect(excludeTexts.contains(d.text), false);
      }
      expect(distractors.length, 2);
    });

    test('returns fewer than requested if pool small', () {
      final pool = SyllablePool.fromWords([
        _w('Мама', ['Ма', 'ма']),
      ]);
      final distractors = pool.randomDistractors(
        exclude: [Syllable.fromText('Ма')],
        count: 10,
      );
      expect(distractors.isEmpty, true);
    });
  });
}
