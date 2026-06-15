import 'package:album_app/catalog/catalog_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Necesario para que rootBundle pueda leer los assets en los tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogLoader (catalog.json real)', () {
    test('carga los 9 departamentos y experiencias', () async {
      final catalog = await const CatalogLoader().load();

      expect(catalog.departments, hasLength(9));
      expect(catalog.experiences, isNotEmpty);
    });

    test('los ids de departamento y de experiencia son únicos', () async {
      final catalog = await const CatalogLoader().load();

      final deptIds = catalog.departments.map((d) => d.id).toList();
      final expIds = catalog.experiences.map((e) => e.id).toList();

      expect(deptIds.toSet(), hasLength(deptIds.length), reason: 'ids de depto repetidos');
      expect(expIds.toSet(), hasLength(expIds.length), reason: 'ids de experiencia repetidos');
    });

    test('toda experiencia apunta a un departamento existente', () async {
      final catalog = await const CatalogLoader().load();
      final deptIds = catalog.departments.map((d) => d.id).toSet();

      for (final exp in catalog.experiences) {
        expect(
          deptIds,
          contains(exp.departmentId),
          reason: 'la experiencia "${exp.id}" apunta a "${exp.departmentId}" inexistente',
        );
      }
    });

    test('cada departamento tiene al menos una experiencia', () async {
      final catalog = await const CatalogLoader().load();

      for (final dept in catalog.departments) {
        expect(
          catalog.experiencesFor(dept.id),
          isNotEmpty,
          reason: 'el departamento "${dept.id}" no tiene experiencias',
        );
      }
    });
  });
}
