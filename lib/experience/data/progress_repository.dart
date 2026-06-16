import '../models/experience_progress.dart';

/// Contrato de persistencia del progreso del usuario.
///
/// La UI habla con providers, no con este repo directamente. Esta interfaz es
/// lo que permite cambiar la fuente de datos (Hive hoy, Firebase mañana, o un
/// fake en memoria en tests) sin tocar las pantallas.
abstract interface class ProgressRepository {
  /// Todo el progreso indexado por `experienceId`.
  Map<String, ExperienceProgress> getAllById();

  /// Progreso de una experiencia, o `null` si el usuario no la ha tocado.
  ExperienceProgress? getById(String experienceId);

  /// Crea o actualiza (upsert) el progreso. La implementación es la autoridad
  /// de los timestamps: conserva `createdAt` y refresca `updatedAt`.
  Future<ExperienceProgress> save(ExperienceProgress progress);

  /// Elimina el progreso de una experiencia (registro completo).
  Future<void> delete(String experienceId);
}
