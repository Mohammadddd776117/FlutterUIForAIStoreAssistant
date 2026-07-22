/// Placeholder for the future cloud synchronisation service.
///
/// When implemented, this class will be responsible for:
/// - Pushing locally created / updated records to the remote API.
/// - Pulling remote changes and merging them into the local Drift database.
/// - Resolving conflicts using a last-write-wins (or custom) strategy.
/// - Tracking sync state (last-synced timestamp, pending-upload queue).
/// - Handling connectivity changes and retrying failed uploads.
///
/// ## Integration plan
/// 1. Wire [AppDatabase] to a remote REST / GraphQL endpoint via
///    [ApiService].
/// 2. Add a `syncedAt` column and a `pendingSync` boolean to each table.
/// 3. Call [push] after every local write to queue the record for upload.
/// 4. Call [pull] periodically (or on app foreground) to fetch remote changes.
///
/// **Do NOT implement cloud sync logic here yet.**
/// This file is a placeholder only.
class SyncService {
  // TODO(sync): inject AppDatabase and ApiService when implementing.

  /// Pushes all locally modified records to the remote API.
  ///
  /// Not yet implemented — does nothing.
  Future<void> push() async {
    // TODO(sync): implement upload of pending local changes.
  }

  /// Fetches remote changes and merges them into the local database.
  ///
  /// Not yet implemented — does nothing.
  Future<void> pull() async {
    // TODO(sync): implement download and merge of remote changes.
  }

  /// Runs a full bidirectional sync: [pull] then [push].
  ///
  /// Not yet implemented — does nothing.
  Future<void> sync() async {
    await pull();
    await push();
  }
}
