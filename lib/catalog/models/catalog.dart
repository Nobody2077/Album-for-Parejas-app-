import 'package:flutter/foundation.dart';

import 'department.dart';
import 'experience.dart';

/// Catálogo curado completo: todos los departamentos y experiencias.
///
/// Es la representación en memoria de `assets/catalog/catalog.json`. Se carga
/// una vez al iniciar (ver Fase 3) y es inmutable.
@immutable
class Catalog {
  const Catalog({
    required this.departments,
    required this.experiences,
  });

  final List<Department> departments;
  final List<Experience> experiences;

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final departmentsJson = json['departments'];
    final experiencesJson = json['experiences'];
    if (departmentsJson is! List) {
      throw const FormatException(
        'Catálogo inválido: falta la lista "departments".',
      );
    }
    if (experiencesJson is! List) {
      throw const FormatException(
        'Catálogo inválido: falta la lista "experiences".',
      );
    }
    return Catalog(
      departments: departmentsJson
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      experiences: experiencesJson
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  /// Experiencias que pertenecen a [departmentId], en el orden del catálogo.
  List<Experience> experiencesFor(String departmentId) => experiences
      .where((e) => e.departmentId == departmentId)
      .toList(growable: false);

  /// Departamento con ese [id], o `null` si no existe en el catálogo.
  Department? departmentById(String id) {
    for (final department in departments) {
      if (department.id == id) return department;
    }
    return null;
  }

  /// Experiencia con ese [id], o `null` si no existe en el catálogo.
  Experience? experienceById(String id) {
    for (final experience in experiences) {
      if (experience.id == id) return experience;
    }
    return null;
  }
}
