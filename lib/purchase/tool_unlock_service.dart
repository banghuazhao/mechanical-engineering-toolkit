import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/rewarded_tool_ad.dart';

enum ToolUnlockResult { unlocked, skipped, unavailable, saveFailed, busy }

abstract interface class ToolUnlockPersistence {
  Set<int> read();
  Future<bool> write(Set<int> toolIds);
}

class SharedPreferencesToolUnlockPersistence implements ToolUnlockPersistence {
  static const key = 'REWARDED_TOOL_UNLOCKS_V1';

  @override
  Set<int> read() =>
      (SharedPreferencesHelper.localStorage.getStringList(key) ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  @override
  Future<bool> write(Set<int> toolIds) => SharedPreferencesHelper.localStorage
      .setStringList(key, toolIds.map((id) => '$id').toList());
}

/// Device-local, permanent tool unlocks. This never modifies the paid entitlement.
class ToolUnlockService extends ChangeNotifier {
  ToolUnlockService(
      {ToolUnlockPersistence? persistence, RewardedToolAdClient? ads})
      : _persistence = persistence ?? SharedPreferencesToolUnlockPersistence(),
        _ads = ads ?? GoogleRewardedToolAdClient() {
    _unlocked = Set.unmodifiable(_persistence.read());
  }

  final ToolUnlockPersistence _persistence;
  final RewardedToolAdClient _ads;
  late Set<int> _unlocked;
  bool _busy = false;
  bool _disposed = false;

  Set<int> get unlockedToolIds => _unlocked;
  bool get isBusy => _busy;

  Future<ToolUnlockResult> unlockWithAd(int toolId) async {
    if (_unlocked.contains(toolId)) return ToolUnlockResult.unlocked;
    if (_busy) return ToolUnlockResult.busy;
    if (!AppPlatform.current.supportsRewardedToolUnlocks) {
      return ToolUnlockResult.unavailable;
    }
    _busy = true;
    _notify();
    Future<bool>? saved;
    try {
      final outcome = await _ads.show(onReward: () {
        // Persist at the reward callback, even if the route has since closed.
        // A duplicate SDK callback must not grant a second reward.
        saved ??= _save(toolId);
      });
      if (saved != null) {
        return await saved!
            ? ToolUnlockResult.unlocked
            : ToolUnlockResult.saveFailed;
      }
      return outcome == RewardedToolAdOutcome.dismissed
          ? ToolUnlockResult.skipped
          : ToolUnlockResult.unavailable;
    } catch (_) {
      if (saved != null) {
        return await saved!
            ? ToolUnlockResult.unlocked
            : ToolUnlockResult.saveFailed;
      }
      return ToolUnlockResult.unavailable;
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<bool> _save(int toolId) async {
    try {
      final updated = {..._unlocked, toolId};
      if (!await _persistence.write(updated)) return false;
      _unlocked = Set.unmodifiable(updated);
      _notify();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
