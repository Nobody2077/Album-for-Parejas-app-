import '../models/custom_moment.dart';

/// Contrato de persistencia de los momentos **personalizados** del usuario.
///
/// Como con `ProgressRepository`, la UI habla con providers y no con este repo
/// directamente; la interfaz permite sustituir la fuente (Hive hoy, un fake en
/// tests) sin tocar las pantallas.
abstract interface class MomentsRepository {
  /// Todos los momentos personalizados, del más nuevo al más antiguo.
  List<CustomMoment> getAll();

  /// Crea o actualiza (upsert) un momento personalizado.
  Future<void> save(CustomMoment moment);

  /// Elimina un momento personalizado por su [id].
  Future<void> delete(String id);
}
