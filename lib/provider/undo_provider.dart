import 'dart:convert';
import 'package:flutter/material.dart';

class UndoRedoState {
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  UndoRedoState({required this.action, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class UndoProvider extends ChangeNotifier {
  final List<UndoRedoState> _undoStack = [];
  final List<UndoRedoState> _redoStack = [];
  static const int maxUndoStates = 50;
  bool _isUndoRedoInProgress = false;

  // Getters
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isUndoRedoInProgress => _isUndoRedoInProgress;
  int get currentStateIndex => _undoStack.length;
  int get totalStates => _undoStack.length + _redoStack.length + 1;

  String? getLastAction() {
    return _undoStack.isNotEmpty ? _undoStack.last.action : null;
  }

  String? getNextAction() {
    return _redoStack.isNotEmpty ? _redoStack.last.action : null;
  }

  void saveState({
    required String action,
    required Map<String, dynamic> state,
  }) {
    if (_isUndoRedoInProgress) return;

    // Clear redo stack when new action is performed
    _redoStack.clear();

    // Add current state to undo stack
    _undoStack.add(UndoRedoState(action: action, data: Map.from(state)));

    // Limit undo stack size
    if (_undoStack.length > maxUndoStates) {
      _undoStack.removeAt(0);
    }

    notifyListeners();
  }

  UndoRedoState? undo() {
    if (!canUndo) return null;

    _isUndoRedoInProgress = true;

    // Move current state to redo stack
    final currentState = _undoStack.removeLast();
    _redoStack.add(currentState);

    // Get previous state
    final previousState = _undoStack.isNotEmpty ? _undoStack.last : null;

    _isUndoRedoInProgress = false;
    notifyListeners();

    return previousState;
  }

  UndoRedoState? redo() {
    if (!canRedo) return null;

    _isUndoRedoInProgress = true;

    // Move state from redo to undo stack
    final redoState = _redoStack.removeLast();
    _undoStack.add(redoState);

    _isUndoRedoInProgress = false;
    notifyListeners();

    return redoState;
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
