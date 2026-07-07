import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/car.dart';
import '../models/gasto.dart';
import '../models/user.dart';
import '../services/expense_logic.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  static int? _currentUserId;

  static const String _usersKey = 'autocash_users';
  static const String _carsKey = 'autocash_cars';
  static const String _gastosKey = 'autocash_gastos';
  static const String _currentUserKey = 'autocash_current_user_id';

  final List<User> _webUsers = [];
  final List<Car> _webCars = [];
  final List<Gasto> _webGastos = [];

  DatabaseHelper._();

  int? get currentUserId => _currentUserId;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt(_currentUserKey);

    if (kIsWeb) {
      final users = await _loadPersistedUsers();
      final cars = await _loadPersistedCars();
      final gastos = await _loadPersistedGastos();
      _webUsers
        ..clear()
        ..addAll(users);
      _webCars
        ..clear()
        ..addAll(cars);
      _webGastos
        ..clear()
        ..addAll(gastos);
    }
  }

  Future<void> setCurrentUserId(int? userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_currentUserKey);
      return;
    }
    await prefs.setInt(_currentUserKey, userId);
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
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      _webUsers.clear();
      _webCars.clear();
      _webGastos.clear();
      _currentUserId = null;
      await prefs.remove(_usersKey);
      await prefs.remove(_carsKey);
      await prefs.remove(_gastosKey);
      await prefs.remove(_currentUserKey);
      return;
    }

    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }

    final dbPath = join(await getDatabasesPath(), 'autocash.db');
    await deleteDatabase(dbPath);
    await prefs.remove(_usersKey);
    await prefs.remove(_carsKey);
    await prefs.remove(_gastosKey);
    await prefs.remove(_currentUserKey);
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

  Future<List<User>> _loadPersistedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => User.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _savePersistedUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = users.map((user) => user.toMap()).toList();
    await prefs.setString(_usersKey, jsonEncode(payload));
  }

  Future<List<Car>> _loadPersistedCars() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_carsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Car.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _savePersistedCars(List<Car> cars) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = cars.map((car) => car.toMap()).toList();
    await prefs.setString(_carsKey, jsonEncode(payload));
  }

  Future<List<Gasto>> _loadPersistedGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gastosKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Gasto.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _savePersistedGastos(List<Gasto> gastos) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = gastos.map((gasto) => gasto.toMap()).toList();
    await prefs.setString(_gastosKey, jsonEncode(payload));
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
      final users = await _loadPersistedUsers();
      final nextId = users.isEmpty
          ? 1
          : users.map((user) => user.id ?? 0).reduce((a, b) => a > b ? a : b) +
                1;
      final user = User(
        id: nextId,
        name: name,
        email: normalizedEmail,
        password: password,
      );
      users.add(user);
      await _savePersistedUsers(users);
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
      final users = await _loadPersistedUsers();
      final filtered = users.where(
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
      final users = await _loadPersistedUsers();
      final filtered = users.where((user) => user.email == normalizedEmail);
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
      final users = await _loadPersistedUsers();
      final filtered = users.where((user) => user.id == id);
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
      final users = await _loadPersistedUsers();
      final index = users.indexWhere((user) => user.id == userId);
      if (index < 0) {
        throw Exception('Usuário não encontrado para atualização.');
      }

      final updatedUser = users[index].copy(
        name: name,
        email: normalizedEmail,
        password: password,
        photoPath: photoPath,
      );
      users[index] = updatedUser;
      await _savePersistedUsers(users);
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
    if (kIsWeb) {
      final cars = await _loadPersistedCars();
      final userId = _currentUserId ?? car.userId;
      final nextId = cars.isEmpty
          ? 1
          : cars
                    .map((existingCar) => existingCar.id ?? 0)
                    .reduce((a, b) => a > b ? a : b) +
                1;
      final newCar = car.copy(id: nextId, userId: userId);
      cars.add(newCar);
      await _savePersistedCars(cars);
      return nextId;
    }

    final db = await database;
    final userId = _currentUserId ?? car.userId;
    final data = car.toMap()..['userId'] = userId;
    return await db.insert('cars', data);
  }

  Future<List<Car>> getCars({int? userId}) async {
    if (kIsWeb) {
      final cars = await _loadPersistedCars();
      final currentUserId = userId ?? _currentUserId;
      if (currentUserId == null) {
        return [];
      }
      return cars.where((car) => car.userId == currentUserId).toList();
    }

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
    if (kIsWeb) {
      final cars = await _loadPersistedCars();
      final currentUserId = userId ?? _currentUserId;
      final matchingCars = cars.where((candidate) => candidate.id == id);
      if (matchingCars.isEmpty) {
        return null;
      }
      final car = matchingCars.first;
      if (currentUserId != null && car.userId != currentUserId) {
        return null;
      }
      return car;
    }

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
    if (kIsWeb) {
      final cars = await _loadPersistedCars();
      final index = cars.indexWhere((candidate) => candidate.id == car.id);
      if (index < 0) {
        return 0;
      }
      final updatedCar = car.userId == null && _currentUserId != null
          ? car.copy(userId: _currentUserId)
          : car;
      cars[index] = updatedCar;
      await _savePersistedCars(cars);
      return 1;
    }

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
    if (kIsWeb) {
      if (_currentUserId == null) {
        return 0;
      }
      final cars = await _loadPersistedCars();
      final initialLength = cars.length;
      cars.removeWhere((car) => car.id == id && car.userId == _currentUserId);
      await _savePersistedCars(cars);
      return initialLength == cars.length ? 0 : 1;
    }

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
    if (kIsWeb) {
      final gastos = await _loadPersistedGastos();
      final nextId = gastos.isEmpty
          ? 1
          : gastos
                    .map((existingGasto) => existingGasto.id ?? 0)
                    .reduce((a, b) => a > b ? a : b) +
                1;
      gastos.add(gasto.copy(id: nextId));
      await _savePersistedGastos(gastos);
      return nextId;
    }

    final db = await database;
    return await db.insert('gastos', gasto.toMap());
  }

  Future<List<Gasto>> getGastosByCarId(int carId) async {
    if (kIsWeb) {
      final gastos = await _loadPersistedGastos();
      return gastos.where((gasto) => gasto.carId == carId).toList();
    }

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
    if (kIsWeb) {
      final gastos = await _loadPersistedGastos();
      final matchingGastos = gastos.where((candidate) => candidate.id == id);
      if (matchingGastos.isEmpty) {
        return null;
      }
      return matchingGastos.first;
    }

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
    if (kIsWeb) {
      final gastos = await _loadPersistedGastos();
      final index = gastos.indexWhere((candidate) => candidate.id == gasto.id);
      if (index < 0) {
        return 0;
      }
      gastos[index] = gasto;
      await _savePersistedGastos(gastos);
      return 1;
    }

    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> deleteGasto(int id) async {
    if (kIsWeb) {
      final gastos = await _loadPersistedGastos();
      final initialLength = gastos.length;
      gastos.removeWhere((gasto) => gasto.id == id);
      await _savePersistedGastos(gastos);
      return initialLength == gastos.length ? 0 : 1;
    }

    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalGastosByCarId(int carId) async {
    if (kIsWeb) {
      final gastos = await _loadPersistedGastos();
      final total = gastos
          .where((gasto) => gasto.carId == carId)
          .fold<double>(0, (sum, gasto) => sum + gasto.valor);
      return total;
    }

    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM gastos WHERE carId = ?',
      [carId],
    );
    return result.first['total'] as double? ?? 0.0;
  }
}
