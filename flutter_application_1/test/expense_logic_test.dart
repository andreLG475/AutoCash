import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/gasto.dart';
import 'package:flutter_application_1/services/expense_logic.dart';

void main() {
  group('expense logic', () {
    test('calculates cost per km from initial and current mileage', () {
      final totalSpent = 240.0;
      final costPerKm = calculateCostPerKm(
        totalSpent: totalSpent,
        initialKm: 1000000,
        currentKm: 1200000,
      );

      expect(costPerKm, 0.0012);
    });

    test('calculates monthly spending by month and year', () {
      final gastos = [
        Gasto(
          carId: 1,
          descricao: 'Troca de óleo',
          valor: 120.0,
          data: '2026-06-10',
          quilometragem: 100500,
        ),
        Gasto(
          carId: 1,
          descricao: 'Pneus',
          valor: 300.0,
          data: '2025-12-01',
          quilometragem: 100600,
        ),
      ];

      final monthlyTotal = calculateMonthlyTotal(
        gastos: gastos,
        referenceDate: DateTime(2026, 6, 15),
      );

      expect(monthlyTotal, 120.0);
    });

    test('permits older dates with mileage below a newer expense', () {
      final gastos = [
        Gasto(
          carId: 1,
          descricao: 'Gasto recente',
          valor: 700.0,
          data: '2026-06-27',
          quilometragem: 10000,
        ),
      ];

      final result = validateMileageAgainstChronology(
        selectedDate: DateTime(2026, 6, 25),
        mileage: 9500,
        existingGastos: gastos,
        initialMileage: 5000,
      );

      expect(result, isNull);
    });

    test(
      'blocks a later date with mileage lower than an existing older expense',
      () {
        final gastos = [
          Gasto(
            carId: 1,
            descricao: 'Gasto antigo',
            valor: 300.0,
            data: '2026-06-25',
            quilometragem: 9500,
          ),
        ];

        final result = validateMileageAgainstChronology(
          selectedDate: DateTime(2026, 6, 27),
          mileage: 9000,
          existingGastos: gastos,
          initialMileage: 5000,
        );

        expect(result, isNotNull);
        expect(result, contains('quilometragem'));
      },
    );
  });
}
