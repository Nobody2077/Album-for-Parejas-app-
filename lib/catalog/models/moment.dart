import 'package:flutter/foundation.dart';

import 'json_utils.dart';

/// Un "momento" curado: un hito típico de pareja (primera cita, cumpleaños,
/// primer viaje…) que no está atado a la geografía de un departamento.
///
/// Inmutable: vive en el catálogo (solo lectura) y se enlaza con el progreso
/// del usuario por [id]. Por convención, los ids de momentos curados llevan el
/// prefijo `m_` para no colisionar con los de experiencias en el mismo box de
/// progreso. La igualdad se basa únicamente en [id].
@immutable
class Moment {
  const Moment({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.icon,
  });

  /// Identificador único, ej. `"m_primera_cita"`.
  final String id;

  /// Título, ej. `"Primera cita"`.
  final String title;

  /// Categoría para agrupar en el timeline, ej. `"Primeras veces"`.
  final String category;

  /// Detalle / inspiración opcional.
  final String? description;

  /// Nombre de un ícono opcional (clave lógica, ej. `"favorite"`).
  final String? icon;

  factory Moment.fromJson(Map<String, dynamic> json) {
    final id = requireString(json, 'id', context: 'un momento');
    final where = 'el momento "$id"';
    return Moment(
      id: id,
      title: requireString(json, 'title', context: where),
      category: requireString(json, 'category', context: where),
      description: optionalString(json, 'description', context: where),
      icon: optionalString(json, 'icon', context: where),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Moment && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Moment(id: $id, title: $title)';
}
