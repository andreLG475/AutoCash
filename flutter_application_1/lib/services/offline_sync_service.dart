// Importa o pacote de async/await
import 'dart:async';

// Importa o pacote de detectar conectividade
import 'package:connectivity_plus/connectivity_plus.dart';

// Importa o repositório offline para sincronização
import '../data/offline_repository.dart';
// Importa os modelos de dados offline
import '../models/offline_models.dart';

// Classe que gerencia a sincronização de dados quando o dispositivo está offline/online
class OfflineSyncService {
  // Construtor que recebe injeção de dependência
  OfflineSyncService({
    required OfflineRepository repository,
    // Função para verificar se há conexão com a internet
    required Future<bool> Function() checkConnection,
    // Função para enviar dados para o servidor
    required Future<bool> Function({
      required List<CarroLocal> cars,
      required List<GastoLocal> gastos,
    })
    sendToServer,
  }) : _repository = repository,
       _checkConnection = checkConnection,
       _sendToServer = sendToServer;

  // Referência ao repositório offline
  final OfflineRepository _repository;
  // Função para verificar conexão
  final Future<bool> Function() _checkConnection;
  // Função para enviar dados ao servidor
  final Future<bool> Function({
    required List<CarroLocal> cars,
    required List<GastoLocal> gastos,
  })
  _sendToServer;
  // Subscription para monitorar mudanças de conectividade
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Método que sincroniza dados se estiver online
  Future<int> syncIfOnline() async {
    // Verifica se está online
    final isOnline = await _checkConnection();
    // Se estiver offline, retorna 0
    if (!isOnline) {
      return 0;
    }

    // Se estiver online, sincroniza dados pendentes com o servidor
    return _repository.syncPendingChanges(sendToServer: _sendToServer);
  }

  // Método que inicia a escuta de mudanças de conectividade
  void startListening({
    required Future<void> Function(int syncedCount) onSynced,
  }) {
    // Inicia a subscription para monitorar mudanças de conectividade
    _subscription ??= Connectivity().onConnectivityChanged.listen((
      result,
    ) async {
      // Verifica se não há conexão ou a lista de resultados está vazia
      if (result.contains(ConnectivityResult.none) || result.isEmpty) {
        return;
      }

      // Sincroniza dados se houver conexão
      final syncedCount = await syncIfOnline();
      // Se houver dados sincronizados, chama o callback onSynced
      if (syncedCount > 0) {
        await onSynced(syncedCount);
      }
    });
  }

  // Método que libera recursos da subscription
  Future<void> dispose() async {
    // Cancela a subscription
    await _subscription?.cancel();
    // Define como null
    _subscription = null;
  }
}
