import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/services/image_storage_service.dart';
import '../../shared/dialogs/confirm_dialog.dart';
import '../../shared/format/memory_date.dart';
import '../../shared/widgets/heart_rating.dart';
import '../../shared/widgets/polaroid_photo.dart';
import '../experience_providers.dart';
import '../models/experience_progress.dart';

/// Abre la hoja para crear/editar el recuerdo de una experiencia.
Future<void> showEditMemorySheet(
  BuildContext context, {
  required String experienceId,
  required String experienceTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => EditMemorySheet(
      experienceId: experienceId,
      experienceTitle: experienceTitle,
    ),
  );
}

/// Hoja para documentar un recuerdo: fecha, corazones (1–5), nota y fotos.
///
/// Toda escritura a disco se difiere hasta "Guardar": las fotos nuevas se
/// mantienen como rutas temporales y solo se copian al almacenamiento al
/// confirmar, de modo que cancelar no deja archivos huérfanos.
class EditMemorySheet extends ConsumerStatefulWidget {
  const EditMemorySheet({
    super.key,
    required this.experienceId,
    required this.experienceTitle,
  });

  final String experienceId;
  final String experienceTitle;

  @override
  ConsumerState<EditMemorySheet> createState() => _EditMemorySheetState();
}

class _EditMemorySheetState extends ConsumerState<EditMemorySheet> {
  late final TextEditingController _noteController;
  late DateTime _date;
  int _rating = 0;
  final List<_PhotoDraft> _photos = [];
  bool _saving = false;

  /// `true` si ya existe un recuerdo completado (estamos editando, no creando).
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(progressProvider(widget.experienceId));
    _isEditing = existing?.completed ?? false;
    _noteController = TextEditingController(text: existing?.note ?? '');
    _date = existing?.completedDate ?? DateTime.now();
    _rating = existing?.rating ?? 0;
    for (final fileName in existing?.photoFileNames ?? const <String>[]) {
      _photos.add(_PhotoDraft.existing(fileName));
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _addPhoto({required bool fromCamera}) async {
    final picker = ref.read(imagePickerServiceProvider);
    final path = fromCamera
        ? await picker.pickFromCamera()
        : await picker.pickFromGallery();
    if (path != null) {
      setState(() => _photos.add(_PhotoDraft.pending(path)));
    }
  }

  void _showAddPhotoMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final storage = ref.read(imageStorageServiceProvider);
    final existing = ref.read(progressProvider(widget.experienceId));

    // Borra del disco las fotos existentes que el usuario quitó.
    final kept = _photos
        .where((p) => p.isExisting)
        .map((p) => p.fileName)
        .toSet();
    for (final fileName in existing?.photoFileNames ?? const <String>[]) {
      if (!kept.contains(fileName)) {
        await storage.deletePhoto(widget.experienceId, fileName);
      }
    }

    // Copia al almacenamiento las fotos nuevas; arma la lista final en orden.
    final finalNames = <String>[];
    for (final photo in _photos) {
      if (photo.isExisting) {
        finalNames.add(photo.fileName!);
      } else {
        final name = await storage.savePhoto(
          experienceId: widget.experienceId,
          sourcePath: photo.sourcePath!,
        );
        finalNames.add(name);
      }
    }

    final note = _noteController.text.trim();
    // El repositorio preserva createdAt; create() permite limpiar a null.
    final progress = ExperienceProgress.create(
      experienceId: widget.experienceId,
      completed: true,
      completedDate: _date,
      rating: _rating == 0 ? null : _rating,
      note: note.isEmpty ? null : note,
      photoFileNames: finalNames,
    );
    await ref.read(progressControllerProvider.notifier).save(progress);

    if (mounted) Navigator.pop(context);
  }

  /// Quita una foto de la tira, confirmando primero para evitar toques
  /// accidentales en la "X".
  Future<void> _removePhoto(int index) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Quitar foto',
      message: '¿Quitar esta foto del recuerdo?',
      confirmLabel: 'Quitar',
    );
    if (confirmed) setState(() => _photos.removeAt(index));
  }

  /// Borra por completo el recuerdo (registro + fotos en disco), con
  /// confirmación previa.
  Future<void> _deleteMemory() async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Borrar recuerdo',
      message:
          '¿Seguro que quieren borrar este recuerdo? Se eliminarán también sus fotos. Esta acción no se puede deshacer.',
    );
    if (!confirmed) return;

    setState(() => _saving = true);
    final storage = ref.read(imageStorageServiceProvider);
    await storage.deleteExperiencePhotos(widget.experienceId);
    await ref.read(progressControllerProvider.notifier).delete(
          widget.experienceId,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storage = ref.watch(imageStorageServiceProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.experienceTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),

            // Fecha
            Text('¿Cuándo lo vivieron?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(formatMemoryDate(_date)),
            ),
            const SizedBox(height: 24),

            // Corazones
            Text('¿Cuánto lo disfrutaron?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            HeartRating(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
              size: 36,
            ),
            const SizedBox(height: 24),

            // Nota
            Text('Una nota para recordar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Lo que sintieron, lo que pasó…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Fotos
            Text('Fotos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _PhotoStrip(
              photos: _photos,
              storage: storage,
              experienceId: widget.experienceId,
              onAdd: _showAddPhotoMenu,
              onRemove: _removePhoto,
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar recuerdo'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _saving ? null : _deleteMemory,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Borrar recuerdo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tira horizontal de fotos (borrables) con un botón para agregar al final.
class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.photos,
    required this.storage,
    required this.experienceId,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_PhotoDraft> photos;
  final ImageStorageService storage;
  final String experienceId;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: photos.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == photos.length) {
            return _AddPhotoButton(onTap: onAdd);
          }
          final photo = photos[index];
          final file = photo.isExisting
              ? storage.resolveFile(experienceId, photo.fileName!)
              : File(photo.sourcePath!);
          return PolaroidPhoto(
            file: file,
            size: 96,
            onDelete: () => onRemove(index),
          );
        },
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceDim.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceDim, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.terracotta),
            SizedBox(height: 6),
            Text('Agregar', style: TextStyle(color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}

/// Una foto en edición: ya guardada (por [fileName]) o pendiente de copiar
/// (por [sourcePath], ruta temporal del picker).
class _PhotoDraft {
  _PhotoDraft.existing(this.fileName) : sourcePath = null;
  _PhotoDraft.pending(this.sourcePath) : fileName = null;

  final String? fileName;
  final String? sourcePath;

  bool get isExisting => fileName != null;
}
