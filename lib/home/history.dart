import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

class HistoryEntry {
  final int toolId;
  final DateTime timestamp;
  final Map<String, String>? inputs;

  HistoryEntry({required this.toolId, required this.timestamp, this.inputs});

  Map<String, dynamic> toJson() => {
        'toolId': toolId,
        'timestamp': timestamp.toIso8601String(),
        'inputs': inputs,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        toolId: json['toolId'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        inputs: json['inputs'] != null ? Map<String, String>.from(json['inputs']) : null,
      );
}

class ToolHistory extends ChangeNotifier {
  static const _key = 'TOOL_HISTORY';
  static const _maxEntries = 50;

  List<HistoryEntry> get entries {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    return raw
        .map((s) => HistoryEntry.fromJson(jsonDecode(s)))
        .toList()
        .reversed
        .toList();
  }

  void record(int toolId, {Map<String, String>? inputs}) {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    final entry = HistoryEntry(toolId: toolId, timestamp: DateTime.now(), inputs: inputs);
    raw.add(jsonEncode(entry.toJson()));
    if (raw.length > _maxEntries) raw.removeAt(0);
    SharedPreferencesHelper.localStorage.setStringList(_key, raw);
    notifyListeners();
  }

  void clear() {
    SharedPreferencesHelper.localStorage.remove(_key);
    notifyListeners();
  }

  void deleteAt(int uiIndex) {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    if (uiIndex >= 0 && uiIndex < raw.length) {
      // The entries getter reverses the list, so UI index 'i' is raw index 'length - 1 - i'
      int storageIndex = raw.length - 1 - uiIndex;
      raw.removeAt(storageIndex);
      SharedPreferencesHelper.localStorage.setStringList(_key, raw);
      notifyListeners();
    }
  }
}
