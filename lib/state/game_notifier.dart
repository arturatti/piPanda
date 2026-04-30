import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllables_apk/data/syllable_pool.dart';
import 'package:syllables_apk/models/game_mode.dart';
import 'package:syllables_apk/models/round_state.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/models/word.dart';
import 'package:syllables_apk/services/audio_service.dart';

const int _hintThreshold = 3;
const int _roundsPerSession = 5;

typedef RoundResultCallback = void Function({
  required Word word,
  required Map<String, int> mistakesPerSyllable,
  required int stars,
});

class GameNotifier extends StateNotifier<RoundState?> {
  final List<Word> _words;
  final SyllablePool _pool;
  final AudioService _audio;
  final GameMode _mode;
  final RoundResultCallback? _onRoundFinished;
  final Random _random = Random();
  Word? _previousWord;

  GameNotifier({
    required List<Word> words,
    required SyllablePool pool,
    required AudioService audio,
    required GameMode mode,
    RoundResultCallback? onRoundFinished,
  })  : _words = words,
        _pool = pool,
        _audio = audio,
        _mode = mode,
        _onRoundFinished = onRoundFinished,
        super(null) {
    nextRound();
  }

  GameMode get mode => _mode;

  void nextRound() {
    final word = _pickWord();
    _previousWord = word;
    final correct = word.syllables;
    final distractors = _pool.randomDistractors(
      exclude: correct,
      count: _mode.extraSyllables,
    );
    final available = [...correct, ...distractors]..shuffle(_random);

    final prev = state;
    final nextIndex = prev == null
        ? 0
        : (prev.roundIndex + 1) % _roundsPerSession;
    final nextSessionStars = prev == null || nextIndex == 0
        ? <int>[]
        : prev.sessionStars;

    state = RoundState(
      word: word,
      filledSlots: List<Syllable?>.filled(correct.length, null),
      attemptsPerSlot: List<int>.filled(correct.length, 0),
      availableSyllables: available,
      hintSlotIndex: null,
      finished: false,
      hintWasShown: false,
      lastEarnedStars: null,
      roundIndex: nextIndex,
      roundsPerSession: _roundsPerSession,
      sessionStars: nextSessionStars,
      highlightedSyllableIndex: null,
    );

    _playSyllablesWithHighlight(word);
  }

  Future<void> _playSyllablesWithHighlight(Word word) async {
    await _audio.playWordBySyllables(
      word,
      onIndex: (index) {
        final s = state;
        if (s == null || s.word != word) return;
        state = s.copyWith(
          highlightedSyllableIndex: index,
          clearHighlight: index == null,
        );
      },
    );
  }

  Word _pickWord() {
    if (_words.length <= 1) return _words.first;
    Word w;
    do {
      w = _words[_random.nextInt(_words.length)];
    } while (w == _previousWord);
    return w;
  }

  void onSyllableDragStart(Syllable syllable) {
    HapticFeedback.selectionClick();
    if (_mode.syllableAudioOnDrag) {
      _audio.playSyllable(syllable);
    }
  }

  void replayWordBySyllables() {
    final current = state;
    if (current == null) return;
    _playSyllablesWithHighlight(current.word);
  }

  void replayWordWhole() {
    final current = state;
    if (current == null) return;
    _audio.playWord(current.word);
  }

  bool tryDropSyllable(int slotIndex, Syllable syllable) {
    final current = state;
    if (current == null || current.finished) return false;
    if (current.filledSlots[slotIndex] != null) return false;

    final correct = current.word.syllables[slotIndex] == syllable;
    if (correct) {
      final filled = [...current.filledSlots];
      filled[slotIndex] = syllable;

      final available = [...current.availableSyllables];
      final removeIdx = available.indexWhere((s) => s.text == syllable.text);
      if (removeIdx >= 0) available.removeAt(removeIdx);

      final attempts = [...current.attemptsPerSlot];
      attempts[slotIndex] = 0;

      final allFilled = filled.every((s) => s != null);

      if (allFilled) {
        final tempState = current.copyWith(
          filledSlots: filled,
          availableSyllables: available,
          attemptsPerSlot: attempts,
          clearHint: true,
          finished: true,
        );
        final stars = _calcStars(tempState);
        state = tempState.copyWith(
          lastEarnedStars: stars,
          sessionStars: [...current.sessionStars, stars],
        );
      } else {
        state = current.copyWith(
          filledSlots: filled,
          availableSyllables: available,
          attemptsPerSlot: attempts,
          clearHint: true,
          finished: false,
        );
      }

      HapticFeedback.lightImpact();
      _audio.playUi('drop_correct');
      if (allFilled) _onVictory();
      return true;
    } else {
      final attempts = [...current.attemptsPerSlot];
      attempts[slotIndex] = attempts[slotIndex] + 1;
      final showHint = attempts[slotIndex] >= _hintThreshold;

      state = current.copyWith(
        attemptsPerSlot: attempts,
        hintSlotIndex: showHint ? slotIndex : current.hintSlotIndex,
        hintWasShown: current.hintWasShown || showHint,
      );

      HapticFeedback.heavyImpact();
      if (showHint) {
        _audio.playSyllable(current.word.syllables[slotIndex]);
      } else {
        _audio.playUi('drop_wrong');
      }
      return false;
    }
  }

  void _onVictory() {
    final current = state;
    if (current == null) return;
    _audio.playUi('success');
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _audio.playWord(current.word);
    });
    final stars = _calcStars(current);
    final mistakes = <String, int>{};
    for (var i = 0; i < current.word.syllables.length; i++) {
      final attempts = current.attemptsPerSlot[i];
      if (attempts > 0) {
        mistakes[current.word.syllables[i].text] = attempts;
      }
    }
    _onRoundFinished?.call(
      word: current.word,
      mistakesPerSyllable: mistakes,
      stars: stars,
    );
  }

  int _calcStars(RoundState state) {
    if (state.totalMistakes == 0) return 3;
    if (!state.hintWasShown) return 2;
    return 1;
  }

  void replayWordAudio() {
    replayWordBySyllables();
  }
}
