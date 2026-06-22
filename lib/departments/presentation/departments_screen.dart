import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
import '../../catalog/models/department.dart';
import '../../experience/experience_providers.dart';
import '../../shared/widgets/department_card.dart';

/// Grid de los departamentos de Bolivia con su progreso (X/Y).
class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Departamentos')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No pudimos cargar el catálogo.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          ),
        ),
        data: (_) => const _DepartmentsGrid(),
      ),
    );
  }
}

class _DepartmentsGrid extends ConsumerWidget {
  const _DepartmentsGrid();

  /// Orden de aparición: en progreso primero, sin empezar después y
  /// completados al final (a más bajo, más arriba).
  static int _rank(ProgressStats s) {
    if (s.isComplete) return 2;
    if (s.completed > 0) return 0;
    return 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentsProvider);

    // Empareja cada departamento con su progreso y ordena de forma estable
    // (conserva el orden del catálogo dentro de cada grupo).
    final items = [
      for (var i = 0; i < departments.length; i++)
        (
          dept: departments[i],
          stats: ref.watch(departmentProgressProvider(departments[i].id)),
          index: i,
        ),
    ]..sort((a, b) {
        final byRank = _rank(a.stats).compareTo(_rank(b.stats));
        return byRank != 0 ? byRank : a.index.compareTo(b.index);
      });

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.80,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final Department department = items[index].dept;
        final stats = items[index].stats;

        return DepartmentCard(
          name: department.name,
          emoji: department.emoji,
          illustration: 'assets/departments/${department.id}.png',
          completed: stats.completed,
          total: stats.total,
          onTap: () => context.push('/departments/${department.id}'),
        );
      },
    );
  }
}
