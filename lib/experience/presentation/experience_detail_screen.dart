import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../catalog/catalog_providers.dart';
import '../../shared/widgets/memory_view.dart';
import '../experience_providers.dart';
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
            MemoryView(progress: progress!)
          else
            const MemoryInvitation(
              message:
                  'Aún no han vivido esta experiencia.\nCuando lo hagan, documéntenla aquí ❤️',
            ),
        ],
      ),
    );
  }
}
