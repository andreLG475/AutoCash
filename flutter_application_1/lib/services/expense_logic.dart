// Importa o modelo de dados de gasto
import '../models/gasto.dart';

// Função que valida se a quilometragem de um novo gasto está em ordem cronológica
// com os gastos existentes (a quilometragem não pode diminuir para datas anteriores)
String? validateMileageAgainstChronology({
  required DateTime selectedDate, // Data selecionada para o novo gasto
  required int mileage, // Quilometragem do novo gasto
  required List<Gasto> existingGastos, // Lista de gastos já registrados
  required int initialMileage, // Quilometragem inicial do carro
}) {
  // Cria uma cópia da lista e ordena os gastos por data
  final gastosOrdenados = [...existingGastos]
    ..sort((a, b) {
      // Tenta converter as datas de string para DateTime
      final dateA = DateTime.tryParse(a.data);
      final dateB = DateTime.tryParse(b.data);
      // Se alguma data falhar, usa comparação de string
      if (dateA == null || dateB == null) {
        return a.data.compareTo(b.data);
      }
      // Caso contrário, compara as datas normalmente
      return dateA.compareTo(dateB);
    });

  // Obtém a quilometragem mínima permitida (quilometragem inicial do carro)
  final minimumAllowedMileage = initialMileage;
  // Verifica se a nova quilometragem é menor que a inicial
  if (mileage < minimumAllowedMileage) {
    return 'A quilometragem deve ser igual ou maior que $minimumAllowedMileage';
  }

  // Itera sobre cada gasto existente para validar cronologia
  for (final gasto in gastosOrdenados) {
    // Tenta converter a data do gasto de string para DateTime
    final gastoDate = DateTime.tryParse(gasto.data);
    // Se não conseguir converter, pula para o próximo gasto
    if (gastoDate == null) {
      continue;
    }

    // Verifica se o gasto é de uma data anterior à data selecionada
    if (gastoDate.isBefore(selectedDate) && mileage < gasto.quilometragem) {
      // Retorna erro: a quilometragem não pode ser menor que a de um gasto anterior
      return 'A quilometragem deve ser igual ou maior que ${gasto.quilometragem} para datas anteriores a ${formatDateForDisplay(gastoDate)}';
    }

    // Verifica se o gasto é de uma data posterior à data selecionada
    if (gastoDate.isAfter(selectedDate) && mileage > gasto.quilometragem) {
      // Retorna erro: a quilometragem não pode ser maior que a de um gasto posterior
      return 'A quilometragem deve ser igual ou menor que ${gasto.quilometragem} para datas posteriores a ${formatDateForDisplay(gastoDate)}';
    }
  }

  // Se passou todas as validações, retorna null (sem erros)
  return null;
}

// Função que formata uma data para exibição no formato DD/MM/YYYY
String formatDateForDisplay(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

// Função que converte uma data armazenada (string ISO) para formato de exibição
String formatDateFromStorage(String? value) {
  // Se valor é null ou vazio, retorna string vazia
  if (value == null || value.isEmpty) {
    return '';
  }

  // Tenta converter a string para DateTime
  final parsedDate = DateTime.tryParse(value);
  // Se não conseguir converter, retorna o valor original
  if (parsedDate == null) {
    return value;
  }

  // Formata e retorna a data em formato DD/MM/YYYY
  return formatDateForDisplay(parsedDate);
}

// Função que calcula o custo por quilômetro de um carro
double calculateCostPerKm({
  required double totalSpent, // Total gasto com manutenção
  required int initialKm, // Quilometragem inicial
  required int currentKm, // Quilometragem atual
}) {
  // Calcula a distância percorrida
  final distance = currentKm - initialKm;
  // Se não houve distância, retorna 0.0
  if (distance <= 0) {
    return 0.0;
  }
  // Retorna o custo por quilômetro (gasto total / distância percorrida)
  return totalSpent / distance;
}

// Função que calcula o total de gastos de um mês específico
double calculateMonthlyTotal({
  required List<Gasto> gastos, // Lista de gastos
  required DateTime referenceDate, // Data de referência para o mês
}) {
  // Usa fold para somar todos os gastos do mesmo mês
  return gastos.fold<double>(0.0, (sum, gasto) {
    // Tenta converter a data do gasto
    final gastoDate = DateTime.tryParse(gasto.data);
    // Se não conseguir converter, retorna a soma sem adicionar nada
    if (gastoDate == null) {
      return sum;
    }

    // Verifica se o gasto é do mesmo mês e ano que a data de referência
    final sameMonth =
        gastoDate.year == referenceDate.year &&
        gastoDate.month == referenceDate.month;
    // Se for do mesmo mês, adiciona o valor à soma, caso contrário retorna a soma atual
    return sameMonth ? sum + gasto.valor : sum;
  });
}
