import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Foto enmarcada estilo polaroid: borde blanco (más grueso abajo), sombra
/// suave y una ligera rotación para el aire de scrapbook.
class PolaroidPhoto extends StatelessWidget {
  const PolaroidPhoto({
    super.key,
    required this.file,
    this.size = 130,
    this.rotation = 0,
    this.onTap,
    this.onDelete,
  });

  final File file;
  final double size;

  /// Rotación en radianes (pequeña, ej. ±0.04).
  final double rotation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final photo = Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            width: size,
            height: size,
            color: AppColors.surfaceDim,
            child: const Icon(Icons.broken_image_outlined, color: AppColors.inkSoft),
          ),
        ),
      ),
    );

    Widget content = Transform.rotate(angle: rotation, child: photo);

    if (onDelete != null) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.terracotta,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
