// Detalle de experiencia + hoja de edición (Fase 7).
//
// Catálogo síncrono, repo de progreso en memoria y un directorio temporal real
// para el almacenamiento de fotos. El picker se sustituye por un doble.

import 'dart:io';

import 'package:album_app/app/theme/app_theme.dart';
import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:album_app/core/services/image_picker_service.dart';
import 'package:album_app/core/services/image_storage_service.dart';
import 'package:album_app/experience/experience_providers.dart';
import 'package:album_app/experience/models/experience_progress.dart';
import 'package:album_app/experience/presentation/experience_detail_screen.dart';
import 'package:album_app/shared/widgets/heart_rating.dart';
import 'package:album_app/shared/widgets/polaroid_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_progress_repository.dart';

/// Picker de prueba: devuelve siempre [path] (o `null` para simular cancelar).
class _FakePicker extends ImagePickerService {
  _FakePicker(this.path);
  final String? path;
  @override
  Future<String?> pickFromGallery() async => path;
  @override
  Future<String?> pickFromCamera() async => path;
}

/// Storage cuyo borrado no toca disco: el I/O real (`dir.exists`/`delete`) no
/// se drena bajo el `FakeAsync` de `testWidgets` y colgaría `pumpAndSettle`.
class _NoIoStorage extends ImageStorageService {
  _NoIoStorage(super.baseDir);
  @override
  Future<void> deleteExperiencePhotos(String experienceId) async {}
}

void main() {
  const testCatalog = Catalog(
    departments: [Department(id: 'la_paz', name: 'La Paz')],
    experiences: [
      Experience(
        id: 'lp_telef',
        departmentId: 'la_paz',
        title: 'Subir al Teleférico',
        description: 'Vean la ciudad encenderse desde las alturas.',
        category: 'paisaje',
      ),
    ],
  );

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('exp_detail_test');
  });

  tearDown(() async {
    // En Windows la caché de imágenes puede retener un handle del archivo;
    // si la limpieza falla por eso, se ignora (es un directorio temporal).
    try {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    } on FileSystemException {
      // ignore
    }
  });

  Widget buildApp({
    List<ExperienceProgress> progress = const [],
    String? pickerPath,
    bool noIoStorage = false,
  }) {
    return ProviderScope(
      overrides: [
        catalogProvider.overrideWith((ref) => testCatalog),
        progressRepositoryProvider
            .overrideWithValue(InMemoryProgressRepository(progress)),
        appDocsDirProvider.overrideWithValue(tempDir),
        imagePickerServiceProvider.overrideWithValue(_FakePicker(pickerPath)),
        if (noIoStorage)
          imageStorageServiceProvider.overrideWithValue(_NoIoStorage(tempDir)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ExperienceDetailScreen(experienceId: 'lp_telef'),
      ),
    );
  }

  testWidgets('no completada: muestra invitación y FAB "Completar"',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.textContaining('Aún no han vivido'), findsOneWidget);
    expect(find.text('Completar'), findsOneWidget);
    expect(find.text('Editar recuerdo'), findsNothing);
  });

  testWidgets('completada: muestra fecha, corazones y nota', (tester) async {
    await tester.pumpWidget(buildApp(progress: [
      ExperienceProgress.create(
        experienceId: 'lp_telef',
        completed: true,
        completedDate: DateTime(2026, 2, 14),
        rating: 5,
        note: 'Inolvidable',
      ),
    ]));
    await tester.pump();

    expect(find.text('Recuerdo completado'), findsOneWidget);
    expect(find.text('14 de febrero de 2026'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(5));
    expect(find.text('Inolvidable'), findsOneWidget);
    expect(find.text('Editar recuerdo'), findsOneWidget);
  });

  testWidgets('crear recuerdo desde la hoja persiste fecha/corazones/nota',
      (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    // Abre la hoja de edición.
    await tester.tap(find.text('Completar'));
    await tester.pumpAndSettle();

    // Pone 4 corazones (el 4º corazón de los 5 del selector de la hoja).
    final heartIcons = find.descendant(
      of: find.byType(HeartRating),
      matching: find.byIcon(Icons.favorite_border),
    );
    await tester.tap(heartIcons.at(3));
    await tester.pump();

    // Escribe una nota.
    await tester.enterText(find.byType(TextField), 'Qué linda tarde');

    // Guarda.
    await tester.tap(find.text('Guardar recuerdo'));
    await tester.pumpAndSettle();

    // De vuelta en el detalle, el recuerdo aparece reflejado.
    expect(find.text('Recuerdo completado'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(4));
    expect(find.text('Qué linda tarde'), findsOneWidget);
  });

  testWidgets('borrar recuerdo: pide confirmación y elimina el progreso',
      (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(buildApp(noIoStorage: true, progress: [
      ExperienceProgress.create(
        experienceId: 'lp_telef',
        completed: true,
        completedDate: DateTime(2026, 2, 14),
        rating: 5,
        note: 'Inolvidable',
      ),
    ]));
    await tester.pump();

    // Abre la hoja de edición (botón "Editar recuerdo").
    await tester.tap(find.text('Editar recuerdo'));
    await tester.pumpAndSettle();

    // Pulsa "Borrar recuerdo" → aparece el diálogo de confirmación.
    await tester.tap(find.text('Borrar recuerdo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('¿Seguro que quieren borrar'), findsOneWidget);

    // Confirma con el botón "Borrar" del diálogo.
    await tester.tap(find.widgetWithText(FilledButton, 'Borrar'));
    await tester.pumpAndSettle();

    // De vuelta en el detalle, el recuerdo ya no existe: vuelve la invitación.
    expect(find.text('Recuerdo completado'), findsNothing);
    expect(find.textContaining('Aún no han vivido'), findsOneWidget);
    expect(find.text('Completar'), findsOneWidget);
  });

  testWidgets('elegir una foto la agrega a la hoja como polaroid',
      (tester) async {
    _useTallSurface(tester);
    // Fuente temporal que el picker "devolverá".
    final source = File('${tempDir.path}/origen.jpg')..writeAsBytesSync([9, 9]);

    await tester.pumpWidget(buildApp(pickerPath: source.path));
    await tester.pump();

    await tester.tap(find.text('Completar'));
    await tester.pumpAndSettle();

    // Aún no hay fotos en la tira.
    expect(find.byType(PolaroidPhoto), findsNothing);

    // Botón "Agregar" → menú → "Elegir de la galería".
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir de la galería'));
    await tester.pumpAndSettle();

    // La foto pendiente aparece como polaroid (la copia a disco al guardar se
    // cubre en los tests de ImageStorageService).
    expect(find.byType(PolaroidPhoto), findsOneWidget);
  });
}

/// Usa una ventana alta para que toda la hoja de edición quepa sin scroll.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
