class Syllable {
  final String text;
  final String audioKey;

  const Syllable({required this.text, required this.audioKey});

  factory Syllable.fromText(String text) {
    final normalized = text.trim().toLowerCase();
    return Syllable(text: normalized, audioKey: _transliterate(normalized));
  }

  static const Map<String, String> _map = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e',
    'ё': 'yo', 'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'j', 'к': 'k',
    'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r',
    'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts',
    'ч': 'ch', 'ш': 'sh', 'щ': 'sch', 'ъ': '', 'ы': 'y', 'ь': '',
    'э': 'e', 'ю': 'yu', 'я': 'ya',
  };

  static String _transliterate(String s) {
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      buf.write(_map[ch] ?? ch);
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) => other is Syllable && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'Syllable($text)';
}
