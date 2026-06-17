import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'heart_rating.dart';

/// Fila de una experiencia dentro del detalle de un departamento.
///
/// Muestra el título y, si está completada, una marca, sus corazones y un
/// indicador de fotos. Widget "tonto": recibe los datos ya resueltos.
class ExperienceRow extends StatelessWidget {
  const ExperienceRow({
    super.key,
    required this.title,
    required this.completed,
    this.rating,
    this.photoCount = 0,
    this.onTap,
  });

  final String title;
  final bool completed;
  final int? rating;
  final int photoCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _StatusDot(completed: completed),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (completed) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (rating != null && rating! > 0)
                            HeartRating(rating: rating!, size: 15),
                          if (photoCount > 0) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.photo_outlined,
                                size: 15, color: AppColors.inkSoft),
                            const SizedBox(width: 3),
                            Text(
                              '$photoCount',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: AppColors.inkSoft),
                            ),
                          ],
                        ],
                      ),
                    ],
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

/// Punto de estado: relleno (terracota + check) si está completada, contorno si no.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? AppColors.terracotta : Colors.transparent,
        border: Border.all(
          color: completed ? AppColors.terracotta : AppColors.surfaceDim,
          width: 2,
        ),
      ),
      child: completed
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );
  }
}
