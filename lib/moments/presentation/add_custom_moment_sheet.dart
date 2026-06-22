import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/custom_moment.dart';
import '../moments_providers.dart';

/// Abre la hoja para crear un momento personalizado.
Future<void> showAddCustomMomentSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const AddCustomMomentSheet(),
  );
}

/// Hoja para crear un momento personalizado: título libre + categoría.
class AddCustomMomentSheet extends ConsumerStatefulWidget {
  const AddCustomMomentSheet({super.key});

  @override
  ConsumerState<AddCustomMomentSheet> createState() =>
      _AddCustomMomentSheetState();
}

class _AddCustomMomentSheetState extends ConsumerState<AddCustomMomentSheet> {
  final _titleController = TextEditingController();
  String _category = defaultCustomCategory;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final moment = CustomMoment(
      id: 'mc_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      category: _category,
      createdAt: DateTime.now(),
    );
    await ref.read(customMomentsControllerProvider.notifier).save(moment);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Nuevo momento', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          Text('¿Qué momento quieren recordar?',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Ej. Primera vez bailando juntos',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Categoría', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (final c in momentCategories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (value) =>
                setState(() => _category = value ?? defaultCustomCategory),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Crear momento'),
          ),
        ],
      ),
    );
  }
}
