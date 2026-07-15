// Classe que define o modelo de dados de um gasto/manutenção do carro
class Gasto {
  // ID único do gasto no banco de dados (null se ainda não foi salvo)
  final int? id;
  // ID do carro ao qual o gasto pertence
  final int carId;
  // Descrição do gasto (ex: "Troca de óleo", "Revisão")
  final String descricao;
  // Valor/custo do gasto em reais
  final double valor;
  // Data do gasto em formato string (ex: "2024-01-15")
  final String data;
  // Quilometragem do carro quando o gasto foi feito
  final int quilometragem;
  // Descrição detalhada/observações sobre o gasto
  final String? descricaoDetalhada;
  // Caminho para a nota fiscal/arquivo do gasto
  final String? notaFiscal;

  // Construtor que inicializa todos os campos do gasto
  Gasto({
    this.id,
    required this.carId,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.quilometragem,
    this.descricaoDetalhada,
    this.notaFiscal,
  });

  // Método que cria uma cópia do gasto com alguns campos atualizados
  Gasto copy({
    // Parâmetros opcionais para atualizar
    int? id,
    int? carId,
    String? descricao,
    double? valor,
    String? data,
    int? quilometragem,
    String? descricaoDetalhada,
    String? notaFiscal,
  }) {
    // Retorna um novo Gasto com os valores atualizados ou mantém os antigos
    return Gasto(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      quilometragem: quilometragem ?? this.quilometragem,
      descricaoDetalhada: descricaoDetalhada ?? this.descricaoDetalhada,
      notaFiscal: notaFiscal ?? this.notaFiscal,
    );
  }

  // Método que converte o gasto para um mapa (dicionário)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'descricao': descricao,
      'valor': valor,
      'data': data,
      'quilometragem': quilometragem,
      'descricaoDetalhada': descricaoDetalhada,
      'notaFiscal': notaFiscal,
    };
  }

  // Factory constructor que cria um Gasto a partir de um mapa (vindo do banco de dados)
  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as int?,
      carId: map['carId'] as int,
      descricao: map['descricao'] as String,
      valor: (map['valor'] as num).toDouble(),
      data: map['data'] as String,
      quilometragem: map['quilometragem'] as int,
      descricaoDetalhada: map['descricaoDetalhada'] as String?,
      notaFiscal: map['notaFiscal'] as String?,
    );
  }
}
