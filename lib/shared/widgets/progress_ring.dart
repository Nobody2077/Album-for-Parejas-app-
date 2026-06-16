import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Anillo de progreso con un [child] centrado (típicamente el conteo).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.fraction,
    required this.child,
    this.size = 170,
    this.strokeWidth = 13,
  });

  /// Progreso 0.0–1.0.
  final double fraction;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceDim,
              valueColor: const AlwaysStoppedAnimation(AppColors.terracotta),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(strokeWidth + 8),
            child: child,
          ),
        ],
      ),
    );
  }
}
