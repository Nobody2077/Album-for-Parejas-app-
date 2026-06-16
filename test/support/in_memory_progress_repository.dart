import 'package:album_app/experience/data/progress_repository.dart';
import 'package:album_app/experience/models/experience_progress.dart';

/// Implementación en memoria de [ProgressRepository] para widget tests.
///
/// Evita Hive, que es incompatible con el `FakeAsync` de `testWidgets`
/// (usa timers/async reales que el reloj falso no puede drenar).
class InMemoryProgressRepository implements ProgressRepository {
  InMemoryProgressRepository([Iterable<ExperienceProgress> initial = const []]) {
    for (final progress in initial) {
      _store[progress.experienceId] = progress;
    }
  }

  final Map<String, ExperienceProgress> _store = {};

  @override
  Map<String, ExperienceProgress> getAllById() => Map.of(_store);

  @override
  ExperienceProgress? getById(String experienceId) => _store[experienceId];

  @override
  Future<ExperienceProgress> save(ExperienceProgress progress) async {
    final existing = _store[progress.experienceId];
    final toSave = progress.copyWith(
      createdAt: existing?.createdAt ?? progress.createdAt,
      updatedAt: DateTime.now(),
    );
    _store[toSave.experienceId] = toSave;
    return toSave;
  }

  @override
  Future<void> delete(String experienceId) async {
    _store.remove(experienceId);
  }
}
