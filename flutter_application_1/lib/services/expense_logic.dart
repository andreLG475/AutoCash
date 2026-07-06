import '../models/gasto.dart';

String? validateMileageAgainstChronology({
  required DateTime selectedDate,
  required int mileage,
  required List<Gasto> existingGastos,
  required int initialMileage,
}) {
  final gastosOrdenados = [...existingGastos]
    ..sort((a, b) {
      final dateA = DateTime.tryParse(a.data);
      final dateB = DateTime.tryParse(b.data);
      if (dateA == null || dateB == null) {
        return a.data.compareTo(b.data);
      }
      return dateA.compareTo(dateB);
    });

  final minimumAllowedMileage = initialMileage;
  if (mileage < minimumAllowedMileage) {
    return 'A quilometragem deve ser igual ou maior que $minimumAllowedMileage';
  }

  for (final gasto in gastosOrdenados) {
    final gastoDate = DateTime.tryParse(gasto.data);
    if (gastoDate == null) {
      continue;
    }

    if (gastoDate.isBefore(selectedDate) && mileage < gasto.quilometragem) {
      return 'A quilometragem deve ser igual ou maior que ${gasto.quilometragem} para datas anteriores a ${formatDateForDisplay(gastoDate)}';
    }

    if (gastoDate.isAfter(selectedDate) && mileage > gasto.quilometragem) {
      return 'A quilometragem deve ser igual ou menor que ${gasto.quilometragem} para datas posteriores a ${formatDateForDisplay(gastoDate)}';
    }
  }

  return null;
}

String formatDateForDisplay(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatDateFromStorage(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(value);
  if (parsedDate == null) {
    return value;
  }

  return formatDateForDisplay(parsedDate);
}

double calculateCostPerKm({
  required double totalSpent,
  required int initialKm,
  required int currentKm,
}) {
  final distance = currentKm - initialKm;
  if (distance <= 0) {
    return 0.0;
  }
  return totalSpent / distance;
}

double calculateMonthlyTotal({
  required List<Gasto> gastos,
  required DateTime referenceDate,
}) {
  return gastos.fold<double>(0.0, (sum, gasto) {
    final gastoDate = DateTime.tryParse(gasto.data);
    if (gastoDate == null) {
      return sum;
    }

    final sameMonth =
        gastoDate.year == referenceDate.year &&
        gastoDate.month == referenceDate.month;
    return sameMonth ? sum + gasto.valor : sum;
  });
}
