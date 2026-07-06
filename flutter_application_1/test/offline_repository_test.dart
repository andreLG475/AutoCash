import 'dart:io';

import 'package:flutter_application_1/data/offline_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('cria UUIDs e sincroniza pendências locais', () async {
    final dbPath = join(Directory.current.path, 'offline_autocash.db');
    if (File(dbPath).existsSync()) {
      await File(dbPath).delete();
    }

    final repository = OfflineRepository(dbPath: dbPath);
    await repository.resetDatabase();

    final user = await repository.createUser(
      nome: 'Ana',
      email: 'ana@email.com',
      token: 'token-123',
    );

    final car = await repository.createCar(
      usuarioId: user.id,
      nomeModelo: 'Onix',
      marca: 'Chevrolet',
      placa: 'ABC1234',
    );

    final carId = car.id;
    expect(carId, isNotNull);
    expect(carId.length, greaterThan(8));
    expect(car.sincronizado, 0);

    final gasto = await repository.createGasto(
      carroId: carId,
      tipoGasto: 'Manutenção',
      valor: 125.5,
      dataGasto: '2026-07-06',
      quilometragem: 155000,
      observacao: 'Troca de óleo',
    );

    expect(gasto.sincronizado, 0);

    final syncedCount = await repository.syncPendingChanges(
      sendToServer: ({required cars, required gastos}) async {
        return true;
      },
    );

    expect(syncedCount, 2);

    final gastoId = gasto.id;
    expect(gastoId, isNotNull);

    final syncedCar = await repository.getCarById(carId);
    final syncedGasto = await repository.getGastoById(gastoId);

    expect(syncedCar?.sincronizado, 1);
    expect(syncedGasto?.sincronizado, 1);
  });
}
