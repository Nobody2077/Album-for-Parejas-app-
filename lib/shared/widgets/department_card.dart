import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Tarjeta de un departamento para el grid: emoji, nombre y progreso (X/Y).
///
/// Widget "tonto": recibe los datos ya calculados; el cálculo del progreso vive
/// en los providers de la pantalla.
class DepartmentCard extends StatelessWidget {
  const DepartmentCard({
    super.key,
    required this.name,
    required this.completed,
    required this.total,
    this.emoji,
    this.onTap,
  });

  final String name;
  final int completed;
  final int total;
  final String? emoji;
  final VoidCallback? onTap;

  bool get _isComplete => total > 0 && completed == total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : completed / total;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji ?? '📍', style: const TextStyle(fontSize: 30)),
                  if (_isComplete)
                    const Icon(Icons.verified, color: AppColors.gold, size: 22),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceDim,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.terracotta),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$completed / $total',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
