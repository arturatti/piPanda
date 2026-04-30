class ProgressEntry {
  final String wordKey;
  final int plays;
  final Map<String, int> mistakesPerSyllable;
  final List<int> stars;

  const ProgressEntry({
    required this.wordKey,
    required this.plays,
    required this.mistakesPerSyllable,
    required this.stars,
  });

  factory ProgressEntry.empty(String wordKey) => ProgressEntry(
    wordKey: wordKey,
    plays: 0,
    mistakesPerSyllable: const {},
    stars: const [],
  );

  ProgressEntry addRound({
    required Map<String, int> mistakes,
    required int starsForRound,
  }) {
    final updated = Map<String, int>.from(mistakesPerSyllable);
    for (final e in mistakes.entries) {
      updated[e.key] = (updated[e.key] ?? 0) + e.value;
    }
    return ProgressEntry(
      wordKey: wordKey,
      plays: plays + 1,
      mistakesPerSyllable: updated,
      stars: [...stars, starsForRound],
    );
  }

  double get averageStars =>
      stars.isEmpty ? 0 : stars.reduce((a, b) => a + b) / stars.length;

  int get totalMistakes =>
      mistakesPerSyllable.values.fold(0, (sum, n) => sum + n);

  Map<String, dynamic> toJson() => {
    'wordKey': wordKey,
    'plays': plays,
    'mistakes': mistakesPerSyllable,
    'stars': stars,
  };

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
    wordKey: json['wordKey'] as String,
    plays: json['plays'] as int,
    mistakesPerSyllable: Map<String, int>.from(
      (json['mistakes'] as Map?) ?? const <String, int>{},
    ),
    stars: List<int>.from((json['stars'] as List?) ?? const <int>[]),
  );
}

class OverallProgress {
  final Map<String, ProgressEntry> entries;
  final int totalSessions;
  final int totalRounds;

  const OverallProgress({
    required this.entries,
    required this.totalSessions,
    required this.totalRounds,
  });

  static const empty = OverallProgress(
    entries: {},
    totalSessions: 0,
    totalRounds: 0,
  );

  OverallProgress withRound({
    required String wordKey,
    required Map<String, int> mistakes,
    required int starsForRound,
  }) {
    final entry = entries[wordKey] ?? ProgressEntry.empty(wordKey);
    final newEntry = entry.addRound(
      mistakes: mistakes,
      starsForRound: starsForRound,
    );
    return OverallProgress(
      entries: {...entries, wordKey: newEntry},
      totalSessions: totalSessions,
      totalRounds: totalRounds + 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'entries': entries.map((k, v) => MapEntry(k, v.toJson())),
    'totalSessions': totalSessions,
    'totalRounds': totalRounds,
  };

  factory OverallProgress.fromJson(Map<String, dynamic> json) {
    final rawEntries = (json['entries'] as Map?) ?? const <String, dynamic>{};
    final entries = <String, ProgressEntry>{};
    rawEntries.forEach((k, v) {
      entries[k as String] = ProgressEntry.fromJson(
        Map<String, dynamic>.from(v as Map),
      );
    });
    return OverallProgress(
      entries: entries,
      totalSessions: (json['totalSessions'] as int?) ?? 0,
      totalRounds: (json['totalRounds'] as int?) ?? 0,
    );
  }
}
