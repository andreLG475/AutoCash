import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/car.dart';
import '../models/gasto.dart';
import '../models/user.dart';
import '../services/expense_logic.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  static int? _currentUserId;

  final List<User> _webUsers = [];

  DatabaseHelper._();

  int? get currentUserId => _currentUserId;

  void setCurrentUserId(int? userId) {
    _currentUserId = userId;
  }

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Database directly não está disponível no web. Use fallback em memória.',
      );
    }

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  bool get _isDesktop {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  Future<Database> _initDatabase() async {
    if (_isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = join(await getDatabasesPath(), 'autocash.db');

    final db = await openDatabase(
      dbPath,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _ensureSchema(db);
    return db;
  }

  Future<void> resetDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }

    final dbPath = join(await getDatabasesPath(), 'autocash.db');
    await deleteDatabase(dbPath);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        ano INTEGER NOT NULL,
        kmInicial INTEGER NOT NULL,
        km INTEGER NOT NULL,
        image TEXT,
        gastos REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        valor REAL NOT NULL,
        data TEXT NOT NULL,
        quilometragem INTEGER NOT NULL,
        descricaoDetalhada TEXT,
        notaFiscal TEXT,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        photoPath TEXT
      )
    ''');
  }

  Future<void> _ensureColumn(
    Database db,
    String tableName,
    String columnName,
    String definition,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    final hasColumn = result.any((row) => row['name'] == columnName);
    if (!hasColumn) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $definition',
      );
    }
  }

  Future<void> _ensureSchema(Database db) async {
    await _ensureColumn(db, 'cars', 'userId', 'INTEGER');
    await _ensureColumn(db, 'users', 'photoPath', 'TEXT');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE cars ADD COLUMN kmInicial INTEGER');
      await db.rawUpdate(
        'UPDATE cars SET kmInicial = km WHERE kmInicial IS NULL',
      );
      await db.rawUpdate(
        'UPDATE cars SET kmInicial = 0 WHERE kmInicial IS NULL',
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await _ensureColumn(db, 'cars', 'userId', 'INTEGER');
      await _ensureColumn(db, 'users', 'photoPath', 'TEXT');
    }
  }

  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existingUser = await getUserByEmail(normalizedEmail);
    if (existingUser != null) {
      throw Exception('Já existe um usuário cadastrado com este e-mail.');
    }

    if (kIsWeb) {
      final user = User(
        id: _webUsers.isEmpty
            ? 1
            : _webUsers.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) +
                  1,
        name: name,
        email: normalizedEmail,
        password: password,
      );
      _webUsers.add(user);
      return user;
    }

    final db = await database;
    final id = await db.insert('users', {
      'name': name,
      'email': normalizedEmail,
      'password': password,
      'photoPath': null,
    });

    return User(id: id, name: name, email: normalizedEmail, password: password);
  }

  Future<User?> authenticateUser({
    required String identifier,
    required String password,
  }) async {
    final normalizedIdentifier = identifier.trim().toLowerCase();
    if (kIsWeb) {
      final filtered = _webUsers.where(
        (user) =>
            (user.email == normalizedIdentifier ||
                user.name.toLowerCase() == normalizedIdentifier) &&
            user.password == password,
      );
      return filtered.isEmpty ? null : filtered.first;
    }

    final db = await database;
    final result = await db.query(
      'users',
      where: '(email = ? OR LOWER(name) = ?) AND password = ?',
      whereArgs: [normalizedIdentifier, normalizedIdentifier, password],
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (kIsWeb) {
      final filtered = _webUsers.where((user) => user.email == normalizedEmail);
      return filtered.isEmpty ? null : filtered.first;
    }

    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<User?> getUserById(int id) async {
    if (kIsWeb) {
      final filtered = _webUsers.where((user) => user.id == id);
      return filtered.isEmpty ? null : filtered.first;
    }

    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<User> updateUserProfile({
    required int userId,
    required String name,
    required String email,
    required String password,
    String? photoPath,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingUser = await getUserByEmail(normalizedEmail);
    if (existingUser != null && existingUser.id != userId) {
      throw Exception('Já existe um usuário cadastrado com este e-mail.');
    }

    if (kIsWeb) {
      final index = _webUsers.indexWhere((user) => user.id == userId);
      if (index < 0) {
        throw Exception('Usuário não encontrado para atualização.');
      }

      final updatedUser = _webUsers[index].copy(
        name: name,
        email: normalizedEmail,
        password: password,
      );
      _webUsers[index] = updatedUser;
      return updatedUser;
    }

    final db = await database;
    await db.update(
      'users',
      {
        'name': name,
        'email': normalizedEmail,
        'password': password,
        'photoPath': photoPath,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    final updatedUser = await getUserById(userId);
    if (updatedUser == null) {
      throw Exception('Usuário não encontrado para atualização.');
    }

    return updatedUser;
  }

  Future<int> insertCar(Car car) async {
    final db = await database;
    final userId = _currentUserId ?? car.userId;
    final data = car.toMap()..['userId'] = userId;
    return await db.insert('cars', data);
  }

  Future<List<Car>> getCars({int? userId}) async {
    final db = await database;
    final currentUserId = userId ?? _currentUserId;
    if (currentUserId == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'cars',
      where: 'userId = ?',
      whereArgs: [currentUserId],
    );
    return List.generate(maps.length, (i) => Car.fromMap(maps[i]));
  }

  Future<Car?> getCarById(int id, {int? userId}) async {
    final db = await database;
    final currentUserId = userId ?? _currentUserId;
    final List<Map<String, dynamic>> maps = await db.query(
      'cars',
      where: currentUserId == null ? 'id = ?' : 'id = ? AND userId = ?',
      whereArgs: currentUserId == null ? [id] : [id, currentUserId],
    );
    if (maps.isEmpty) return null;
    return Car.fromMap(maps.first);
  }

  Future<int> updateCar(Car car) async {
    final db = await database;
    final data = car.toMap();
    if (data['userId'] == null && _currentUserId != null) {
      data['userId'] = _currentUserId;
    }
    return await db.update('cars', data, where: 'id = ?', whereArgs: [car.id]);
  }

  Future<Car> syncCarMetrics(int carId, {DateTime? referenceDate}) async {
    final car = await getCarById(carId);
    if (car == null) {
      throw Exception('Veículo não encontrado');
    }

    final gastos = await getGastosByCarId(carId);
    final monthlyTotal = calculateMonthlyTotal(
      gastos: gastos,
      referenceDate: referenceDate ?? DateTime.now(),
    );
    final latestMileage = gastos.isEmpty
        ? car.kmInicial
        : gastos
              .map((gasto) => gasto.quilometragem)
              .reduce((a, b) => a > b ? a : b);
    final currentMileage = latestMileage >= car.kmInicial
        ? latestMileage
        : car.kmInicial;

    final updatedCar = car.copy(km: currentMileage, gastos: monthlyTotal);
    await updateCar(updatedCar);
    return updatedCar;
  }

  Future<int> deleteCar(int id) async {
    final db = await database;
    if (_currentUserId == null) {
      return 0;
    }
    return await db.delete(
      'cars',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, _currentUserId],
    );
  }

  Future<int> insertGasto(Gasto gasto) async {
    final db = await database;
    return await db.insert('gastos', gasto.toMap());
  }

  Future<List<Gasto>> getGastosByCarId(int carId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gastos',
      where: 'carId = ?',
      whereArgs: [carId],
      orderBy: 'data DESC',
    );
    return List.generate(maps.length, (i) => Gasto.fromMap(maps[i]));
  }

  Future<Gasto?> getGastoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Gasto.fromMap(maps.first);
  }

  Future<int> updateGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> deleteGasto(int id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalGastosByCarId(int carId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM gastos WHERE carId = ?',
      [carId],
    );
    return result.first['total'] as double? ?? 0.0;
  }
}
