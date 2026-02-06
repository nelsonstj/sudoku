import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/persistence_service.dart';

class SettingsState {
  final String language;
  final ThemeMode themeMode;
  final int undoStackLimit;
  final bool realtimeErrorChecking;
  final bool largerNumbers;
  final bool highlightRowCol;
  SettingsState({required this.language, required this.themeMode, required this.undoStackLimit, required this.realtimeErrorChecking, required this.largerNumbers, required this.highlightRowCol});

  SettingsState copyWith({String? language, ThemeMode? themeMode, int? undoStackLimit, bool? realtimeErrorChecking, bool? largerNumbers, bool? highlightRowCol}) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      undoStackLimit: undoStackLimit ?? this.undoStackLimit,
      realtimeErrorChecking: realtimeErrorChecking ?? this.realtimeErrorChecking,
      largerNumbers: largerNumbers ?? this.largerNumbers,
      highlightRowCol: highlightRowCol ?? this.highlightRowCol,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(language: 'pt', themeMode: ThemeMode.system, undoStackLimit: 50, realtimeErrorChecking: true, largerNumbers: false, highlightRowCol: true)) {
    // load persisted settings
    Future.microtask(() async {
      try {
        final persistence = PersistenceService();
        final val = await persistence.loadUndoLimit();
        if (val != null) {
          state = state.copyWith(undoStackLimit: val);
        }
        final rt = await persistence.loadRealtimeErrors();
        if (rt != null) {
          state = state.copyWith(realtimeErrorChecking: rt);
        }
        final ln = await persistence.loadLargerNumbers();
        if (ln != null) {
          state = state.copyWith(largerNumbers: ln);
        }
        final hrc = await persistence.loadHighlightRowCol();
        if (hrc != null) {
          state = state.copyWith(highlightRowCol: hrc);
        }
      } catch (_) {}
    });
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setUndoStackLimit(int limit) {
    state = state.copyWith(undoStackLimit: limit);
    // persist
    Future.microtask(() async {
      try {
        final persistence = PersistenceService();
        await persistence.saveUndoLimit(limit);
        // keep realtime setting untouched here
      } catch (_) {}
    });
  }

  void setRealtimeErrorChecking(bool enabled) {
    state = state.copyWith(realtimeErrorChecking: enabled);
    Future.microtask(() async {
      try {
        final persistence = PersistenceService();
        await persistence.saveRealtimeErrors(enabled);
      } catch (_) {}
    });
  }

  void setLargerNumbers(bool enabled) {
    state = state.copyWith(largerNumbers: enabled);
    Future.microtask(() async {
      try {
        final persistence = PersistenceService();
        await persistence.saveLargerNumbers(enabled);
      } catch (_) {}
    });
  }

  void setHighlightRowCol(bool enabled) {
    state = state.copyWith(highlightRowCol: enabled);
    Future.microtask(() async {
      try {
        final persistence = PersistenceService();
        await persistence.saveHighlightRowCol(enabled);
      } catch (_) {}
    });
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());
