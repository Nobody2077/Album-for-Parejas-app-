import 'package:hive_ce/hive.dart';

part 'custom_moment.g.dart';

/// Definición de un momento **personalizado** creado por el usuario.
///
/// A diferencia de los momentos curados (que viven en el catálogo de solo
/// lectura), estos los crea la pareja, así que viven en Hive. El recuerdo en sí
/// (fecha/nota/fotos/corazones) sigue guardándose en `ExperienceProgress`,
/// indexado por este mismo [id]. Por convención los ids llevan prefijo `mc_`.
///
/// Registro de `typeId` de Hive (mantener único por tipo):
/// - 0 → `ExperienceProgress`
/// - 1 → [CustomMoment]
@HiveType(typeId: 1)
class CustomMoment {
  const CustomMoment({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
  });

  /// Identificador único, ej. `"mc_1718000000000"`.
  @HiveField(0)
  final String id;

  /// Título libre dado por el usuario.
  @HiveField(1)
  final String title;

  /// Categoría a la que pertenece en el timeline.
  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime createdAt;

  @override
  String toString() => 'CustomMoment(id: $id, title: $title)';
}
