import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

/// A named set of calculator inputs the user chose to keep.
///
/// Unlike a [HistoryEntry], a project is permanent: it is never evicted, and
/// the user names it after the thing they are designing ("Valve spring — rev
/// C") rather than the tool or the time.
///
/// ## Compatibility contract
///
/// [inputs] is keyed by each calculator's own input labels, the same map
/// [ToolHistory.record] captures and [Tool.action] replays via
/// `initialInputs`. History tolerates those keys drifting because entries are
/// evicted after 50; a project the user expects to keep for a year does not.
///
/// Reading is deliberately tolerant, so a rename degrades instead of breaking:
/// a key a calculator no longer recognizes is ignored, and a key it expects
/// but does not find leaves that field blank. Renaming an input label
/// therefore costs the user that one prefilled field, not the whole project.
///
/// [schemaVersion] is stored so a future change of shape can be migrated
/// rather than guessed at. Bump it whenever the meaning of a stored field
/// changes, and handle the older value in [SavedProject.fromJson].
class SavedProject {
  const SavedProject({
    required this.id,
    required this.name,
    required this.toolId,
    required this.inputs,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Current storage shape. See the compatibility contract above.
  static const int currentSchemaVersion = 1;

  final String id;
  final String name;
  final int toolId;
  final Map<String, String> inputs;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedProject copyWith({
    String? name,
    Map<String, String>? inputs,
    DateTime? updatedAt,
  }) =>
      SavedProject(
        id: id,
        name: name ?? this.name,
        toolId: toolId,
        inputs: inputs ?? this.inputs,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'v': currentSchemaVersion,
        'id': id,
        'name': name,
        'toolId': toolId,
        'inputs': inputs,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Throws [FormatException] when the record is unusable. Callers read
  /// through [SavedProjects.projects], which drops such records rather than
  /// letting one bad row take the whole list down.
  factory SavedProject.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final toolId = json['toolId'];
    if (id is! String || toolId is! int) {
      throw const FormatException('saved project is missing its id or toolId');
    }
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return SavedProject(
      id: id,
      name: json['name'] as String? ?? '',
      toolId: toolId,
      // Values are coerced to String: a calculator writes display text, but a
      // hand-edited or older record may hold a number.
      inputs: {
        for (final entry in (json['inputs'] as Map? ?? const {}).entries)
          '${entry.key}': '${entry.value}',
      },
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }
}

/// The user's saved projects, newest first.
///
/// Follows the same SharedPreferences string-list pattern as [ToolHistory],
/// with one deliberate difference: there is no entry cap and nothing is ever
/// evicted. A project disappears only when the user deletes it.
class SavedProjects extends ChangeNotifier {
  static const _key = 'SAVED_PROJECTS';

  List<String> get _raw =>
      SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];

  void _write(List<String> raw) {
    SharedPreferencesHelper.localStorage.setStringList(_key, raw);
    notifyListeners();
  }

  /// Stored projects, newest first. Records that cannot be decoded are skipped
  /// so a single corrupt row cannot hide every other project.
  List<SavedProject> get projects {
    final decoded = <SavedProject>[];
    for (final entry in _raw) {
      try {
        decoded.add(SavedProject.fromJson(jsonDecode(entry)));
      } catch (_) {
        continue;
      }
    }
    decoded.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return decoded;
  }

  bool get isEmpty => projects.isEmpty;

  SavedProject? byId(String id) {
    for (final project in projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  /// Persists a new project and returns it.
  SavedProject save({
    required String name,
    required int toolId,
    required Map<String, String> inputs,
  }) {
    final now = DateTime.now();
    final project = SavedProject(
      id: '${now.microsecondsSinceEpoch}-$toolId',
      name: name.trim(),
      toolId: toolId,
      inputs: Map<String, String>.from(inputs),
      createdAt: now,
      updatedAt: now,
    );
    _write([..._raw, jsonEncode(project.toJson())]);
    return project;
  }

  void rename(String id, String name) =>
      _update(id, (project) => project.copyWith(
            name: name.trim(),
            updatedAt: DateTime.now(),
          ));

  /// Replaces a project's inputs — for "save over" after re-running a tool
  /// with tweaked numbers.
  void updateInputs(String id, Map<String, String> inputs) =>
      _update(id, (project) => project.copyWith(
            inputs: Map<String, String>.from(inputs),
            updatedAt: DateTime.now(),
          ));

  void _update(String id, SavedProject Function(SavedProject) transform) {
    final raw = _raw;
    for (var i = 0; i < raw.length; i++) {
      try {
        final project = SavedProject.fromJson(jsonDecode(raw[i]));
        if (project.id != id) continue;
        raw[i] = jsonEncode(transform(project).toJson());
        _write(raw);
        return;
      } catch (_) {
        continue;
      }
    }
  }

  void delete(String id) {
    final raw = _raw;
    raw.removeWhere((entry) {
      try {
        return (jsonDecode(entry) as Map)['id'] == id;
      } catch (_) {
        // Drop undecodable rows while we are here.
        return true;
      }
    });
    _write(raw);
  }

  void clear() {
    SharedPreferencesHelper.localStorage.remove(_key);
    notifyListeners();
  }
}
