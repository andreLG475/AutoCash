class Gasto {
  final int? id;
  final int carId;
  final String descricao;
  final double valor;
  final String data;
  final int quilometragem;
  final String? descricaoDetalhada;
  final String? notaFiscal;

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

  Gasto copy({
    int? id,
    int? carId,
    String? descricao,
    double? valor,
    String? data,
    int? quilometragem,
    String? descricaoDetalhada,
    String? notaFiscal,
  }) {
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
