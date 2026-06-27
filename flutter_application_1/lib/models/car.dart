class Car {
  final int? id;
  final String marca;
  final String modelo;
  final int ano;
  final int kmInicial;
  final int km;
  final String image;
  final double gastos;

  Car({
    this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.km,
    int? kmInicial,
    required this.image,
    required this.gastos,
  }) : kmInicial = kmInicial ?? km;

  Car copy({
    int? id,
    String? marca,
    String? modelo,
    int? ano,
    int? kmInicial,
    int? km,
    String? image,
    double? gastos,
  }) {
    return Car(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      kmInicial: kmInicial ?? this.kmInicial,
      km: km ?? this.km,
      image: image ?? this.image,
      gastos: gastos ?? this.gastos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'kmInicial': kmInicial,
      'km': km,
      'image': image,
      'gastos': gastos,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] as int?,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      ano: map['ano'] as int,
      kmInicial: (map['kmInicial'] as int?) ?? (map['km'] as int),
      km: map['km'] as int,
      image: map['image'] as String,
      gastos: (map['gastos'] as num).toDouble(),
    );
  }
}
