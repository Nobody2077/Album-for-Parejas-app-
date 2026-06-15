import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        catalogProvider.overrideWith((ref) async => testCatalog),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('departmentsProvider expone los departamentos del catálogo', () async {
    final container = makeContainer();
    await container.read(catalogProvider.future);

    expect(container.read(departmentsProvider).map((d) => d.id), ['la_paz', 'oruro']);
  });

  test('experiencesByDeptProvider filtra por departamento', () async {
    final container = makeContainer();
    await container.read(catalogProvider.future);

    expect(container.read(experiencesByDeptProvider('la_paz')), hasLength(2));
    expect(container.read(experiencesByDeptProvider('oruro')), hasLength(1));
    expect(container.read(experiencesByDeptProvider('inexistente')), isEmpty);
  });

  test('antes de cargar, los providers derivados están vacíos', () {
    final container = makeContainer();

    // Sin await: el FutureProvider aún no resolvió.
    expect(container.read(departmentsProvider), isEmpty);
    expect(container.read(experiencesByDeptProvider('la_paz')), isEmpty);
  });
}
