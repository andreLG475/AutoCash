import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../data/offline_repository.dart';
import '../models/offline_models.dart';

class OfflineSyncService {
  OfflineSyncService({
    required OfflineRepository repository,
    required Future<bool> Function() checkConnection,
    required Future<bool> Function({
      required List<CarroLocal> cars,
      required List<GastoLocal> gastos,
    })
    sendToServer,
  }) : _repository = repository,
       _checkConnection = checkConnection,
       _sendToServer = sendToServer;

  final OfflineRepository _repository;
  final Future<bool> Function() _checkConnection;
  final Future<bool> Function({
    required List<CarroLocal> cars,
    required List<GastoLocal> gastos,
  })
  _sendToServer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<int> syncIfOnline() async {
    final isOnline = await _checkConnection();
    if (!isOnline) {
      return 0;
    }

    return _repository.syncPendingChanges(sendToServer: _sendToServer);
  }

  void startListening({
    required Future<void> Function(int syncedCount) onSynced,
  }) {
    _subscription ??= Connectivity().onConnectivityChanged.listen((
      result,
    ) async {
      if (result.contains(ConnectivityResult.none) || result.isEmpty) {
        return;
      }

      final syncedCount = await syncIfOnline();
      if (syncedCount > 0) {
        await onSynced(syncedCount);
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
