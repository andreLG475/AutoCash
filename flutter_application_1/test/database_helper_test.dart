import 'dart:io';

import 'package:flutter_application_1/data/database_helper.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final dbPath = join(Directory.current.path, 'autocash.db');
    if (File(dbPath).existsSync()) {
      await File(dbPath).delete();
    }
  });

  test('cadastra, autentica e atualiza usuário no banco', () async {
    final createdUser = await DatabaseHelper.instance.registerUser(
      name: 'Usuário 1',
      email: 'teste@email.com',
      password: '123456',
    );

    expect(createdUser.id, isNotNull);

    final authenticatedUser = await DatabaseHelper.instance.authenticateUser(
      identifier: 'teste@email.com',
      password: '123456',
    );

    expect(authenticatedUser, isNotNull);
    expect(authenticatedUser!.email, 'teste@email.com');

    final updatedUser = await DatabaseHelper.instance.updateUserProfile(
      userId: createdUser.id!,
      name: 'Usuário Atualizado',
      email: 'novo@email.com',
      password: '654321',
    );

    expect(updatedUser.name, 'Usuário Atualizado');
    expect(updatedUser.email, 'novo@email.com');

    final reAuthenticatedUser = await DatabaseHelper.instance.authenticateUser(
      identifier: 'novo@email.com',
      password: '654321',
    );

    expect(reAuthenticatedUser, isNotNull);
    expect(reAuthenticatedUser!.name, 'Usuário Atualizado');
  });
}
