import 'package:flutter/foundation.dart';
import '../models/car.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  final List<Car> _cars = [];

  DatabaseHelper._();

  Future<List<Car>> get database async => _cars;

  Future<int> insertCar(Car car) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final newCar = Car(
      id: id,
      marca: car.marca,
      modelo: car.modelo,
      ano: car.ano,
      km: car.km,
      image: car.image,
      gastos: car.gastos,
    );
    _cars.add(newCar);
    return id;
  }

  Future<List<Car>> getCars() async {
    return _cars;
  }

  Future<Car?> getCarById(int id) async {
    return _cars.cast<Car?>().firstWhere(
      (car) => car?.id == id,
      orElse: () => null,
    );
  }

  Future<int> updateCar(Car car) async {
    final index = _cars.indexWhere((c) => c.id == car.id);
    if (index != -1) {
      _cars[index] = car;
    }
    return car.id!;
  }

  Future<int> deleteCar(int id) async {
    _cars.removeWhere((car) => car.id == id);
    return id;
  }
}
