// Utilidades de parseo estricto para el catálogo curado.
//
// El `catalog.json` lo escribimos a mano, así que un error temprano y claro
// ayuda a detectar typos o campos faltantes durante el desarrollo.

/// Lee un campo `String` **obligatorio** de un mapa JSON.
///
/// Lanza [FormatException] con un mensaje legible si el campo falta, está vacío
/// o no es un texto. [context] describe dónde ocurrió (ej. `el departamento "la_paz"`).
String requireString(Map<String, dynamic> json, String key, {String? context}) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    final where = context != null ? ' en $context' : '';
    throw FormatException(
      'Catálogo inválido$where: falta el campo obligatorio "$key" '
      '(o no es un texto válido).',
    );
  }
  return value;
}

/// Lee un campo `String` **opcional**.
///
/// Devuelve `null` si el campo no está presente o es `null`. Lanza
/// [FormatException] si está presente pero no es un texto.
String? optionalString(Map<String, dynamic> json, String key, {String? context}) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    final where = context != null ? ' en $context' : '';
    throw FormatException(
      'Catálogo inválido$where: el campo "$key" debe ser un texto.',
    );
  }
  return value;
}
