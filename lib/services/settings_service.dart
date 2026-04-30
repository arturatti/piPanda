import 'package:shared_preferences/shared_preferences.dart';
import 'package:syllables_apk/models/settings.dart';

class SettingsService {
  static const _kVolume = 'settings.volume';
  static const _kSoundEffects = 'settings.sfx';
  static const _kAnimations = 'settings.animations';
  static const _kBackgroundMusic = 'settings.bgm';
  static const _kTotalSyllables = 'settings.totalSyllables';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      volume: prefs.getDouble(_kVolume) ?? AppSettings.defaults.volume,
      soundEffects:
          prefs.getBool(_kSoundEffects) ?? AppSettings.defaults.soundEffects,
      animations:
          prefs.getBool(_kAnimations) ?? AppSettings.defaults.animations,
      backgroundMusic:
          prefs.getBool(_kBackgroundMusic) ??
          AppSettings.defaults.backgroundMusic,
      totalSyllables:
          prefs.getInt(_kTotalSyllables) ??
          AppSettings.defaults.totalSyllables,
    );
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolume, s.volume);
    await prefs.setBool(_kSoundEffects, s.soundEffects);
    await prefs.setBool(_kAnimations, s.animations);
    await prefs.setBool(_kBackgroundMusic, s.backgroundMusic);
    await prefs.setInt(_kTotalSyllables, s.totalSyllables);
  }
}
