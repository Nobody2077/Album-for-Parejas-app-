// Pantallas de departamentos (Fase 7): grid con progreso y navegación al detalle.
//
// Router de prueba aislado y catálogo síncrono. La persistencia se sustituye
// por un repo en memoria (Hive no es compatible con testWidgets/FakeAsync).

import 'package:album_app/app/theme/app_theme.dart';
import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:album_app/departments/presentation/department_detail_screen.dart';
import 'package:album_app/departments/presentation/departments_screen.dart';
import 'package:album_app/experience/experience_providers.dart';
import 'package:album_app/experience/models/experience_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/in_memory_progress_repository.dart';

void main() {
  const testCatalog = Catalog(
    departments: [
      Department(id: 'la_paz', name: 'La Paz', emoji: '🏔️'),
      Department(id: 'oruro', name: 'Oruro', emoji: '🎭'),
    ],
    experiences: [
      Experience(id: 'lp_telef', departmentId: 'la_paz', title: 'Teleférico'),
      Experience(id: 'lp_luna', departmentId: 'la_paz', title: 'Valle de la Luna'),
      Experience(id: 'or_carnaval', departmentId: 'oruro', title: 'Carnaval'),
    ],
  );

  Widget buildApp({List<ExperienceProgress> progress = const []}) {
    final router = GoRouter(
      initialLocation: '/departments',
      routes: [
        GoRoute(
          path: '/departments',
          builder: (context, state) => const DepartmentsScreen(),
        ),
        GoRoute(
          path: '/departments/:deptId',
          builder: (context, state) => DepartmentDetailScreen(
            departmentId: state.pathParameters['deptId']!,
          ),
        ),
        GoRoute(
          path: '/experiences/:expId',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('PANTALLA EXP'))),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        catalogProvider.overrideWith((ref) => testCatalog),
        progressRepositoryProvider
            .overrideWithValue(InMemoryProgressRepository(progress)),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('grid muestra los departamentos con su progreso', (tester) async {
    await tester.pumpWidget(buildApp(progress: [
      ExperienceProgress.create(experienceId: 'lp_telef', completed: true),
    ]));
    await tester.pump();

    expect(find.text('La Paz'), findsOneWidget);
    expect(find.text('Oruro'), findsOneWidget);
    // La Paz: 1 de 2 completadas.
    expect(find.text('1 / 2'), findsOneWidget);
    // Oruro: 0 de 1.
    expect(find.text('0 / 1'), findsOneWidget);
  });

  testWidgets('tocar un departamento abre su detalle con las experiencias',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('La Paz'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // AppBar del detalle + las dos experiencias del departamento.
    expect(find.text('Teleférico'), findsOneWidget);
    expect(find.text('Valle de la Luna'), findsOneWidget);
    expect(find.text('Carnaval'), findsNothing);
  });

  testWidgets('desde el detalle se navega a una experiencia', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('Oruro'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Carnaval'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('PANTALLA EXP'), findsOneWidget);
  });
}
