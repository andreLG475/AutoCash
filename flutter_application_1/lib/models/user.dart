// Classe que define o modelo de dados do usuário
class User {
  // ID único do usuário no banco de dados (null se ainda não foi salvo)
  final int? id;
  // Nome completo do usuário
  final String name;
  // Email do usuário
  final String email;
  // Senha do usuário (armazenada de forma segura)
  final String password;
  // Caminho para a foto de perfil do usuário
  final String? photoPath;

  // Construtor constante que inicializa todos os campos
  const User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photoPath,
  });

  // Factory constructor que cria um User a partir de um mapa (vindo do banco de dados)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      photoPath: map['photoPath'] as String?,
    );
  }

  // Método que converte o usuário para um mapa (dicionário)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photoPath': photoPath,
    };
  }

  // Método que cria uma cópia do usuário com alguns campos atualizados
  User copy({
    // Parâmetros opcionais para atualizar
    int? id,
    String? name,
    String? email,
    String? password,
    String? photoPath,
  }) {
    // Retorna um novo User com os valores atualizados ou mantém os antigos
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
