import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/ui/result_snapshot.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

/// One calculation inside a project.
///
/// Always carries enough to reopen the tool it came from ([toolId] and the
/// inputs it was run with). [snapshot] is added when the entry was kept from a
/// result page, which is the only place the computed numbers exist — the
/// calculators have no headless "inputs in, results out" path, so an entry
/// without a snapshot can be reopened but cannot be reported on.
@immutable
class ProjectEntry {
  const ProjectEntry({
    required this.toolId,
    required this.inputs,
    required this.addedAt,
    this.snapshot,
  });

  final int toolId;
  final Map<String, String> inputs;
  final DateTime addedAt;

  /// The result as it stood when kept, or null for an entry saved from
  /// history, where only the inputs were ever recorded.
  final ResultSnapshot? snapshot;

  Map<String, dynamic> toJson() => {
        'toolId': toolId,
        'inputs': inputs,
        'addedAt': addedAt.toIso8601String(),
        if (snapshot != null) 'snapshot': snapshot!.toJson(),
      };

  /// Throws [FormatException] when the entry has no tool to belong to.
  factory ProjectEntry.fromJson(Map<String, dynamic> json) {
    final toolId = json['toolId'];
    if (toolId is! int) {
      throw const FormatException('project entry is missing its toolId');
    }
    final rawSnapshot = json['snapshot'];
    return ProjectEntry(
      toolId: toolId,
      // Coerced to String: a calculator writes display text, but a
      // hand-edited or older record may hold a number.
      inputs: {
        for (final entry in (json['inputs'] as Map? ?? const {}).entries)
          '${entry.key}': '${entry.value}',
      },
      addedAt:
          DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      snapshot: rawSnapshot is Map<String, dynamic>
          ? ResultSnapshot.fromJson(rawSnapshot)
          : null,
    );
  }
}

