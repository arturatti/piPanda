class AppSettings {
  final double volume;
  final bool soundEffects;
  final bool animations;
  final bool backgroundMusic;
  final int totalSyllables;

  const AppSettings({
    required this.volume,
    required this.soundEffects,
    required this.animations,
    required this.backgroundMusic,
    required this.totalSyllables,
  });

  static const defaults = AppSettings(
    volume: 1.0,
    soundEffects: true,
    animations: true,
    backgroundMusic: true,
    totalSyllables: 8,
  );

  AppSettings copyWith({
    double? volume,
    bool? soundEffects,
    bool? animations,
    bool? backgroundMusic,
    int? totalSyllables,
  }) {
    return AppSettings(
      volume: volume ?? this.volume,
      soundEffects: soundEffects ?? this.soundEffects,
      animations: animations ?? this.animations,
      backgroundMusic: backgroundMusic ?? this.backgroundMusic,
      totalSyllables: totalSyllables ?? this.totalSyllables,
    );
  }
}
