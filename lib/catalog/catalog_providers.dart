import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_loader.dart';
import 'models/catalog.dart';
import 'models/department.dart';
import 'models/experience.dart';

/// Loader del catálogo (inyectable: se puede sustituir en tests).
final catalogLoaderProvider = Provider<CatalogLoader>(
  (ref) => const CatalogLoader(),
);

/// Carga el catálogo curado una sola vez desde los assets.
final catalogProvider = FutureProvider<Catalog>((ref) async {
  return ref.watch(catalogLoaderProvider).load();
});

/// Departamentos del catálogo. Vacío mientras carga o si hubo error
/// (la UI observa [catalogProvider] para los estados de carga/error).
final departmentsProvider = Provider<List<Department>>((ref) {
  return ref.watch(catalogProvider).value?.departments ?? const [];
});

/// Experiencias de un departamento dado, en el orden del catálogo.
final experiencesByDeptProvider =
    Provider.family<List<Experience>, String>((ref, departmentId) {
  return ref.watch(catalogProvider).value?.experiencesFor(departmentId) ??
      const [];
});
