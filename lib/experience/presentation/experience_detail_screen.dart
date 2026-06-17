import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
import '../../core/services/image_storage_service.dart';
import '../../shared/format/memory_date.dart';
import '../../shared/widgets/heart_rating.dart';
import '../../shared/widgets/polaroid_photo.dart';
import '../experience_providers.dart';
import '../models/experience_progress.dart';
import 'edit_memory_sheet.dart';

/// Detalle de una experiencia: título, descripción y, si está completada,
/// el recuerdo (fecha, corazones, nota y galería). Permite crear/editar.
class ExperienceDetailScreen extends ConsumerWidget {
  const ExperienceDetailScreen({super.key, required this.experienceId});

  final String experienceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final experience = catalog?.experienceById(experienceId);
    final progress = ref.watch(progressProvider(experienceId));
    final theme = Theme.of(context);

    if (experience == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: catalog == null
              ? const CircularProgressIndicator()
              : const Text('Experiencia no encontrada'),
        ),
      );
    }

    final isCompleted = progress?.completed ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(experience.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showEditMemorySheet(
          context,
          experienceId: experienceId,
          experienceTitle: experience.title,
        ),
        icon: Icon(isCompleted ? Icons.edit_outlined : Icons.favorite_border),
        label: Text(isCompleted ? 'Editar recuerdo' : 'Completar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        children: [
          if (experience.category != null)
            Text(
              experience.category!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.terracotta,
                letterSpacing: 1.2,
              ),
            ),
          const SizedBox(height: 6),
          Text(experience.title, style: theme.textTheme.headlineSmall),
          if (experience.description != null) ...[
            const SizedBox(height: 12),
            Text(
              experience.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSoft,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),
          if (isCompleted)
            _MemoryView(progress: progress!)
          else
            const _NotCompletedYet(),
        ],
      ),
    );
  }
}

/// Recuerdo completado: fecha, corazones, nota y galería de polaroids.
class _MemoryView extends ConsumerWidget {
  const _MemoryView({required this.progress});

  final ExperienceProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storage = ref.watch(imageStorageServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.terracotta, size: 20),
            const SizedBox(width: 8),
            Text('Recuerdo completado', style: theme.textTheme.titleMedium),
          ],
        ),
        if (progress.completedDate != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Text(
                formatMemoryDate(progress.completedDate!),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        if (progress.rating != null && progress.rating! > 0) ...[
          const SizedBox(height: 16),
          HeartRating(rating: progress.rating!, size: 26),
        ],
        if (progress.note != null && progress.note!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceDim),
            ),
            child: Text(
              progress.note!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
        if (progress.photoFileNames.isNotEmpty) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: progress.photoFileNames.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final file = storage.resolveFile(
                  progress.experienceId,
                  progress.photoFileNames[index],
                );
                final rotation = (index.isEven ? 1 : -1) * 0.03;
                return PolaroidPhoto(file: file, size: 140, rotation: rotation);
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Estado para una experiencia aún no completada: invitación a documentarla.
class _NotCompletedYet extends StatelessWidget {
  const _NotCompletedYet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, color: AppColors.dustyRose, size: 36),
          const SizedBox(height: 12),
          Text(
            'Aún no han vivido esta experiencia.\nCuando lo hagan, documéntenla aquí ❤️',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
