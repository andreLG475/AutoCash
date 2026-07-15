// Classe que define o modelo de usuário para sincronização offline
class UsuarioLocal {
  // ID único do usuário
  final String id;
  // Nome do usuário
  final String nome;
  // Email do usuário
  final String email;
  // Token de autenticação para sincronização com servidor
  final String token;

  // Construtor constante que inicializa todos os campos
  const UsuarioLocal({
    required this.id,
    required this.nome,
    required this.email,
    required this.token,
  });

  // Método que converte o usuário local para um mapa (dicionário)
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'email': email, 'token': token};
  }

  // Factory constructor que cria um UsuarioLocal a partir de um mapa
  factory UsuarioLocal.fromMap(Map<String, dynamic> map) {
    return UsuarioLocal(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      token: map['token'] as String,
    );
  }
}

// Classe que define o modelo de carro para sincronização offline
class CarroLocal {
  // ID único do carro
  final String id;
  // ID do usuário proprietário do carro
  final String usuarioId;
  // Nome/modelo do carro
  final String nomeModelo;
  // Marca/fabricante do carro
  final String marca;
  // Placa do carro
  final String placa;
  // Flag que indica se foi sincronizado com o servidor (0 = não sincronizado, 1 = sincronizado)
  final int sincronizado;
  // Data/hora da última atualização do carro
  final String atualizadoEm;

  // Construtor constante que inicializa todos os campos
  const CarroLocal({
    required this.id,
    required this.usuarioId,
    required this.nomeModelo,
    required this.marca,
    required this.placa,
    required this.sincronizado,
    required this.atualizadoEm,
  });

  // Método que converte o carro local para um mapa (dicionário)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nome_modelo': nomeModelo,
      'marca': marca,
      'placa': placa,
      'sincronizado': sincronizado,
      'atualizado_em': atualizadoEm,
    };
  }

  // Factory constructor que cria um CarroLocal a partir de um mapa
  factory CarroLocal.fromMap(Map<String, dynamic> map) {
    return CarroLocal(
      id: map['id'] as String,
      usuarioId: map['usuario_id'] as String,
      nomeModelo: map['nome_modelo'] as String,
      marca: map['marca'] as String,
      placa: map['placa'] as String,
      sincronizado: map['sincronizado'] as int,
      atualizadoEm: map['atualizado_em'] as String,
    );
  }
}

// Classe que define o modelo de gasto para sincronização offline
class GastoLocal {
  // ID único do gasto
  final String id;
  // ID do carro ao qual o gasto pertence
  final String carroId;
  // Tipo de gasto/manutenção
  final String tipoGasto;
  // Valor do gasto em reais
  final double valor;
  // Data do gasto
  final String dataGasto;
  // Quilometragem do carro no momento do gasto
  final int quilometragem;
  // Observações/descrição do gasto
  final String observacao;
  // Flag que indica se foi sincronizado com o servidor (0 = não sincronizado, 1 = sincronizado)
  final int sincronizado;
  // Data/hora da última atualização do gasto
  final String atualizadoEm;

  // Construtor constante que inicializa todos os campos
  const GastoLocal({
    required this.id,
    required this.carroId,
    required this.tipoGasto,
    required this.valor,
    required this.dataGasto,
    required this.quilometragem,
    required this.observacao,
    required this.sincronizado,
    required this.atualizadoEm,
  });

  // Método que converte o gasto local para um mapa (dicionário)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carro_id': carroId,
      'tipo_gasto': tipoGasto,
      'valor': valor,
      'data_gasto': dataGasto,
      'quilometragem': quilometragem,
      'observacao': observacao,
      'sincronizado': sincronizado,
      'atualizado_em': atualizadoEm,
    };
  }

  // Factory constructor que cria um GastoLocal a partir de um mapa
  factory GastoLocal.fromMap(Map<String, dynamic> map) {
    return GastoLocal(
      id: map['id'] as String,
      carroId: map['carro_id'] as String,
      tipoGasto: map['tipo_gasto'] as String,
      valor: (map['valor'] as num).toDouble(),
      dataGasto: map['data_gasto'] as String,
      quilometragem: map['quilometragem'] as int,
      observacao: map['observacao'] as String,
      sincronizado: map['sincronizado'] as int,
      atualizadoEm: map['atualizado_em'] as String,
    );
  }
}
