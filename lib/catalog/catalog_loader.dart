import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models/catalog.dart';

/// Carga el catálogo curado desde los assets de la app.
///
/// Es la única pieza que conoce de dónde sale el JSON; el resto trabaja con
/// el [Catalog] ya parseado.
class CatalogLoader {
  const CatalogLoader();

  /// Ruta del catálogo dentro de los assets (declarada en `pubspec.yaml`).
  static const String assetPath = 'assets/catalog/catalog.json';

  /// Lee y parsea `catalog.json`. Propaga [FormatException] si el contenido
  /// es inválido (ver parseo estricto de los modelos).
  Future<Catalog> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Catalog.fromJson(json);
  }
}
