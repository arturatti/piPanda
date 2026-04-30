import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:syllables_apk/models/syllable.dart';
import 'package:syllables_apk/models/word.dart';

class AudioService {
  // Yandex SpeechKit отдаёт WAV для слогов и слов; UI/BGM из Mixkit — MP3.
  static const _voiceExts = ['wav', 'mp3', 'm4a', 'ogg'];
  static const _uiExts = ['mp3', 'wav', 'm4a', 'ogg'];

  final AudioPlayer _wordPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  double _volume = 1.0;
  bool _soundEffects = true;

  void updateSettings({required double volume, required bool soundEffects}) {
    _volume = volume.clamp(0.0, 1.0);
    _soundEffects = soundEffects;
    _wordPlayer.setVolume(_volume);
    _sfxPlayer.setVolume(_volume);
  }

  Future<void> playSyllable(Syllable syllable) {
    return _playOn(
      _sfxPlayer,
      'assets/audio/syllables/${syllable.audioKey}',
      _voiceExts,
    );
  }

  Future<void> playWord(Word word) {
    return _playOn(
      _wordPlayer,
      'assets/audio/words/${word.audioKey}',
      _voiceExts,
    );
  }

  Future<void> playUi(String name) {
    if (!_soundEffects) return Future.value();
    // Important UI cues (success) play on the word player so they aren't cut off
    // by syllable drag/drop sounds on the SFX player.
    final player = name == 'success' ? _wordPlayer : _sfxPlayer;
    return _playOn(player, 'assets/audio/ui/$name', _uiExts);
  }

  Future<void> playWordBySyllables(
    Word word, {
    required void Function(int? index) onIndex,
    Duration gap = const Duration(milliseconds: 120),
  }) async {
    if (_volume <= 0) {
      onIndex(null);
      return;
    }
    for (var i = 0; i < word.syllables.length; i++) {
      onIndex(i);
      final played = await _playAndWaitOn(
        _wordPlayer,
        'assets/audio/syllables/${word.syllables[i].audioKey}',
        _voiceExts,
      );
      if (!played) {
        await Future.delayed(const Duration(milliseconds: 350));
      }
      if (i < word.syllables.length - 1) {
        await Future.delayed(gap);
      }
    }
    onIndex(null);
  }

  Future<void> stopWordPlayer() async {
    try {
      await _wordPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playOn(
    AudioPlayer player,
    String basePath,
    List<String> exts,
  ) async {
    if (_volume <= 0) return;
    for (final ext in exts) {
      if (await _setAndPlay(player, '$basePath.$ext')) return;
    }
  }

  Future<bool> _setAndPlay(AudioPlayer player, String assetPath) async {
    try {
      await player.stop();
      await player.setAsset(assetPath);
      await player.setVolume(_volume);
      await player.play();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _playAndWaitOn(
    AudioPlayer player,
    String basePath,
    List<String> exts,
  ) async {
    if (_volume <= 0) return false;
    for (final ext in exts) {
      try {
        await player.stop();
        await player.setAsset('$basePath.$ext');
        await player.setVolume(_volume);
        await player.play();
        await player.processingStateStream
            .firstWhere((s) => s == ProcessingState.completed)
            .timeout(
              const Duration(seconds: 4),
              onTimeout: () => ProcessingState.completed,
            );
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Future<void> dispose() async {
    await _wordPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
