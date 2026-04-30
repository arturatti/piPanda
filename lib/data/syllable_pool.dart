import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/models/word.dart';

class SyllablePool {
  final List<Syllable> all;

  SyllablePool(this.all);

  factory SyllablePool.fromWords(List<Word> words) {
    final unique = <String, Syllable>{};
    for (final w in words) {
      for (final s in w.syllables) {
        unique[s.text] = s;
      }
    }
    return SyllablePool(unique.values.toList());
  }

  List<Syllable> randomDistractors({
    required List<Syllable> exclude,
    required int count,
  }) {
    final excludeTexts = exclude.map((s) => s.text).toSet();
    final candidates = all.where((s) => !excludeTexts.contains(s.text)).toList();
    candidates.shuffle();
    return candidates.take(count).toList();
  }
}
