import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
import '../../core/services/image_storage_service.dart';
import '../../experience/experience_providers.dart';
import '../../experience/models/experience_progress.dart';
import '../../moments/moments_providers.dart';
import '../../shared/widgets/polaroid_photo.dart';
import '../../shared/widgets/progress_ring.dart';

/// Dashboard: saludo, progreso global y últimos recuerdos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      body: SafeArea(
        child: catalogAsync.when(
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
          data: (_) => const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(overallProgressProvider);
    final recent = ref.watch(recentMemoriesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        Text('Su viaje juntos', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Coleccionen experiencias por toda Bolivia ❤️',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
        ),
        const SizedBox(height: 28),
        Center(
          child: ProgressRing(
            fraction: stats.fraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${stats.completed}', style: theme.textTheme.displaySmall),
                Text(
                  'de ${stats.total}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
                Text(
                  'recuerdos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _ExploreCard(onTap: () => context.push('/departments')),
        const SizedBox(height: 14),
        _MomentsCard(onTap: () => context.push('/moments')),
        const SizedBox(height: 32),
        Text('Últimos recuerdos', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const _EmptyMemories()
        else
          _RecentStrip(memories: recent),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.explore_outlined, color: AppColors.terracotta),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explorar departamentos',
                        style: theme.textTheme.titleMedium),
                    Text(
                      'Las 9 regiones de Bolivia',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentsCard extends ConsumerWidget {
  const _MomentsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(momentsProgressProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.favorite_outline, color: AppColors.dustyRose),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nuestros momentos',
                        style: theme.textTheme.titleMedium),
                    Text(
                      'Primera cita, viajes, cumpleaños…',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              Text(
                '${stats.completed} / ${stats.total}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.dustyRose,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentStrip extends ConsumerWidget {
  const _RecentStrip({required this.memories});

  final List<ExperienceProgress> memories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final storage = ref.watch(imageStorageServiceProvider);

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: memories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final memory = memories[index];
          final title =
              catalog?.experienceById(memory.experienceId)?.title ?? '';
          final file = storage.resolveFile(
            memory.experienceId,
            memory.photoFileNames.first,
          );
          // Rotación alterna para el aire de scrapbook.
          final rotation = (index.isEven ? 1 : -1) * 0.03;

          return SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PolaroidPhoto(
                  file: file,
                  size: 120,
                  rotation: rotation,
                  onTap: () => context.push('/experiences/${memory.experienceId}'),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyMemories extends StatelessWidget {
  const _EmptyMemories();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.photo_camera_outlined, color: AppColors.inkSoft),
          const SizedBox(height: 10),
          Text(
            'Aún no hay recuerdos.\nCompleten su primera experiencia ❤️',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
