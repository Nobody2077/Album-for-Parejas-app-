import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/image_storage_service.dart';
import '../../experience/models/experience_progress.dart';
import '../format/memory_date.dart';
import 'heart_rating.dart';
import 'polaroid_photo.dart';

/// Vista de un recuerdo ya completado: fecha, corazones, nota y galería de
/// polaroids. Compartida por el detalle de experiencia y el de momento.
class MemoryView extends ConsumerWidget {
  const MemoryView({super.key, required this.progress});

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

/// Invitación mostrada cuando aún no se documentó el recuerdo.
class MemoryInvitation extends StatelessWidget {
  const MemoryInvitation({super.key, required this.message});

  final String message;

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
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
