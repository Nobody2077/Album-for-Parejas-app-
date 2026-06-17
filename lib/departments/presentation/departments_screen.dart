import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentsProvider);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.92,
      ),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final department = departments[index];
        final stats = ref.watch(departmentProgressProvider(department.id));

        return DepartmentCard(
          name: department.name,
          emoji: department.emoji,
          completed: stats.completed,
          total: stats.total,
          onTap: () => context.push('/departments/${department.id}'),
        );
      },
    );
  }
}
