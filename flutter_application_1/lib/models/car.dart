// Classe que define o modelo de dados de um carro/veículo
class Car {
  // ID único do carro no banco de dados (null se ainda não foi salvo)
  final int? id;
  // ID do usuário proprietário do carro (null se sem proprietário)
  final int? userId;
  // Marca/fabricante do carro (ex: Toyota, Chevrolet)
  final String marca;
  // Modelo do carro (ex: Corolla, Chevette)
  final String modelo;
  // Ano de fabricação do carro
  final int ano;
  // Quilometragem inicial do carro (quando foi cadastrado)
  final int kmInicial;
  // Quilometragem atual do carro
  final int km;
  // Caminho para a imagem do carro (foto/URL)
  final String image;
  // Total de gastos com manutenção do carro
  final double gastos;

  // Construtor que inicializa todos os campos do carro
  Car({
    this.id,
    this.userId,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.km,
    int? kmInicial,
    required this.image,
    required this.gastos,
    // Se kmInicial não for fornecido, usa o valor de km
  }) : kmInicial = kmInicial ?? km;

  // Método que cria uma cópia do carro com alguns campos atualizados
  Car copy({
    // Parâmetros opcionais para atualizar
    int? id,
    int? userId,
    String? marca,
    String? modelo,
    int? ano,
    int? kmInicial,
    int? km,
    String? image,
    double? gastos,
  }) {
    // Retorna um novo Car com os valores atualizados ou mantém os antigos
    return Car(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      kmInicial: kmInicial ?? this.kmInicial,
      km: km ?? this.km,
      image: image ?? this.image,
      gastos: gastos ?? this.gastos,
    );
  }

  // Método que converte o carro para um mapa (dicionário)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'kmInicial': kmInicial,
      'km': km,
      'image': image,
      'gastos': gastos,
    };
  }

  // Factory constructor que cria um Car a partir de um mapa (vindo do banco de dados)
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
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
