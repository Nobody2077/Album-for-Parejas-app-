import 'dart:io';

import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:album_app/experience/data/hive_progress_repository.dart';
import 'package:album_app/experience/experience_providers.dart';
import 'package:album_app/experience/models/experience_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;
  const boxName = 'test_progress';

  setUpAll(() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExperienceProgressAdapter());
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<Box<ExperienceProgress>> openBox() =>
      Hive.openBox<ExperienceProgress>(boxName);

  group('ProgressRepository', () {
    test('guardar y leer persiste tras reabrir el box (reinicio)', () async {
      var box = await openBox();
      await HiveProgressRepository(box).save(
        ExperienceProgress.create(
          experienceId: 'lp_telef',
          completed: true,
          rating: 5,
          note: 'Inolvidable',
          completedDate: DateTime(2026, 2, 14),
          photoFileNames: const ['a.jpg', 'b.jpg'],
        ),
      );

      // Simula reinicio de la app: cerrar y reabrir el box.
      await box.close();
      box = await openBox();

      final loaded = HiveProgressRepository(box).getById('lp_telef');
      expect(loaded, isNotNull);
      expect(loaded!.completed, isTrue);
      expect(loaded.rating, 5);
      expect(loaded.note, 'Inolvidable');
      expect(loaded.completedDate, DateTime(2026, 2, 14));
      expect(loaded.photoFileNames, ['a.jpg', 'b.jpg']);
    });

    test('save conserva createdAt y refresca updatedAt', () async {
      final repo = HiveProgressRepository(await openBox());

      final first = await repo.save(
        ExperienceProgress.create(experienceId: 'x', now: DateTime(2020, 1, 1)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final second = await repo.save(first.copyWith(completed: true));

      expect(second.createdAt, first.createdAt);
      expect(second.updatedAt.isAfter(first.updatedAt), isTrue);
      expect(second.completed, isTrue);
    });

    test('delete elimina el registro', () async {
      final repo = HiveProgressRepository(await openBox());
      await repo.save(ExperienceProgress.create(experienceId: 'x'));

      await repo.delete('x');

      expect(repo.getById('x'), isNull);
    });

    test('getAllById indexa por experienceId', () async {
      final repo = HiveProgressRepository(await openBox());
      await repo.save(ExperienceProgress.create(experienceId: 'a'));
      await repo.save(ExperienceProgress.create(experienceId: 'b'));

      expect(repo.getAllById().keys.toSet(), {'a', 'b'});
    });
  });

  group('Providers de progreso', () {
    const testCatalog = Catalog(
      departments: [
        Department(id: 'la_paz', name: 'La Paz'),
        Department(id: 'oruro', name: 'Oruro'),
      ],
      experiences: [
        Experience(id: 'lp_telef', departmentId: 'la_paz', title: 'Teleférico'),
        Experience(id: 'lp_luna', departmentId: 'la_paz', title: 'Valle de la Luna'),
        Experience(id: 'or_carnaval', departmentId: 'oruro', title: 'Carnaval'),
      ],
    );

    Future<ProviderContainer> makeContainer() async {
      final box = await openBox();
      final container = ProviderContainer(
        overrides: [
          catalogProvider.overrideWith((ref) async => testCatalog),
          progressRepositoryProvider.overrideWithValue(HiveProgressRepository(box)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(catalogProvider.future);
      return container;
    }

    test('guardar progreso se refleja en los providers derivados', () async {
      final container = await makeContainer();

      expect(container.read(overallProgressProvider),
          const ProgressStats(completed: 0, total: 3));

      await container.read(progressControllerProvider.notifier).save(
            ExperienceProgress.create(experienceId: 'lp_telef', completed: true),
          );

      expect(container.read(progressProvider('lp_telef'))?.completed, isTrue);
      expect(container.read(overallProgressProvider),
          const ProgressStats(completed: 1, total: 3));
      expect(container.read(departmentProgressProvider('la_paz')),
          const ProgressStats(completed: 1, total: 2));
      expect(container.read(departmentProgressProvider('oruro')),
          const ProgressStats(completed: 0, total: 1));
    });

    test('borrar progreso lo quita de los providers', () async {
      final container = await makeContainer();
      final controller = container.read(progressControllerProvider.notifier);

      await controller
          .save(ExperienceProgress.create(experienceId: 'lp_telef', completed: true));
      await controller.delete('lp_telef');

      expect(container.read(progressProvider('lp_telef')), isNull);
      expect(container.read(overallProgressProvider),
          const ProgressStats(completed: 0, total: 3));
    });
  });
}
