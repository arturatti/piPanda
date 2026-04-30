import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syllables_apk/models/progress.dart';

class ProgressService {
  static const String _fileName = 'progress.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<OverallProgress> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return OverallProgress.empty;
      final content = await file.readAsString();
      if (content.isEmpty) return OverallProgress.empty;
      return OverallProgress.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('ProgressService load error: $e');
      return OverallProgress.empty;
    }
  }

  Future<void> save(OverallProgress progress) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(progress.toJson()));
    } catch (e) {
      if (kDebugMode) debugPrint('ProgressService save error: $e');
    }
  }

  Future<void> reset() async {
    try {
      final file = await _file();
      if (file.existsSync()) await file.delete();
    } catch (e) {
      if (kDebugMode) debugPrint('ProgressService reset error: $e');
    }
  }
}
