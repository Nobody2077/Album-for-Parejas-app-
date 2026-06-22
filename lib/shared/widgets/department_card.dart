import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Tarjeta de un departamento para el grid: ilustración, nombre y progreso
/// (barra + "X / Y" + porcentaje). Las completadas se resaltan con borde dorado
/// e insignia.
///
/// Widget "tonto": recibe los datos ya calculados; el cálculo del progreso vive
/// en los providers de la pantalla. Pensado para un contexto de altura acotada
/// (grid); en tests, envolver en un `SizedBox`.
class DepartmentCard extends StatelessWidget {
  const DepartmentCard({
    super.key,
    required this.name,
    required this.completed,
    required this.total,
    this.illustration,
    this.emoji,
    this.onTap,
  });

  final String name;
  final int completed;
  final int total;

  /// Ruta del asset de la ilustración (ej. `assets/departments/la_paz.png`).
  /// Si es `null` o falla la carga, se usa [emoji] como respaldo.
  final String? illustration;
  final String? emoji;
  final VoidCallback? onTap;

  bool get _isComplete => total > 0 && completed == total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : completed / total;
    final percent = (fraction * 100).round();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: _isComplete
            ? const BorderSide(color: AppColors.gold, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _Illustration(
              illustration: illustration,
              emoji: emoji,
              showBadge: _isComplete,
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceDim,
                      valueColor: AlwaysStoppedAnimation(
                        _isComplete ? AppColors.gold : AppColors.terracotta,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completed / $total',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.inkSoft),
                      ),
                      Text(
                        '$percent%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isComplete
                              ? AppColors.gold
                              : AppColors.terracotta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banda superior de la tarjeta: ilustración del departamento (o emoji de
/// respaldo) con una insignia dorada si está completado.
class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.illustration,
    required this.emoji,
    required this.showBadge,
  });

  final String? illustration;
  final String? emoji;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppColors.surfaceDim,
      alignment: Alignment.center,
      child: Text(emoji ?? '📍', style: const TextStyle(fontSize: 32)),
    );

    final Widget base = illustration == null
        ? fallback
        : Image.asset(
            illustration!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => fallback,
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        base,
        if (showBadge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.verified, color: AppColors.gold, size: 20),
            ),
          ),
      ],
    );
  }
}
