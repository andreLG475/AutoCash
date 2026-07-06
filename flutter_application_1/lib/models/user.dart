class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? photoPath;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photoPath,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      photoPath: map['photoPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photoPath': photoPath,
    };
  }

  User copy({
    int? id,
    String? name,
    String? email,
    String? password,
    String? photoPath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
