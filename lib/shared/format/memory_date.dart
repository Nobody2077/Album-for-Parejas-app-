/// Formatea una fecha de recuerdo en español: `17 de junio de 2026`.
///
/// Helper mínimo y puro para el MVP. La adopción formal de `intl` con locale
/// es_BO es la tarea 8.3 (pulido); cuando llegue, esta función se reemplaza.
String formatMemoryDate(DateTime date) {
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  return '${date.day} de ${months[date.month - 1]} de ${date.year}';
}
