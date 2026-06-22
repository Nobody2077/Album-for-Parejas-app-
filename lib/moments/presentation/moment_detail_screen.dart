import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/image_storage_service.dart';
import '../../experience/experience_providers.dart';
import '../../experience/presentation/edit_memory_sheet.dart';
import '../../shared/dialogs/confirm_dialog.dart';
import '../../shared/widgets/memory_view.dart';
import '../moments_providers.dart';

/// Detalle de un momento (curado o personalizado): título, descripción y, si
/// está completado, el recuerdo. Reutiliza la hoja de edición y la vista de
/// recuerdo compartidas. Los personalizados se pueden borrar.
class MomentDetailScreen extends ConsumerWidget {
  const MomentDetailScreen({super.key, required this.momentId});

  final String momentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(momentItemsProvider);
    final theme = Theme.of(context);

    final matches = items.where((item) => item.id == momentId);
    final moment = matches.isEmpty ? null : matches.first;
    final progress = ref.watch(progressProvider(momentId));

    if (moment == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Momento no encontrado')),
      );
    }

    final isCompleted = progress?.completed ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(moment.title),
        actions: [
          if (moment.isCustom)
            IconButton(
              tooltip: 'Borrar momento',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteCustom(context, ref),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showEditMemorySheet(
          context,
          experienceId: momentId,
          experienceTitle: moment.title,
        ),
        icon: Icon(isCompleted ? Icons.edit_outlined : Icons.favorite_border),
        label: Text(isCompleted ? 'Editar recuerdo' : 'Completar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        children: [
          Text(
            moment.category.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.terracotta,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(moment.title, style: theme.textTheme.headlineSmall),
          if (moment.description != null) ...[
            const SizedBox(height: 12),
            Text(
              moment.description!,
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
                  'Aún no han vivido este momento.\nCuando lo hagan, documéntenlo aquí ❤️',
            ),
        ],
      ),
    );
  }

  /// Borra el momento personalizado: su definición, su recuerdo y sus fotos.
  Future<void> _deleteCustom(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Borrar momento',
      message:
          '¿Seguro que quieren borrar este momento personalizado? Se eliminarán también su recuerdo y sus fotos.',
    );
    if (!confirmed) return;

    final storage = ref.read(imageStorageServiceProvider);
    await storage.deleteExperiencePhotos(momentId);
    await ref.read(progressControllerProvider.notifier).delete(momentId);
    await ref.read(customMomentsControllerProvider.notifier).delete(momentId);

    if (context.mounted) Navigator.of(context).pop();
  }
}
