import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Locale de formato. Bolivia usa el mismo formato de fecha larga que el
/// español genérico ("17 de junio de 2026"), así que 'es' cubre es_BO.
const _locale = 'es';

bool _ready = false;

/// Registra los símbolos de fecha en español. Idempotente y síncrono:
/// `date_symbol_data_local` popula los datos durante la llamada (el Future que
/// devuelve ya viene completo), por lo que un `DateFormat('…', 'es')` inmediato
/// funciona sin necesidad de `await`.
void _ensureReady() {
  if (_ready) return;
  initializeDateFormatting(_locale);
  _ready = true;
}

/// Formatea una fecha de recuerdo en español: `17 de junio de 2026`.
String formatMemoryDate(DateTime date) {
  _ensureReady();
  return DateFormat("d 'de' MMMM 'de' y", _locale).format(date);
}
