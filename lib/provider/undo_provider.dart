import 'dart:convert';
import 'package:flutter/material.dart';

class UndoRedoState {
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  UndoRedoState({
    required this.action,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class UndoProvider extends ChangeNotifier {
  final List<UndoRedoState> _undoStack = [];
  final List<UndoRedoState> _redoStack = [];
  static const int maxUndoStates = 50;
  bool _isUndoRedoInProgress = false;

  bool get canUndo => _undoStack.length > 1;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isUndoRedoInProgress => _isUndoRedoInProgress;
  int get currentStateIndex => _undoStack.length;
  int get totalStates => _undoStack.length + _redoStack.length + 1;

  String? getLastAction() {
    return _undoStack.length > 1 ? _undoStack[_undoStack.length - 2].action : null;
  }

  String? getNextAction() {
    return _redoStack.isNotEmpty ? _redoStack.last.action : null;
  }

  void saveState({
    required String action,
    required Map<String, dynamic> state,
  }) {
    if (_isUndoRedoInProgress) return;

    _redoStack.clear();

    _undoStack.add(UndoRedoState(
      action: action,
      data: _deepCopyState(state),
    ));

    if (_undoStack.length > maxUndoStates) {
      _undoStack.removeAt(0);
    }

    notifyListeners();
  }

  UndoRedoState? undo() {
    if (!canUndo) return null;

    _isUndoRedoInProgress = true;

    final currentState = _undoStack.removeLast();
    _redoStack.add(currentState);

    final stateToRestore = _undoStack.last;

    _isUndoRedoInProgress = false;
    notifyListeners();

    return stateToRestore;
  }

  UndoRedoState? redo() {
    if (!canRedo) return null;

    _isUndoRedoInProgress = true;

    final stateToRestore = _redoStack.removeLast();
    _undoStack.add(stateToRestore);

    _isUndoRedoInProgress = false;
    notifyListeners();

    return stateToRestore;
  }

  Map<String, dynamic> _deepCopyState(Map<String, dynamic> state) {
    return Map<String, dynamic>.from(state.map((key, value) {
      if (value is Map) {
        return MapEntry(key, Map<String, dynamic>.from(value));
      } else if (value is List) {
        return MapEntry(key, List.from(value));
      }
      return MapEntry(key, value);
    }));
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  List<String> getUndoHistory() {
    return _undoStack.map((state) => state.action).toList();
  }

  List<String> getRedoHistory() {
    return _redoStack.map((state) => state.action).toList().reversed.toList();
  }
}