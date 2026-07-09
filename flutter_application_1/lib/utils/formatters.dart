import 'package:intl/intl.dart';

String formatCurrency(double value) {
  final f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return f.format(value);
}

String capitalizeFirst(String? s) {
  if (s == null) return '';
  final t = s.trim();
  if (t.isEmpty) return '';
  return t[0].toUpperCase() + (t.length > 1 ? t.substring(1) : '');
}
