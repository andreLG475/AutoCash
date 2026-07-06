class UsuarioLocal {
  final String id;
  final String nome;
  final String email;
  final String token;

  const UsuarioLocal({
    required this.id,
    required this.nome,
    required this.email,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'email': email, 'token': token};
  }

  factory UsuarioLocal.fromMap(Map<String, dynamic> map) {
    return UsuarioLocal(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      token: map['token'] as String,
    );
  }
}

class CarroLocal {
  final String id;
  final String usuarioId;
  final String nomeModelo;
  final String marca;
  final String placa;
  final int sincronizado;
  final String atualizadoEm;

  const CarroLocal({
    required this.id,
    required this.usuarioId,
    required this.nomeModelo,
    required this.marca,
    required this.placa,
    required this.sincronizado,
    required this.atualizadoEm,
  });

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

class GastoLocal {
  final String id;
  final String carroId;
  final String tipoGasto;
  final double valor;
  final String dataGasto;
  final int quilometragem;
  final String observacao;
  final int sincronizado;
  final String atualizadoEm;

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
