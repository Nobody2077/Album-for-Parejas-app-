import 'package:album_app/catalog/catalog_loader.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/moment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Moment.fromJson', () {
    test('parsea los campos y aplica igualdad por id', () {
      final m = Moment.fromJson(const {
        'id': 'm_primera_cita',
        'title': 'Primera cita',
        'category': 'Primeras veces',
        'description': 'El día que todo empezó.',
        'icon': 'favorite',
      });

      expect(m.id, 'm_primera_cita');
      expect(m.title, 'Primera cita');
      expect(m.category, 'Primeras veces');
      expect(m.description, 'El día que todo empezó.');
      expect(m, const Moment(
        id: 'm_primera_cita',
        title: 'otro título',
        category: 'otra',
      ));
    });

    test('falla si falta un campo obligatorio', () {
      expect(
        () => Moment.fromJson(const {'id': 'm_x', 'title': 'X'}),
        throwsFormatException,
      );
    });
  });

  group('Catalog con moments', () {
    test('tolera la ausencia de la lista "moments"', () {
      final catalog = Catalog.fromJson(const {
        'departments': [
          {'id': 'la_paz', 'name': 'La Paz'},
        ],
        'experiences': [
          {'id': 'lp_x', 'departmentId': 'la_paz', 'title': 'X'},
        ],
      });
      expect(catalog.moments, isEmpty);
    });

    test('momentById encuentra por id', () {
      final catalog = Catalog.fromJson(const {
        'departments': [
          {'id': 'la_paz', 'name': 'La Paz'},
        ],
        'experiences': [
          {'id': 'lp_x', 'departmentId': 'la_paz', 'title': 'X'},
        ],
        'moments': [
          {'id': 'm_a', 'title': 'A', 'category': 'Primeras veces'},
        ],
      });
      expect(catalog.momentById('m_a')?.title, 'A');
      expect(catalog.momentById('nope'), isNull);
    });
  });

  group('catalog.json real', () {
    test('trae momentos curados con ids únicos y prefijo m_', () async {
      final catalog = await const CatalogLoader().load();

      expect(catalog.moments, isNotEmpty);
      final ids = catalog.moments.map((m) => m.id).toList();
      expect(ids.toSet(), hasLength(ids.length), reason: 'ids de momento repetidos');
      for (final m in catalog.moments) {
        expect(m.id, startsWith('m_'), reason: '${m.id} sin prefijo m_');
      }
    });
  });
}