/// A named collection of calculations the user chose to keep.
///
/// Unlike a [HistoryEntry], a project is permanent: it is never evicted, and
/// the user names it after the thing they are designing ("Valve spring — rev
/// C") rather than the tool or the time. A project holds however many
/// calculations belong to that thing, which is what lets one report cover a
/// whole assembly rather than a single sum.
///
/// ## Compatibility contract
///
/// Each entry's inputs are keyed by that calculator's own input labels, the
/// same map [ToolHistory.record] captures and [Tool.action] replays via
/// `initialInputs`. History tolerates those keys drifting because entries are
/// evicted after 50; a project the user expects to keep for a year does not.
///
/// Reading is deliberately tolerant, so a rename degrades instead of breaking:
/// a key a calculator no longer recognizes is ignored, and a key it expects
/// but does not find leaves that field blank. Renaming an input label
/// therefore costs the user that one prefilled field, not the whole project.
///
/// [currentSchemaVersion] is stored so a change of shape can be migrated
/// rather than guessed at. Version 1 held a single `toolId` and `inputs` at
/// the top level; version 2 holds [entries], and a v1 record is read as a
/// project of one entry. Bump it whenever the meaning of a stored field
/// changes, and handle the older value in [SavedProject.fromJson].
class SavedProject {
  const SavedProject({
    required this.id,
    required this.name,
    required this.entries,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Current storage shape. See the compatibility contract above.
  static const int currentSchemaVersion = 2;

  final String id;
  final String name;

  /// The calculations in this project, oldest first — the order they were
  /// added, which is the order a report reads in.
  final List<ProjectEntry> entries;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// The project's first calculation: what tapping the project reopens, and
  /// what a single-entry project is entirely made of.
  ProjectEntry get primary => entries.first;

  int get toolId => primary.toolId;
  Map<String, String> get inputs => primary.inputs;

  /// Entries a report can actually render numbers for.
  List<ProjectEntry> get reportable =>
      [for (final entry in entries) if (entry.snapshot != null) entry];

  SavedProject copyWith({
    String? name,
    List<ProjectEntry>? entries,
    DateTime? updatedAt,
  }) =>
      SavedProject(
        id: id,
        name: name ?? this.name,
        entries: entries ?? this.entries,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'v': currentSchemaVersion,
        'id': id,
        'name': name,
        'entries': [for (final entry in entries) entry.toJson()],
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Throws [FormatException] when the record is unusable. Callers read
  /// through [SavedProjects.projects], which drops such records rather than
  /// letting one bad row take the whole list down.
  factory SavedProject.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('saved project is missing its id');
    }
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    final updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? createdAt;

    final rawEntries = json['entries'];
    final entries = <ProjectEntry>[];
    if (rawEntries is List) {
      for (final raw in rawEntries) {
        if (raw is! Map<String, dynamic>) continue;
        // One unreadable entry is dropped; the rest of the project survives.
        try {
          entries.add(ProjectEntry.fromJson(raw));
        } catch (_) {
          continue;
        }
      }
    } else {
      // Version 1: one calculation, stored flat. Read as a project of one.
      entries.add(ProjectEntry.fromJson({
        ...json,
        'addedAt': createdAt.toIso8601String(),
      }));
    }

    if (entries.isEmpty) {
      throw const FormatException('saved project has no usable entries');
    }

    return SavedProject(
      id: id,
      name: json['name'] as String? ?? '',
      entries: entries,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

  /// Persists a new project of one calculation and returns it.
  SavedProject save({
    required String name,
    required int toolId,
    required Map<String, String> inputs,
    ResultSnapshot? snapshot,
  }) {
    final now = DateTime.now();
    final project = SavedProject(
      id: '${now.microsecondsSinceEpoch}-$toolId',
      name: name.trim(),
      entries: [
        ProjectEntry(
          toolId: toolId,
          inputs: Map<String, String>.from(inputs),
          addedAt: now,
          snapshot: snapshot,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    _write([..._raw, jsonEncode(project.toJson())]);
    return project;
  }

  /// Appends a calculation to an existing project.
  ///
  /// This is what turns a project from a saved sum into the record of an
  /// assembly: several calculations under one name, which one report can then
  /// cover end to end.
  void addEntry(
    String projectId, {
    required int toolId,
    required Map<String, String> inputs,
    ResultSnapshot? snapshot,
  }) =>
      _update(
        projectId,
        (project) => project.copyWith(
          entries: [
            ...project.entries,
            ProjectEntry(
              toolId: toolId,
              inputs: Map<String, String>.from(inputs),
              addedAt: DateTime.now(),
              snapshot: snapshot,
            ),
          ],
          updatedAt: DateTime.now(),
        ),
      );

  /// Drops one calculation from a project.
  ///
  /// Removing the last entry deletes the project: a project with nothing in it
  /// cannot be reopened or reported on, and leaving an empty shell in the list
  /// would only be something else to tidy up.
  void removeEntry(String projectId, int index) {
    final project = byId(projectId);
    if (project == null || index < 0 || index >= project.entries.length) return;
    if (project.entries.length == 1) {
      delete(projectId);
      return;
    }
    _update(
      projectId,
      (current) => current.copyWith(
        entries: [...current.entries]..removeAt(index),
        updatedAt: DateTime.now(),
      ),
    );
  }

  void rename(String id, String name) =>
      _update(id, (project) => project.copyWith(
            name: name.trim(),
            updatedAt: DateTime.now(),
          ));

  /// Replaces the first calculation's inputs — for "save over" after re-running
  /// a tool with tweaked numbers.
  void updateInputs(String id, Map<String, String> inputs) =>
      _update(id, (project) {
        final primary = project.primary;
        return project.copyWith(
          entries: [
            ProjectEntry(
              toolId: primary.toolId,
              inputs: Map<String, String>.from(inputs),
              addedAt: primary.addedAt,
              // The stored result described the old inputs, so it is dropped
              // rather than left to describe numbers that are no longer there.
              snapshot: null,
            ),
            ...project.entries.skip(1),
          ],
          updatedAt: DateTime.now(),
        );
      });

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
