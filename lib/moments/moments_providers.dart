import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/catalog_providers.dart';
import '../catalog/models/moment.dart';
import '../core/storage/hive_init.dart';
import '../experience/experience_providers.dart';
import 'data/hive_moments_repository.dart';
import 'data/moments_repository.dart';
import 'models/custom_moment.dart';

/// Orden fijo de las categorías en el timeline. Las desconocidas van al final.
const List<String> momentCategories = [
  'Primeras veces',
  'Celebraciones',
  'Aventuras y viajes',
  'Hitos de la relación',
  'Personalizados',
];

/// Categoría por defecto para un momento personalizado nuevo.
const String defaultCustomCategory = 'Personalizados';

/// Ítem unificado del timeline: representa un momento curado o uno
/// personalizado, con lo mínimo que la UI necesita para mostrarlo y enlazar su
/// recuerdo (por [id]).
@immutable
class MomentItem {
  const MomentItem({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.icon,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final String category;
  final String? description;
  final String? icon;
  final bool isCustom;

  factory MomentItem.fromMoment(Moment m) => MomentItem(
        id: m.id,
        title: m.title,
        category: m.category,
        description: m.description,
        icon: m.icon,
      );

  factory MomentItem.fromCustom(CustomMoment m) => MomentItem(
        id: m.id,
        title: m.title,
        category: m.category,
        isCustom: true,
      );
}

/// Un grupo del timeline: una categoría con sus ítems.
@immutable
class MomentGroup {
  const MomentGroup({required this.category, required this.items});

  final String category;
  final List<MomentItem> items;
}

/// Repositorio de momentos personalizados sobre el box ya abierto en `initHive()`.
final momentsRepositoryProvider = Provider<MomentsRepository>(
  (ref) => HiveMomentsRepository(customMomentsBox()),
);

/// Fuente de verdad reactiva de los momentos personalizados.
class CustomMomentsController extends Notifier<List<CustomMoment>> {
  @override
  List<CustomMoment> build() => ref.watch(momentsRepositoryProvider).getAll();

  Future<void> save(CustomMoment moment) async {
    await ref.read(momentsRepositoryProvider).save(moment);
    state = ref.read(momentsRepositoryProvider).getAll();
  }

  Future<void> delete(String id) async {
    await ref.read(momentsRepositoryProvider).delete(id);
    state = ref.read(momentsRepositoryProvider).getAll();
  }
}

final customMomentsControllerProvider =
    NotifierProvider<CustomMomentsController, List<CustomMoment>>(
  CustomMomentsController.new,
);

/// Momentos curados del catálogo (vacío mientras carga o si hubo error).
final curatedMomentsProvider = Provider<List<Moment>>((ref) {
  return ref.watch(catalogProvider).value?.moments ?? const [];
});

/// Todos los ítems de momentos (curados + personalizados), sin agrupar.
final momentItemsProvider = Provider<List<MomentItem>>((ref) {
  final curated =
      ref.watch(curatedMomentsProvider).map(MomentItem.fromMoment);
  final custom =
      ref.watch(customMomentsControllerProvider).map(MomentItem.fromCustom);
  return [...curated, ...custom];
});

/// Ítems agrupados por categoría, en el orden de [momentCategories]
/// (las categorías sin ítems se omiten; las desconocidas van al final).
final momentGroupsProvider = Provider<List<MomentGroup>>((ref) {
  final items = ref.watch(momentItemsProvider);

  final byCategory = <String, List<MomentItem>>{};
  for (final item in items) {
    byCategory.putIfAbsent(item.category, () => []).add(item);
  }

  final groups = <MomentGroup>[];
  for (final category in momentCategories) {
    final list = byCategory.remove(category);
    if (list != null && list.isNotEmpty) {
      groups.add(MomentGroup(category: category, items: list));
    }
  }
  // Categorías fuera del orden conocido (por si un personalizado trae otra).
  byCategory.forEach((category, list) {
    groups.add(MomentGroup(category: category, items: list));
  });
  return groups;
});

/// Progreso de los momentos: completados sobre el total (curados + personalizados).
final momentsProgressProvider = Provider<ProgressStats>((ref) {
  final items = ref.watch(momentItemsProvider);
  final progressById = ref.watch(progressControllerProvider);
  final completed = items
      .where((item) => progressById[item.id]?.completed ?? false)
      .length;
  return ProgressStats(completed: completed, total: items.length);
});
