import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllables_apk/data/syllable_pool.dart';
import 'package:syllables_apk/data/word_repository.dart';
import 'package:syllables_apk/models/game_mode.dart';
import 'package:syllables_apk/models/progress.dart';
import 'package:syllables_apk/models/round_state.dart';
import 'package:syllables_apk/models/settings.dart';
import 'package:syllables_apk/models/word.dart';
import 'package:syllables_apk/models/word_set.dart';
import 'package:syllables_apk/services/audio_service.dart';
import 'package:syllables_apk/services/bgm_service.dart';
import 'package:syllables_apk/services/progress_service.dart';
import 'package:syllables_apk/services/settings_service.dart';
import 'package:syllables_apk/state/game_notifier.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

final currentWordSetProvider = StateProvider<WordSet>((_) => WordSet.standard);

final wordsProvider = FutureProvider<List<Word>>((ref) {
  final set = ref.watch(currentWordSetProvider);
  return ref.read(wordRepositoryProvider).loadSet(set);
});

final allWordsProvider = FutureProvider<Map<String, Word>>((ref) async {
  final repo = ref.read(wordRepositoryProvider);
  final entries = <String, Word>{};
  for (final set in WordSet.all) {
    try {
      final words = await repo.loadSet(set);
      for (final w in words) {
        entries['${set.id.name}:${w.text}'] = w;
      }
    } catch (_) {
      // Skip sets without data file (e.g. dinosaurs before content arrives)
    }
  }
  return entries;
});

final syllablePoolProvider = Provider<SyllablePool>((ref) {
  final words = ref.watch(wordsProvider).valueOrNull ?? const [];
  return SyllablePool.fromWords(words);
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(AppSettings.defaults) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.load();
  }

  Future<void> setVolume(double v) async {
    state = state.copyWith(volume: v);
    await _service.save(state);
  }

  Future<void> setSoundEffects(bool v) async {
    state = state.copyWith(soundEffects: v);
    await _service.save(state);
  }

  Future<void> setAnimations(bool v) async {
    state = state.copyWith(animations: v);
    await _service.save(state);
  }

  Future<void> setBackgroundMusic(bool v) async {
    state = state.copyWith(backgroundMusic: v);
    await _service.save(state);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsServiceProvider));
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  final settings = ref.watch(settingsNotifierProvider);
  service.updateSettings(
    volume: settings.volume,
    soundEffects: settings.soundEffects,
  );
  ref.onDispose(service.dispose);
  return service;
});

final bgmServiceProvider = Provider<BgmService>((ref) {
  final service = BgmService();
  final settings = ref.watch(settingsNotifierProvider);
  service.updateSettings(
    enabled: settings.backgroundMusic,
    masterVolume: settings.volume,
  );
  ref.onDispose(service.dispose);
  return service;
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

class ProgressNotifier extends StateNotifier<OverallProgress> {
  final ProgressService _service;

  ProgressNotifier(this._service) : super(OverallProgress.empty) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.load();
  }

  Future<void> recordRound({
    required String wordKey,
    required Map<String, int> mistakes,
    required int stars,
  }) async {
    final updated = state.withRound(
      wordKey: wordKey,
      mistakes: mistakes,
      starsForRound: stars,
    );
    state = updated;
    await _service.save(updated);
  }

  Future<void> reset() async {
    await _service.reset();
    state = OverallProgress.empty;
  }
}

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, OverallProgress>((ref) {
  return ProgressNotifier(ref.watch(progressServiceProvider));
});

final gameNotifierProvider = StateNotifierProvider.autoDispose
    .family<GameNotifier, RoundState?, GameMode>((ref, mode) {
  final words = ref.watch(wordsProvider).requireValue;
  final pool = ref.watch(syllablePoolProvider);
  final audio = ref.watch(audioServiceProvider);
  final progress = ref.read(progressNotifierProvider.notifier);
  return GameNotifier(
    words: words,
    pool: pool,
    audio: audio,
    mode: mode,
    onRoundFinished: ({required word, required mistakesPerSyllable, required stars}) {
      final set = ref.read(currentWordSetProvider);
      progress.recordRound(
        wordKey: '${set.id.name}:${word.text}',
        mistakes: mistakesPerSyllable,
        stars: stars,
      );
    },
  );
});
