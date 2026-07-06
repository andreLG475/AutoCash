import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/offline_models.dart';

class OfflineRepository {
  OfflineRepository({String? dbPath}) : _dbPath = dbPath;

  final String? _dbPath;
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path =
        _dbPath ?? join(await getDatabasesPath(), 'autocash_offline.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        token TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE carros(
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        nome_modelo TEXT NOT NULL,
        marca TEXT NOT NULL,
        placa TEXT NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0,
        atualizado_em TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos(
        id TEXT PRIMARY KEY,
        carro_id TEXT NOT NULL,
        tipo_gasto TEXT NOT NULL,
        valor REAL NOT NULL,
        data_gasto TEXT NOT NULL,
        quilometragem INTEGER NOT NULL,
        observacao TEXT NOT NULL DEFAULT '',
        sincronizado INTEGER NOT NULL DEFAULT 0,
        atualizado_em TEXT NOT NULL,
        FOREIGN KEY (carro_id) REFERENCES carros (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    final path =
        _dbPath ?? join(await getDatabasesPath(), 'autocash_offline.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }

  String _newId() => const Uuid().v4();

  String _timestamp() => DateTime.now().toUtc().toIso8601String();

  Future<UsuarioLocal> createUser({
    required String nome,
    required String email,
    required String token,
  }) async {
    final db = await database;
    final user = UsuarioLocal(
      id: _newId(),
      nome: nome,
      email: email,
      token: token,
    );

    await db.insert('usuarios', user.toMap());
    return user;
  }

  Future<UsuarioLocal?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (rows.isEmpty) {
      return null;
    }

    return UsuarioLocal.fromMap(rows.first);
  }

  Future<CarroLocal> createCar({
    required String usuarioId,
    required String nomeModelo,
    required String marca,
    required String placa,
  }) async {
    final db = await database;
    final now = _timestamp();
    final car = CarroLocal(
      id: _newId(),
      usuarioId: usuarioId,
      nomeModelo: nomeModelo,
      marca: marca,
      placa: placa,
      sincronizado: 0,
      atualizadoEm: now,
    );

    await db.insert('carros', car.toMap());
    return car;
  }

  Future<List<CarroLocal>> getCarsByUser(String usuarioId) async {
    final db = await database;
    final rows = await db.query(
      'carros',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'atualizado_em DESC',
    );

    return rows.map(CarroLocal.fromMap).toList();
  }

  Future<CarroLocal?> getCarById(String id) async {
    final db = await database;
    final rows = await db.query('carros', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) {
      return null;
    }

    return CarroLocal.fromMap(rows.first);
  }

  Future<int> updateCar(CarroLocal car) async {
    final db = await database;
    return db.update(
      'carros',
      car.toMap(),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  Future<GastoLocal> createGasto({
    required String carroId,
    required String tipoGasto,
    required double valor,
    required String dataGasto,
    required int quilometragem,
    required String observacao,
  }) async {
    final db = await database;
    final now = _timestamp();
    final gasto = GastoLocal(
      id: _newId(),
      carroId: carroId,
      tipoGasto: tipoGasto,
      valor: valor,
      dataGasto: dataGasto,
      quilometragem: quilometragem,
      observacao: observacao,
      sincronizado: 0,
      atualizadoEm: now,
    );

    await db.insert('gastos', gasto.toMap());
    return gasto;
  }

  Future<List<GastoLocal>> getGastosByCar(String carroId) async {
    final db = await database;
    final rows = await db.query(
      'gastos',
      where: 'carro_id = ?',
      whereArgs: [carroId],
      orderBy: 'data_gasto DESC',
    );

    return rows.map(GastoLocal.fromMap).toList();
  }

  Future<GastoLocal?> getGastoById(String id) async {
    final db = await database;
    final rows = await db.query('gastos', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) {
      return null;
    }

    return GastoLocal.fromMap(rows.first);
  }

  Future<int> updateGasto(GastoLocal gasto) async {
    final db = await database;
    return db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> syncPendingChanges({
    required Future<bool> Function({
      required List<CarroLocal> cars,
      required List<GastoLocal> gastos,
    })
    sendToServer,
  }) async {
    final db = await database;

    final pendingCars = await db.query(
      'carros',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    final pendingGastos = await db.query(
      'gastos',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );

    final cars = pendingCars.map(CarroLocal.fromMap).toList();
    final gastos = pendingGastos.map(GastoLocal.fromMap).toList();

    if (cars.isEmpty && gastos.isEmpty) {
      return 0;
    }

    final success = await sendToServer(cars: cars, gastos: gastos);
    if (!success) {
      return 0;
    }

    final now = _timestamp();
    await db.update(
      'carros',
      {'sincronizado': 1, 'atualizado_em': now},
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    await db.update(
      'gastos',
      {'sincronizado': 1, 'atualizado_em': now},
      where: 'sincronizado = ?',
      whereArgs: [0],
    );

    return cars.length + gastos.length;
  }
}
