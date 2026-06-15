import 'package:flutter/foundation.dart';

import 'json_utils.dart';

/// Una experiencia/cita curada que una pareja puede completar.
///
/// Inmutable: vive en el catálogo (solo lectura) y se enlaza con el progreso
/// del usuario por [id]. La igualdad se basa únicamente en [id].
@immutable
class Experience {
  const Experience({
    required this.id,
    required this.departmentId,
    required this.title,
    this.description,
    this.category,
  });

  /// Identificador único en toda la app, ej. `"lp_telef"`.
  final String id;

  /// A qué [Department] pertenece (enlaza con `Department.id`).
  final String departmentId;

  /// Título, ej. `"Subir al Teleférico juntos"`.
  final String title;

  /// Detalle / inspiración opcional.
  final String? description;

  /// Categoría opcional (comida, paisaje, aventura…) para filtrar a futuro.
  final String? category;

  factory Experience.fromJson(Map<String, dynamic> json) {
    final id = requireString(json, 'id', context: 'una experiencia');
    final where = 'la experiencia "$id"';
    return Experience(
      id: id,
      departmentId: requireString(json, 'departmentId', context: where),
      title: requireString(json, 'title', context: where),
      description: optionalString(json, 'description', context: where),
      category: optionalString(json, 'category', context: where),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Experience && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Experience(id: $id, title: $title)';
}
