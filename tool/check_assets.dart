import 'dart:io';

const _setDirs = ['standard', 'dinosaurs', 'reptiles'];

void main() {
  final missingImages = <String>[];
  final missingWordAudio = <String>[];
  final allSyllables = <String>{};
  var totalLines = 0;

  for (final setDir in _setDirs) {
    final wordsFile = File('assets/data/$setDir/words.txt');
    if (!wordsFile.existsSync()) {
      stderr.writeln('Skipping $setDir: words.txt not found');
      continue;
    }

    final lines = wordsFile
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    print('--- $setDir (${lines.length} words) ---');
    totalLines += lines.length;

    for (final line in lines) {
      final parts = line.split('|');
      if (parts.length != 3) {
        stderr.writeln('Bad line in $setDir: "$line"');
        continue;
      }
      final word = parts[0].trim();
      final syllables = parts[1].trim().split('-');
      final image = parts[2].trim();

      final imagePath = 'assets/images/words/$setDir/$image';
      if (!File(imagePath).existsSync()) {
        missingImages.add('  [$setDir] $word -> $imagePath');
      }

      final wordKey = _transliterate(word.toLowerCase());
      if (!_audioExists('assets/audio/words/$wordKey')) {
        missingWordAudio.add(
          '  [$setDir] $word -> assets/audio/words/$wordKey.{mp3,wav,m4a,ogg}',
        );
      }

      for (final s in syllables) {
        allSyllables.add(s);
      }
    }
  }

  final missingSyllableAudio = <String>[];
  for (final s in allSyllables) {
    final key = _transliterate(s.toLowerCase());
    if (!_audioExists('assets/audio/syllables/$key')) {
      missingSyllableAudio.add(
        '  $s -> assets/audio/syllables/$key.{mp3,wav,m4a,ogg}',
      );
    }
  }

  final uiSounds = ['success', 'drop_correct', 'drop_wrong'];
  final missingUi = <String>[];
  for (final name in uiSounds) {
    if (!_audioExists('assets/audio/ui/$name')) {
      missingUi.add('  assets/audio/ui/$name.{mp3,wav,m4a,ogg}');
    }
  }

  print('');
  print('=== Asset check (all sets) ===');
  print('Total words: $totalLines');
  print('Unique syllables: ${allSyllables.length}');
  print('');

  _report('Missing images', missingImages);
  _report('Missing word audio', missingWordAudio);
  _report('Missing syllable audio', missingSyllableAudio);
  _report('Missing UI sounds', missingUi);

  final totalMissing =
      missingImages.length +
      missingWordAudio.length +
      missingSyllableAudio.length +
      missingUi.length;
  if (totalMissing == 0) {
    print('All assets present.');
    exit(0);
  } else {
    print('TOTAL MISSING: $totalMissing');
    exit(2);
  }
}

void _report(String title, List<String> missing) {
  if (missing.isEmpty) {
    print('$title: OK');
  } else {
    print('$title (${missing.length}):');
    for (final m in missing) {
      print(m);
    }
  }
  print('');
}

const Map<String, String> _map = {
  'а': 'a',
  'б': 'b',
  'в': 'v',
  'г': 'g',
  'д': 'd',
  'е': 'e',
  'ё': 'yo',
  'ж': 'zh',
  'з': 'z',
  'и': 'i',
  'й': 'j',
  'к': 'k',
  'л': 'l',
  'м': 'm',
  'н': 'n',
  'о': 'o',
  'п': 'p',
  'р': 'r',
  'с': 's',
  'т': 't',
  'у': 'u',
  'ф': 'f',
  'х': 'h',
  'ц': 'ts',
  'ч': 'ch',
  'ш': 'sh',
  'щ': 'sch',
  'ъ': '',
  'ы': 'y',
  'ь': '',
  'э': 'e',
  'ю': 'yu',
  'я': 'ya',
};

bool _audioExists(String basePath) {
  for (final ext in const ['mp3', 'wav', 'm4a', 'ogg']) {
    if (File('$basePath.$ext').existsSync()) return true;
  }
  return false;
}

String _transliterate(String s) {
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    buf.write(_map[ch] ?? ch);
  }
  return buf.toString();
}
