// Importa a biblioteca de internacionalização para formatação de moedas
import 'package:intl/intl.dart';

// Função que formata um valor numérico em moeda brasileira (Real)
String formatCurrency(double value) {
  // Cria um formatador de moeda com localização "pt_BR" (Português Brasil) e símbolo "R$"
  final f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  // Retorna o valor formatado como string (ex: "R$ 150,50")
  return f.format(value);
}

// Função que capitaliza a primeira letra de uma string
String capitalizeFirst(String? s) {
  // Retorna string vazia se o valor for null
  if (s == null) return '';
  // Remove espaços em branco do início e fim
  final t = s.trim();
  // Retorna string vazia se ficar vazia após trim
  if (t.isEmpty) return '';
  // Retorna a primeira letra em maiúscula seguida do resto da string
  return t[0].toUpperCase() + (t.length > 1 ? t.substring(1) : '');
}
