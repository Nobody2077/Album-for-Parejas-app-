import 'package:hive_ce/hive.dart';

import '../models/experience_progress.dart';

/// Única pieza que conoce Hive. La UI habla con providers, no con este repo
/// directamente. Mañana un `FirebaseProgressRepository` podría reemplazarlo
/// sin tocar las pantallas.
class ProgressRepository {
  ProgressRepository(this._box);

  final Box<ExperienceProgress> _box;

  /// Todo el progreso indexado por `experienceId`.
  Map<String, ExperienceProgress> getAllById() => {
        for (final progress in _box.values) progress.experienceId: progress,
      };

  /// Progreso de una experiencia, o `null` si el usuario no la ha tocado.
  ExperienceProgress? getById(String experienceId) => _box.get(experienceId);

  /// Crea o actualiza (upsert) el progreso. El repositorio es la autoridad de
  /// los timestamps: conserva `createdAt` y refresca `updatedAt`.
  Future<ExperienceProgress> save(ExperienceProgress progress) async {
    final existing = _box.get(progress.experienceId);
    final toSave = progress.copyWith(
      createdAt: existing?.createdAt ?? progress.createdAt,
      updatedAt: DateTime.now(),
    );
    await _box.put(toSave.experienceId, toSave);
    return toSave;
  }

  /// Elimina el progreso de una experiencia (registro completo).
  Future<void> delete(String experienceId) => _box.delete(experienceId);
}
