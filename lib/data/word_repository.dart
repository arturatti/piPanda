import 'package:flutter/services.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/models/word.dart';
import 'package:syllables_apk/models/word_set.dart';

class WordRepository {
  Future<List<Word>> loadSet(WordSet set) async {
    final raw = await rootBundle.loadString(set.dataPath);
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => _parseLine(line, set))
        .toList();
  }

  Word _parseLine(String line, WordSet set) {
    final parts = line.split('|');
    if (parts.length != 3) {
      throw FormatException('Invalid line in ${set.dataPath}: "$line"');
    }
    final text = parts[0].trim();
    final syllableTexts = parts[1].trim().split('-');
    final image = '${set.imagesSubdir}/${parts[2].trim()}';
    return Word(
      text: text,
      syllables: syllableTexts.map(Syllable.fromText).toList(),
      imageFile: image,
    );
  }
}
