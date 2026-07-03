import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

class HistoryEntry {
  final int toolId;
  final DateTime timestamp;

  HistoryEntry({required this.toolId, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'toolId': toolId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        toolId: json['toolId'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
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

  void record(int toolId) {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    final entry = HistoryEntry(toolId: toolId, timestamp: DateTime.now());
    raw.add(jsonEncode(entry.toJson()));
    if (raw.length > _maxEntries) raw.removeAt(0);
    SharedPreferencesHelper.localStorage.setStringList(_key, raw);
    notifyListeners();
  }

  void clear() {
    SharedPreferencesHelper.localStorage.remove(_key);
    notifyListeners();
  }
}
