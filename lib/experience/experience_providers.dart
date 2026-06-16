import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/catalog_providers.dart';
import '../core/storage/hive_init.dart';
import 'data/hive_progress_repository.dart';
import 'data/progress_repository.dart';
import 'models/experience_progress.dart';

/// Estadística de progreso: completadas sobre total.
@immutable
class ProgressStats {
  const ProgressStats({required this.completed, required this.total});

  final int completed;
  final int total;

  /// Fracción 0.0–1.0 (0 si no hay experiencias).
  double get fraction => total == 0 ? 0 : completed / total;

  /// `true` si hay experiencias y todas están completadas.
  bool get isComplete => total > 0 && completed == total;

  @override
  bool operator ==(Object other) =>
      other is ProgressStats &&
      other.completed == completed &&
      other.total == total;

  @override
  int get hashCode => Object.hash(completed, total);

  @override
  String toString() => 'ProgressStats($completed/$total)';
}

/// Repositorio de progreso sobre el box de Hive ya abierto en `initHive()`.
/// En tests se sustituye con un repo respaldado por un box temporal.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => HiveProgressRepository(progressBox()),
);

/// Fuente de verdad reactiva del progreso, indexado por `experienceId`.
/// Carga el estado inicial del repositorio y lo mantiene sincronizado con Hive.
class ProgressController extends Notifier<Map<String, ExperienceProgress>> {
  @override
  Map<String, ExperienceProgress> build() =>
      ref.watch(progressRepositoryProvider).getAllById();

  /// Crea o actualiza el progreso de una experiencia.
  Future<void> save(ExperienceProgress progress) async {
    final saved = await ref.read(progressRepositoryProvider).save(progress);
    state = {...state, saved.experienceId: saved};
  }

  /// Elimina por completo el progreso de una experiencia.
  Future<void> delete(String experienceId) async {
    await ref.read(progressRepositoryProvider).delete(experienceId);
    state = {...state}..remove(experienceId);
  }
}

final progressControllerProvider =
    NotifierProvider<ProgressController, Map<String, ExperienceProgress>>(
  ProgressController.new,
);

/// Progreso de una experiencia (o `null` si no se ha tocado).
final progressProvider = Provider.family<ExperienceProgress?, String>(
  (ref, experienceId) => ref.watch(progressControllerProvider)[experienceId],
);

/// Progreso global: experiencias completadas sobre el total del catálogo.
final overallProgressProvider = Provider<ProgressStats>((ref) {
  final completed = ref
      .watch(progressControllerProvider)
      .values
      .where((p) => p.completed)
      .length;
  final total = ref.watch(catalogProvider).value?.experiences.length ?? 0;
  return ProgressStats(completed: completed, total: total);
});

/// Recuerdos recientes con foto, del más nuevo al más antiguo (máx. 8).
/// Alimenta la tira de "últimos recuerdos" de la Home.
final recentMemoriesProvider = Provider<List<ExperienceProgress>>((ref) {
  final withPhotos = ref
      .watch(progressControllerProvider)
      .values
      .where((p) => p.photoFileNames.isNotEmpty)
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return withPhotos.take(8).toList(growable: false);
});

/// Progreso de un departamento: completadas sobre total de ese departamento.
final departmentProgressProvider =
    Provider.family<ProgressStats, String>((ref, departmentId) {
  final experiences = ref.watch(experiencesByDeptProvider(departmentId));
  final progressById = ref.watch(progressControllerProvider);
  final completed = experiences
      .where((e) => progressById[e.id]?.completed ?? false)
      .length;
  return ProgressStats(completed: completed, total: experiences.length);
});
