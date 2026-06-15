import 'package:flutter/material.dart';

/// Paleta de "Our Journey": cálida, romántica y elegante.
///
/// Fondos crema/marfil, acentos en terracota y rosa polvo, detalles en dorado
/// suave. Nada de colores chillones ni infantiles (ver `docs/02-design.md` §9).
abstract final class AppColors {
  // Fondos
  /// Fondo principal de la app (marfil cálido).
  static const Color cream = Color(0xFFFAF4EC);

  /// Superficies elevadas: tarjetas, hojas, diálogos.
  static const Color surface = Color(0xFFFFFDF9);

  /// Superficie hundida / divisores y bordes suaves.
  static const Color surfaceDim = Color(0xFFF1E7DA);

  // Acentos
  /// Color primario: terracota.
  static const Color terracotta = Color(0xFFBC6B4C);

  /// Variante oscura de la terracota (estados presionados, contornos).
  static const Color terracottaDark = Color(0xFF9A5238);

  /// Color secundario: rosa polvo.
  static const Color dustyRose = Color(0xFFD7A9A1);

  /// Detalles dorados suaves.
  static const Color gold = Color(0xFFC9A24B);

  // Texto / tinta
  /// Texto principal (marrón cálido casi negro).
  static const Color ink = Color(0xFF3D2C26);

  /// Texto secundario / apagado.
  static const Color inkSoft = Color(0xFF7A675F);

  // Semánticos
  /// Corazones de la valoración (1–5).
  static const Color heart = Color(0xFFC75D54);

  /// Errores / acciones destructivas.
  static const Color error = Color(0xFFB3261E);
}
