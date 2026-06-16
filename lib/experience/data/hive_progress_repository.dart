import 'package:hive_ce/hive.dart';

import '../models/experience_progress.dart';
import 'progress_repository.dart';

/// Implementación de [ProgressRepository] sobre un box de Hive.
class HiveProgressRepository implements ProgressRepository {
  HiveProgressRepository(this._box);

  final Box<ExperienceProgress> _box;

  @override
  Map<String, ExperienceProgress> getAllById() => {
        for (final progress in _box.values) progress.experienceId: progress,
      };

  @override
  ExperienceProgress? getById(String experienceId) => _box.get(experienceId);

  @override
  Future<ExperienceProgress> save(ExperienceProgress progress) async {
    final existing = _box.get(progress.experienceId);
    final toSave = progress.copyWith(
      createdAt: existing?.createdAt ?? progress.createdAt,
      updatedAt: DateTime.now(),
    );
    await _box.put(toSave.experienceId, toSave);
    return toSave;
  }

  @override
  Future<void> delete(String experienceId) => _box.delete(experienceId);
}
