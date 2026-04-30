import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class BgmService {
  static const String _assetPath = 'assets/audio/bgm/loop.mp3';
  static const double _bgmVolumeFactor = 0.4;

  final AudioPlayer _player = AudioPlayer();
  double _masterVolume = 1.0;
  bool _started = false;
  bool _wasPlayingBeforePause = false;

  Future<void> updateSettings({
    required bool enabled,
    required double masterVolume,
  }) async {
    _masterVolume = masterVolume.clamp(0.0, 1.0);
    final effective = _masterVolume * _bgmVolumeFactor;
    try {
      await _player.setVolume(effective);
    } catch (_) {}

    if (enabled && !_started) {
      await _start();
    } else if (!enabled && _started) {
      await _stop();
    }
  }

  Future<void> _start() async {
    try {
      await _player.setAsset(_assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(_masterVolume * _bgmVolumeFactor);
      await _player.play();
      _started = true;
    } catch (e) {
      if (kDebugMode) debugPrint('BgmService: skip ($e)');
    }
  }

  Future<void> _stop() async {
    try {
      await _player.stop();
      _started = false;
    } catch (_) {}
  }

  Future<void> pauseForLifecycle() async {
    if (_started && _player.playing) {
      _wasPlayingBeforePause = true;
      try {
        await _player.pause();
      } catch (_) {}
    }
  }

  Future<void> resumeAfterLifecycle() async {
    if (_started && _wasPlayingBeforePause) {
      _wasPlayingBeforePause = false;
      try {
        await _player.play();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
