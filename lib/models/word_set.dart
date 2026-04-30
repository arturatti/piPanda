import 'package:flutter/material.dart';
import 'package:syllables_apk/theme/app_theme.dart';

enum WordSetId { standard, dinosaurs, reptiles }

class WordSet {
  final WordSetId id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String dataPath;
  final String imagesSubdir;

  const WordSet({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.dataPath,
    required this.imagesSubdir,
  });

  static const standard = WordSet(
    id: WordSetId.standard,
    title: 'Стандартный',
    description: 'Знакомые слова',
    icon: Icons.menu_book_rounded,
    color: AppTheme.sunshine,
    dataPath: 'assets/data/standard/words.txt',
    imagesSubdir: 'standard',
  );

  static const dinosaurs = WordSet(
    id: WordSetId.dinosaurs,
    title: 'Динозавры',
    description: 'Древние ящеры',
    icon: Icons.pets_rounded,
    color: AppTheme.success,
    dataPath: 'assets/data/dinosaurs/words.txt',
    imagesSubdir: 'dinosaurs',
  );

  static const reptiles = WordSet(
    id: WordSetId.reptiles,
    title: 'Рептилии',
    description: 'Ящеры и амфибии',
    icon: Icons.eco_rounded,
    color: AppTheme.sky,
    dataPath: 'assets/data/reptiles/words.txt',
    imagesSubdir: 'reptiles',
  );

  static const all = [standard, dinosaurs, reptiles];

  static WordSet byId(WordSetId id) => all.firstWhere((s) => s.id == id);
  static WordSet? byName(String name) {
    for (final s in all) {
      if (s.id.name == name) return s;
    }
    return null;
  }
}
