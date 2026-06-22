import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
import '../../core/services/image_storage_service.dart';
import '../../experience/experience_providers.dart';
import '../../experience/models/experience_progress.dart';
import '../../shared/widgets/heart_rating.dart';
import '../moments_providers.dart';
import 'add_custom_moment_sheet.dart';

/// Timeline de "Nuestros momentos": hitos de pareja agrupados por categoría,
/// con su contador propio. Cada fila enlaza al detalle del momento.
class MomentsScreen extends ConsumerWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);
    final stats = ref.watch(momentsProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuestros momentos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${stats.completed} / ${stats.total}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddCustomMomentSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar momento'),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No pudimos cargar los momentos.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          ),
        ),
        data: (_) => const _Timeline(),
      ),
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(momentGroupsProvider);
    final theme = Theme.of(context);

    if (groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aún no hay momentos.\nAgreguen el primero ❤️',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSoft),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 4),
            child: Text(
              group.category.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.terracotta,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (var i = 0; i < group.items.length; i++)
            _MomentRow(
              item: group.items[i],
              isFirst: i == 0,
              isLast: i == group.items.length - 1,
            ),
        ],
      ],
    );
  }
}

/// Una fila del timeline: conector (línea + punto) + contenido del momento.
class _MomentRow extends ConsumerWidget {
  const _MomentRow({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  final MomentItem item;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider(item.id));
    final completed = progress?.completed ?? false;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Connector(isFirst: isFirst, isLast: isLast, completed: completed),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/moments/${item.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Content(
                            item: item,
                            progress: progress,
                            completed: completed,
                          ),
                        ),
                        if (completed && progress!.photoFileNames.isNotEmpty)
                          _Thumb(progress: progress),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.item,
    required this.progress,
    required this.completed,
  });

  final MomentItem item;
  final ExperienceProgress? progress;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (completed)
          Row(
            children: [
              if (progress?.completedDate != null) ...[
                Text(
                  _shortDate(progress!.completedDate!),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(width: 8),
              ],
              if ((progress?.rating ?? 0) > 0)
                HeartRating(rating: progress!.rating!, size: 14),
            ],
          )
        else
          Text(
            'Toca para documentarlo',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.inkSoft),
          ),
      ],
    );
  }

  static String _shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Thumb extends ConsumerWidget {
  const _Thumb({required this.progress});

  final ExperienceProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(imageStorageServiceProvider);
    final file = storage.resolveFile(
      progress.experienceId,
      progress.photoFileNames.first,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          file,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            width: 48,
            height: 48,
            color: AppColors.surfaceDim,
            child: const Icon(Icons.broken_image_outlined,
                size: 18, color: AppColors.inkSoft),
          ),
        ),
      ),
    );
  }
}

/// Conector visual del timeline: línea vertical continua con un punto centrado
/// (relleno si está completado, hueco si no).
class _Connector extends StatelessWidget {
  const _Connector({
    required this.isFirst,
    required this.isLast,
    required this.completed,
  });

  final bool isFirst;
  final bool isLast;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    const lineColor = AppColors.surfaceDim;
    return SizedBox(
      width: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Línea (se recorta arriba en el primero y abajo en el último).
          Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : lineColor,
                ),
              ),
            ],
          ),
          // Punto.
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.terracotta : AppColors.surface,
              border: Border.all(
                color: completed ? AppColors.terracotta : AppColors.dustyRose,
                width: 2,
              ),
            ),
            child: completed
                ? const Icon(Icons.check, size: 9, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
