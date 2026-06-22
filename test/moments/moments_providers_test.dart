import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:album_app/catalog/models/moment.dart';
import 'package:album_app/experience/experience_providers.dart';
import 'package:album_app/experience/models/experience_progress.dart';
import 'package:album_app/moments/models/custom_moment.dart';
import 'package:album_app/moments/moments_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_moments_repository.dart';
import '../support/in_memory_progress_repository.dart';

void main() {
  const testCatalog = Catalog(
    departments: [Department(id: 'la_paz', name: 'La Paz')],
    experiences: [
      Experience(id: 'lp_x', departmentId: 'la_paz', title: 'X'),
    ],
    moments: [
      Moment(id: 'm_a', title: 'A', category: 'Primeras veces'),
      Moment(id: 'm_b', title: 'B', category: 'Celebraciones'),
      Moment(id: 'm_c', title: 'C', category: 'Primeras veces'),
    ],
  );

  ProviderContainer makeContainer({
    List<ExperienceProgress> progress = const [],
    List<CustomMoment> customs = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        catalogProvider.overrideWith((ref) async => testCatalog),
        progressRepositoryProvider
            .overrideWithValue(InMemoryProgressRepository(progress)),
        momentsRepositoryProvider
            .overrideWithValue(InMemoryMomentsRepository(customs)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('agrupa por categoría en el orden definido', () async {
    final container = makeContainer();
    await container.read(catalogProvider.future);

    final groups = container.read(momentGroupsProvider);
    expect(groups.map((g) => g.category), ['Primeras veces', 'Celebraciones']);
    // Dentro del grupo se conserva el orden del catálogo.
    expect(groups.first.items.map((i) => i.id), ['m_a', 'm_c']);
  });

  test('incluye los personalizados y los pone en su categoría', () async {
    final container = makeContainer(customs: [
      CustomMoment(
        id: 'mc_1',
        title: 'Bailar',
        category: 'Personalizados',
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
    await container.read(catalogProvider.future);

    final groups = container.read(momentGroupsProvider);
    expect(groups.last.category, 'Personalizados');
    expect(groups.last.items.single.title, 'Bailar');
    // Total de ítems: 3 curados + 1 personalizado.
    expect(container.read(momentItemsProvider), hasLength(4));
  });

  test('momentsProgressProvider cuenta completados sobre el total', () async {
    final container = makeContainer(progress: [
      ExperienceProgress.create(experienceId: 'm_a', completed: true),
      // m_b tocado pero no completado: no cuenta.
      ExperienceProgress.create(experienceId: 'm_b', completed: false),
    ]);
    await container.read(catalogProvider.future);

    final stats = container.read(momentsProgressProvider);
    expect(stats.total, 3);
    expect(stats.completed, 1);
  });
}
