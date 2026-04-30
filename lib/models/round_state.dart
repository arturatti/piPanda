import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/models/word.dart';

class RoundState {
  final Word word;
  final List<Syllable?> filledSlots;
  final List<int> attemptsPerSlot;
  final List<Syllable> availableSyllables;
  final int? hintSlotIndex;
  final bool finished;
  final bool hintWasShown;
  final int? lastEarnedStars;
  final int roundIndex;
  final int roundsPerSession;
  final List<int> sessionStars;
  final int? highlightedSyllableIndex;

  const RoundState({
    required this.word,
    required this.filledSlots,
    required this.attemptsPerSlot,
    required this.availableSyllables,
    required this.hintSlotIndex,
    required this.finished,
    required this.hintWasShown,
    this.lastEarnedStars,
    required this.roundIndex,
    required this.roundsPerSession,
    required this.sessionStars,
    this.highlightedSyllableIndex,
  });

  RoundState copyWith({
    List<Syllable?>? filledSlots,
    List<int>? attemptsPerSlot,
    List<Syllable>? availableSyllables,
    int? hintSlotIndex,
    bool clearHint = false,
    bool? finished,
    bool? hintWasShown,
    int? lastEarnedStars,
    int? roundIndex,
    int? roundsPerSession,
    List<int>? sessionStars,
    int? highlightedSyllableIndex,
    bool clearHighlight = false,
  }) {
    return RoundState(
      word: word,
      filledSlots: filledSlots ?? this.filledSlots,
      attemptsPerSlot: attemptsPerSlot ?? this.attemptsPerSlot,
      availableSyllables: availableSyllables ?? this.availableSyllables,
      hintSlotIndex: clearHint ? null : (hintSlotIndex ?? this.hintSlotIndex),
      finished: finished ?? this.finished,
      hintWasShown: hintWasShown ?? this.hintWasShown,
      lastEarnedStars: lastEarnedStars ?? this.lastEarnedStars,
      roundIndex: roundIndex ?? this.roundIndex,
      roundsPerSession: roundsPerSession ?? this.roundsPerSession,
      sessionStars: sessionStars ?? this.sessionStars,
      highlightedSyllableIndex: clearHighlight
          ? null
          : (highlightedSyllableIndex ?? this.highlightedSyllableIndex),
    );
  }

  bool get allFilled => filledSlots.every((s) => s != null);

  int get totalMistakes =>
      attemptsPerSlot.fold(0, (sum, attempts) => sum + attempts);
}
