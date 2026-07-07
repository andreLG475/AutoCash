import 'package:flutter_application_1/data/database_helper.dart';
import 'package:flutter_application_1/models/car.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseHelper.instance.resetDatabase();
  });

  test('persiste o usuário atual entre execuções', () async {
    await DatabaseHelper.instance.setCurrentUserId(42);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('autocash_current_user_id'), 42);
  });

  test('restaura o usuário atual ao reinicializar a sessão', () async {
    await DatabaseHelper.instance.setCurrentUserId(77);
    await DatabaseHelper.instance.initialize();

    expect(DatabaseHelper.instance.currentUserId, 77);
  });

  test('cadastra, autentica e atualiza usuário no banco', () async {
    final createdUser = await DatabaseHelper.instance.registerUser(
      name: 'Usuário 1',
      email: 'teste1@email.com',
      password: '123456',
    );

    expect(createdUser.id, isNotNull);

    final authenticatedUser = await DatabaseHelper.instance.authenticateUser(
      identifier: 'teste1@email.com',
      password: '123456',
    );

    expect(authenticatedUser, isNotNull);
    expect(authenticatedUser!.email, 'teste1@email.com');

    final updatedUser = await DatabaseHelper.instance.updateUserProfile(
      userId: createdUser.id!,
      name: 'Usuário Atualizado',
      email: 'novo1@email.com',
      password: '654321',
    );

    expect(updatedUser.name, 'Usuário Atualizado');
    expect(updatedUser.email, 'novo1@email.com');

    final reAuthenticatedUser = await DatabaseHelper.instance.authenticateUser(
      identifier: 'novo1@email.com',
      password: '654321',
    );

    expect(reAuthenticatedUser, isNotNull);
    expect(reAuthenticatedUser!.name, 'Usuário Atualizado');
  });

  test('veículos ficam isolados por conta logada', () async {
    final primeiraConta = await DatabaseHelper.instance.registerUser(
      name: 'Conta 1',
      email: 'conta01@email.com',
      password: '123456',
    );
    final segundaConta = await DatabaseHelper.instance.registerUser(
      name: 'Conta 2',
      email: 'conta02@email.com',
      password: '123456',
    );

    await DatabaseHelper.instance.setCurrentUserId(primeiraConta.id);
    await DatabaseHelper.instance.insertCar(
      Car(
        marca: 'Chevrolet',
        modelo: 'Onix',
        ano: 2023,
        km: 1000,
        kmInicial: 1000,
        image: '',
        gastos: 0.0,
      ),
    );

    await DatabaseHelper.instance.setCurrentUserId(segundaConta.id);
    final carrosDaConta2 = await DatabaseHelper.instance.getCars();

    expect(carrosDaConta2, isEmpty);
  });
}
