import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
import '../../experience/experience_providers.dart';
import '../../shared/widgets/experience_row.dart';

/// Detalle de un departamento: lista de sus experiencias con estado de completado.
class DepartmentDetailScreen extends ConsumerWidget {
  const DepartmentDetailScreen({super.key, required this.departmentId});

  final String departmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final department = catalog?.departmentById(departmentId);
    final experiences = ref.watch(experiencesByDeptProvider(departmentId));
    final stats = ref.watch(departmentProgressProvider(departmentId));

    return Scaffold(
      appBar: AppBar(title: Text(department?.name ?? 'Departamento')),
      body: catalog == null
          ? const Center(child: CircularProgressIndicator())
          : experiences.isEmpty
          ? const _NoExperiences()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                if (department?.description != null) ...[
                  Text(
                    department!.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${stats.completed} de ${stats.total} completadas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                for (final experience in experiences) ...[
                  Builder(
                    builder: (context) {
                      final progress =
                          ref.watch(progressProvider(experience.id));
                      return ExperienceRow(
                        title: experience.title,
                        completed: progress?.completed ?? false,
                        rating: progress?.rating,
                        photoCount: progress?.photoFileNames.length ?? 0,
                        onTap: () =>
                            context.push('/experiences/${experience.id}'),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

/// Estado vacío: el departamento aún no tiene experiencias en el catálogo.
class _NoExperiences extends StatelessWidget {
  const _NoExperiences();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_outlined, color: AppColors.inkSoft),
            const SizedBox(height: 12),
            Text(
              'Aún no hay experiencias para este departamento.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
