import 'package:flutter/foundation.dart';

import 'department.dart';
import 'experience.dart';
import 'moment.dart';

/// Catálogo curado completo: departamentos, experiencias y momentos.
///
/// Es la representación en memoria de `assets/catalog/catalog.json`. Se carga
/// una vez al iniciar (ver Fase 3) y es inmutable.
@immutable
class Catalog {
  const Catalog({
    required this.departments,
    required this.experiences,
    this.moments = const [],
  });

  final List<Department> departments;
  final List<Experience> experiences;

  /// Momentos curados (hitos de pareja). Lista opcional en el JSON.
  final List<Moment> moments;

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final departmentsJson = json['departments'];
    final experiencesJson = json['experiences'];
    final momentsJson = json['moments'];
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
    if (momentsJson != null && momentsJson is! List) {
      throw const FormatException(
        'Catálogo inválido: "moments" debe ser una lista.',
      );
    }
    return Catalog(
      departments: departmentsJson
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      experiences: experiencesJson
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      moments: (momentsJson as List? ?? const [])
          .map((e) => Moment.fromJson(e as Map<String, dynamic>))
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

  /// Momento curado con ese [id], o `null` si no existe.
  Moment? momentById(String id) {
    for (final moment in moments) {
      if (moment.id == id) return moment;
    }
    return null;
  }
}
