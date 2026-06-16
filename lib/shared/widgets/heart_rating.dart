import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Valoración en corazones (1–5).
///
/// Si [onChanged] es `null` es de **solo lectura** (muestra el rating);
/// si se provee, es **interactivo**: tocar un corazón fija ese valor, y tocar
/// el corazón actual vuelve a 0 (sin valoración).
class HeartRating extends StatelessWidget {
  const HeartRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
    this.max = 5,
  });

  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final int max;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        final position = index + 1;
        final filled = position <= rating;
        final icon = Icon(
          filled ? Icons.favorite : Icons.favorite_border,
          color: filled ? AppColors.heart : AppColors.heart.withValues(alpha: 0.35),
          size: size,
        );

        if (!_interactive) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: icon,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged!(position == rating ? 0 : position),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: icon,
          ),
        );
      }),
    );
  }
}
