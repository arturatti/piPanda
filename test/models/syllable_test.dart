import 'package:flutter_test/flutter_test.dart';
import 'package:syllables_apk/models/syllable.dart';

void main() {
  group('Syllable.fromText transliteration', () {
    test('basic CV syllables', () {
      expect(Syllable.fromText('Ма').audioKey, 'ma');
      expect(Syllable.fromText('Ро').audioKey, 'ro');
      expect(Syllable.fromText('Ка').audioKey, 'ka');
      expect(Syllable.fromText('Те').audioKey, 'te');
    });

    test('iotated vowels', () {
      expect(Syllable.fromText('Ря').audioKey, 'rya');
      expect(Syllable.fromText('Ню').audioKey, 'nyu');
      expect(Syllable.fromText('Ё').audioKey, 'yo');
    });

    test('soft sign disappears', () {
      expect(Syllable.fromText('Аль').audioKey, 'al');
      expect(Syllable.fromText('Ть').audioKey, 't');
    });

    test('multi-char letters', () {
      expect(Syllable.fromText('Ща').audioKey, 'scha');
      expect(Syllable.fromText('Жо').audioKey, 'zho');
      expect(Syllable.fromText('Цы').audioKey, 'tsy');
    });

    test('VC syllables', () {
      expect(Syllable.fromText('Ап').audioKey, 'ap');
      expect(Syllable.fromText('Ов').audioKey, 'ov');
      expect(Syllable.fromText('Об').audioKey, 'ob');
    });
  });

  group('Syllable equality', () {
    test('same text → equal', () {
      expect(Syllable.fromText('Ма'), Syllable.fromText('Ма'));
      expect(
        Syllable.fromText('Ма').hashCode,
        Syllable.fromText('Ма').hashCode,
      );
    });

    test('different text → not equal', () {
      expect(Syllable.fromText('Ма') == Syllable.fromText('Мо'), false);
    });
  });
}
