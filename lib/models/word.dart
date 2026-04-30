import 'package:syllables_apk/models/syllable.dart';

class Word {
  final String text;
  final List<Syllable> syllables;
  final String imageFile;

  const Word({
    required this.text,
    required this.syllables,
    required this.imageFile,
  });

  String get audioKey => Syllable.fromText(text.toLowerCase()).audioKey;

  @override
  String toString() => 'Word($text)';
}
