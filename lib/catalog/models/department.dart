import 'package:flutter/foundation.dart';

import 'json_utils.dart';

/// Un departamento de Bolivia dentro del catálogo curado (solo lectura).
///
/// Inmutable: se carga una vez desde `assets/catalog/catalog.json`. La igualdad
/// se basa únicamente en [id] (su clave en el catálogo).
@immutable
class Department {
  const Department({
    required this.id,
    required this.name,
    this.description,
    this.emoji,
  });

  /// Identificador único, ej. `"la_paz"`.
  final String id;

  /// Nombre legible, ej. `"La Paz"`.
  final String name;

  /// Descripción breve opcional.
  final String? description;

  /// Emoji para la tarjeta, ej. `"🏔️"` (imágenes/íconos quedan para el futuro).
  final String? emoji;

  factory Department.fromJson(Map<String, dynamic> json) {
    final id = requireString(json, 'id', context: 'un departamento');
    final where = 'el departamento "$id"';
    return Department(
      id: id,
      name: requireString(json, 'name', context: where),
      description: optionalString(json, 'description', context: where),
      emoji: optionalString(json, 'emoji', context: where),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Department && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Department(id: $id, name: $name)';
}
