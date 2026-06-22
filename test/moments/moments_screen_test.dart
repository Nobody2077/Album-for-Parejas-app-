// Pantalla de momentos (Fase 9): timeline, completar, crear personalizado.
//
// Router de prueba aislado y catálogo síncrono con momentos. Persistencia en
// memoria (Hive no es compatible con testWidgets/FakeAsync).

import 'dart:io';

import 'package:album_app/app/theme/app_theme.dart';
import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:album_app/catalog/models/moment.dart';
import 'package:album_app/core/services/image_storage_service.dart';
import 'package:album_app/experience/experience_providers.dart';
import 'package:album_app/experience/models/experience_progress.dart';
import 'package:album_app/moments/moments_providers.dart';
import 'package:album_app/moments/presentation/moment_detail_screen.dart';
import 'package:album_app/moments/presentation/moments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/in_memory_moments_repository.dart';
import '../support/in_memory_progress_repository.dart';

void main() {
  const testCatalog = Catalog(
    departments: [Department(id: 'la_paz', name: 'La Paz')],
    experiences: [Experience(id: 'lp_x', departmentId: 'la_paz', title: 'X')],
    moments: [
      Moment(
        id: 'm_primera_cita',
        title: 'Primera cita',
        category: 'Primeras veces',
        description: 'El día que todo empezó.',
      ),
      Moment(id: 'm_cumple', title: 'Cumpleaños de ella', category: 'Celebraciones'),
    ],
  );

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('moments_test');
  });

  tearDown(() async {
    try {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    } on FileSystemException {
      // ignore (handles de imagen en Windows)
    }
  });

  Widget buildApp({List<ExperienceProgress> progress = const []}) {
    final router = GoRouter(
      initialLocation: '/moments',
      routes: [
        GoRoute(
          path: '/moments',
          builder: (context, state) => const MomentsScreen(),
        ),
        GoRoute(
          path: '/moments/:momentId',
          builder: (context, state) =>
              MomentDetailScreen(momentId: state.pathParameters['momentId']!),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        catalogProvider.overrideWith((ref) => testCatalog),
        progressRepositoryProvider
            .overrideWithValue(InMemoryProgressRepository(progress)),
        momentsRepositoryProvider
            .overrideWithValue(InMemoryMomentsRepository()),
        appDocsDirProvider.overrideWithValue(tempDir),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('timeline muestra las categorías y los momentos', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.text('PRIMERAS VECES'), findsOneWidget);
    expect(find.text('CELEBRACIONES'), findsOneWidget);
    expect(find.text('Primera cita'), findsOneWidget);
    // Contador en el AppBar: 0 de 2.
    expect(find.text('0 / 2'), findsOneWidget);
  });

  testWidgets('un momento completado muestra su fecha corta', (tester) async {
    await tester.pumpWidget(buildApp(progress: [
      ExperienceProgress.create(
        experienceId: 'm_primera_cita',
        completed: true,
        completedDate: DateTime(2026, 2, 14),
      ),
    ]));
    await tester.pump();

    expect(find.text('14/02/2026'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('crear un momento personalizado lo agrega al timeline',
      (tester) async {
    // Ventana alta para que todo el timeline (incl. el grupo nuevo) quepa sin
    // scroll; si no, el ListView no construye lo que queda fuera de pantalla.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('Agregar momento'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Primera vez bailando');
    await tester.pump(); // habilita el botón (setState de _canSave)
    await tester.tap(find.text('Crear momento'));
    await tester.pumpAndSettle();

    expect(find.text('PERSONALIZADOS'), findsOneWidget);
    expect(find.text('Primera vez bailando'), findsOneWidget);
  });

  testWidgets('tocar un momento abre su detalle', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('Primera cita'));
    await tester.pumpAndSettle();

    // En el detalle aparece la descripción y el FAB "Completar".
    expect(find.text('El día que todo empezó.'), findsOneWidget);
    expect(find.text('Completar'), findsOneWidget);
  });
}
