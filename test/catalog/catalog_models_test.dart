import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Department.fromJson', () {
    test('parsea todos los campos', () {
      final dept = Department.fromJson({
        'id': 'la_paz',
        'name': 'La Paz',
        'description': 'La sede de gobierno.',
        'emoji': '🏔️',
      });

      expect(dept.id, 'la_paz');
      expect(dept.name, 'La Paz');
      expect(dept.description, 'La sede de gobierno.');
      expect(dept.emoji, '🏔️');
    });

    test('los campos opcionales pueden faltar', () {
      final dept = Department.fromJson({'id': 'oruro', 'name': 'Oruro'});

      expect(dept.description, isNull);
      expect(dept.emoji, isNull);
    });

    test('lanza FormatException si falta un campo obligatorio', () {
      expect(
        () => Department.fromJson({'id': 'la_paz'}), // falta name
        throwsFormatException,
      );
    });
  });

  group('Experience.fromJson', () {
    test('parsea todos los campos', () {
      final exp = Experience.fromJson({
        'id': 'lp_telef',
        'departmentId': 'la_paz',
        'title': 'Subir al Teleférico juntos',
        'description': 'Tomen la línea roja al atardecer.',
        'category': 'paisaje',
      });

      expect(exp.id, 'lp_telef');
      expect(exp.departmentId, 'la_paz');
      expect(exp.title, 'Subir al Teleférico juntos');
      expect(exp.description, 'Tomen la línea roja al atardecer.');
      expect(exp.category, 'paisaje');
    });

    test('lanza FormatException si falta departmentId', () {
      expect(
        () => Experience.fromJson({'id': 'lp_telef', 'title': 'X'}),
        throwsFormatException,
      );
    });
  });

  group('Igualdad por id', () {
    test('dos departamentos con el mismo id son iguales', () {
      const a = Department(id: 'la_paz', name: 'La Paz');
      const b = Department(id: 'la_paz', name: 'Otro nombre');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('dos experiencias con distinto id no son iguales', () {
      const a = Experience(id: 'a', departmentId: 'la_paz', title: 'A');
      const b = Experience(id: 'b', departmentId: 'la_paz', title: 'A');

      expect(a, isNot(equals(b)));
    });
  });

  group('Catalog', () {
    final catalog = Catalog.fromJson({
      'departments': [
        {'id': 'la_paz', 'name': 'La Paz'},
        {'id': 'cochabamba', 'name': 'Cochabamba'},
      ],
      'experiences': [
        {'id': 'lp_telef', 'departmentId': 'la_paz', 'title': 'Teleférico'},
        {'id': 'lp_luna', 'departmentId': 'la_paz', 'title': 'Valle de la Luna'},
        {'id': 'cb_silp', 'departmentId': 'cochabamba', 'title': 'Silpancho'},
      ],
    });

    test('parsea las dos listas', () {
      expect(catalog.departments, hasLength(2));
      expect(catalog.experiences, hasLength(3));
    });

    test('experiencesFor devuelve solo las del departamento', () {
      final lpaz = catalog.experiencesFor('la_paz');
      expect(lpaz, hasLength(2));
      expect(lpaz.map((e) => e.id), ['lp_telef', 'lp_luna']);

      expect(catalog.experiencesFor('inexistente'), isEmpty);
    });

    test('departmentById encuentra o devuelve null', () {
      expect(catalog.departmentById('cochabamba')?.name, 'Cochabamba');
      expect(catalog.departmentById('inexistente'), isNull);
    });

    test('lanza FormatException si falta una lista', () {
      expect(
        () => Catalog.fromJson({'departments': []}), // falta experiences
        throwsFormatException,
      );
    });
  });
}
