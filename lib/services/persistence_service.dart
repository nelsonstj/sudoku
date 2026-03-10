// lib/services/persistence_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress.dart';

class PersistenceService {
  static const String _gamesKey = 'sudoku_games';
  static const String _undoLimitKey = 'settings_undo_limit';
  static const String _realtimeErrorsKey = 'settings_realtime_errors';

  Future<Map<String, GameProgress>> loadAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_gamesKey);
    if (jsonStr == null) return {};

    final Map<String, dynamic> data = jsonDecode(jsonStr);
    final result = <String, GameProgress>{};

    for (final entry in data.entries) {
      result[entry.key] =
          GameProgress.fromJson(Map<String, dynamic>.from(entry.value));
    }
    return result;
  }

  Future<GameProgress?> loadGame(String key) async {
    final all = await loadAllGames();
    return all[key];
  }

  Future<void> saveGame(GameProgress game) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAllGames();
    all[game.key] = game;

    final jsonStr = jsonEncode(all.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_gamesKey, jsonStr);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gamesKey);
  }

  Future<int?> loadUndoLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_undoLimitKey);
  }

  Future<void> saveUndoLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_undoLimitKey, limit);
  }

  Future<bool?> loadRealtimeErrors() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_realtimeErrorsKey);
  }

  Future<void> saveRealtimeErrors(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_realtimeErrorsKey, enabled);
  }

  static const String _largerNumbersKey = 'settings_larger_numbers';

  Future<bool?> loadLargerNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_largerNumbersKey);
  }

  Future<void> saveLargerNumbers(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largerNumbersKey, enabled);
  }

  static const String _highlightRowColKey = 'settings_highlight_row_col';

  Future<bool?> loadHighlightRowCol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_highlightRowColKey);
  }

  Future<void> saveHighlightRowCol(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highlightRowColKey, enabled);
  }

  Future<void> deleteGame(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAllGames();
    all.remove(key);

    final jsonStr = jsonEncode(all.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_gamesKey, jsonStr);
  }
}
