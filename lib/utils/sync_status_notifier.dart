import 'package:flutter/foundation.dart';
import 'sync_status.dart';

/// A ValueNotifier for sync status that enables targeted widget rebuilds.
/// 
/// Use this with ValueListenableBuilder to rebuild only the widgets that
/// display sync status, rather than triggering full parent widget rebuilds.
/// 
/// Example:
/// ```dart
/// ValueListenableBuilder<SyncStatusState>(
///   valueListenable: syncStatusNotifier,
///   builder: (context, state, child) {
///     return ConnectionStatusIndicator(
///       isOnline: state.isOnline,
///       syncStatus: state.syncStatus,
///     );
///   },
/// )
/// ```
class SyncStatusNotifier extends ValueNotifier<SyncStatusState> {
  SyncStatusNotifier() : super(const SyncStatusState());

  /// Update sync status only if it changed
  void updateSyncStatus(SyncStatus status) {
    if (value.syncStatus != status) {
      value = value.copyWith(syncStatus: status);
    }
  }

  /// Update online status only if it changed
  void updateOnlineStatus(bool isOnline) {
    if (value.isOnline != isOnline) {
      value = value.copyWith(isOnline: isOnline);
    }
  }

  /// Update both statuses at once, only notifying if either changed
  void update({SyncStatus? syncStatus, bool? isOnline}) {
    final newSyncStatus = syncStatus ?? value.syncStatus;
    final newIsOnline = isOnline ?? value.isOnline;
    
    if (newSyncStatus != value.syncStatus || newIsOnline != value.isOnline) {
      value = SyncStatusState(
        syncStatus: newSyncStatus,
        isOnline: newIsOnline,
      );
    }
  }
}

/// Immutable state class for sync status
@immutable
class SyncStatusState {
  final SyncStatus syncStatus;
  final bool isOnline;

  const SyncStatusState({
    this.syncStatus = SyncStatus.synced,
    this.isOnline = true,
  });

  SyncStatusState copyWith({
    SyncStatus? syncStatus,
    bool? isOnline,
  }) {
    return SyncStatusState(
      syncStatus: syncStatus ?? this.syncStatus,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncStatusState &&
        other.syncStatus == syncStatus &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => Object.hash(syncStatus, isOnline);
}
