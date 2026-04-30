import 'package:flutter/material.dart';
import 'package:syllables_apk/theme/app_theme.dart';

enum GameModeId {
  baby,
  basic,
  noImage,
  audioOnly,
  hardcore,
}

class GameMode {
  final GameModeId id;
  final String title;
  final String description;
  final bool showImage;
  final bool showWord;
  final bool syllableAudioOnDrag;
  final bool wordAudioOnRoundStart;
  final int extraSyllables;
  final Color color;
  final IconData icon;

  const GameMode({
    required this.id,
    required this.title,
    required this.description,
    required this.showImage,
    required this.showWord,
    required this.syllableAudioOnDrag,
    required this.wordAudioOnRoundStart,
    required this.extraSyllables,
    required this.color,
    required this.icon,
  });

  static const baby = GameMode(
    id: GameModeId.baby,
    title: 'Малыш',
    description: 'С картинкой и подсказками',
    showImage: true,
    showWord: true,
    syllableAudioOnDrag: true,
    wordAudioOnRoundStart: false,
    extraSyllables: 3,
    color: AppTheme.mint,
    icon: Icons.child_care_rounded,
  );

  static const basic = GameMode(
    id: GameModeId.basic,
    title: 'Базовый',
    description: 'Картинка и слово',
    showImage: true,
    showWord: true,
    syllableAudioOnDrag: true,
    wordAudioOnRoundStart: false,
    extraSyllables: 7,
    color: AppTheme.sunshine,
    icon: Icons.menu_book_rounded,
  );

  static const noImage = GameMode(
    id: GameModeId.noImage,
    title: 'Без картинки',
    description: 'Только слово',
    showImage: false,
    showWord: true,
    syllableAudioOnDrag: true,
    wordAudioOnRoundStart: false,
    extraSyllables: 7,
    color: AppTheme.sky,
    icon: Icons.image_not_supported_rounded,
  );

  static const audioOnly = GameMode(
    id: GameModeId.audioOnly,
    title: 'На слух',
    description: 'Только озвучка слова',
    showImage: false,
    showWord: false,
    syllableAudioOnDrag: true,
    wordAudioOnRoundStart: true,
    extraSyllables: 7,
    color: AppTheme.secondary,
    icon: Icons.hearing_rounded,
  );

  static const hardcore = GameMode(
    id: GameModeId.hardcore,
    title: 'Хардкор',
    description: 'Без подсказок',
    showImage: false,
    showWord: false,
    syllableAudioOnDrag: false,
    wordAudioOnRoundStart: false,
    extraSyllables: 7,
    color: AppTheme.violet,
    icon: Icons.local_fire_department_rounded,
  );

  static const all = [basic, noImage, audioOnly];

  static GameMode byId(GameModeId id) => all.firstWhere((m) => m.id == id);
}
