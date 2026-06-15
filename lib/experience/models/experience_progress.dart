import 'package:hive_ce/hive.dart';

part 'experience_progress.g.dart';

/// Progreso mutable del usuario sobre una experiencia curada.
///
/// Vive en Hive (su clave en el box es [experienceId]) y se enlaza con el
/// catálogo por ese mismo id. Solo existe un registro cuando el usuario
/// interactúa con la experiencia (la completa o le agrega algo).
///
/// Registro de `typeId` de Hive (mantener único por tipo):
/// - 0 → [ExperienceProgress]
@HiveType(typeId: 0)
class ExperienceProgress {
  const ExperienceProgress({
    required this.experienceId,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.completedDate,
    this.rating,
    this.note,
    this.photoFileNames = const [],
  });

  /// Crea un progreso nuevo con timestamps iniciales (`createdAt == updatedAt`).
  factory ExperienceProgress.create({
    required String experienceId,
    bool completed = false,
    DateTime? completedDate,
    int? rating,
    String? note,
    List<String> photoFileNames = const [],
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return ExperienceProgress(
      experienceId: experienceId,
      completed: completed,
      completedDate: completedDate,
      rating: rating,
      note: note,
      photoFileNames: photoFileNames,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// Enlaza con `Experience.id` del catálogo.
  @HiveField(0)
  final String experienceId;

  /// Marcado como completado por la pareja.
  @HiveField(1)
  final bool completed;

  /// Fecha en que vivieron la experiencia.
  @HiveField(2)
  final DateTime? completedDate;

  /// Valoración en corazones (1–5).
  @HiveField(3)
  final int? rating;

  /// Nota / texto libre del recuerdo.
  @HiveField(4)
  final String? note;

  /// Solo **nombres de archivo** de las fotos (no rutas absolutas, ver Design §3.3).
  @HiveField(5)
  final List<String> photoFileNames;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  ExperienceProgress copyWith({
    bool? completed,
    DateTime? completedDate,
    int? rating,
    String? note,
    List<String>? photoFileNames,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExperienceProgress(
      experienceId: experienceId,
      completed: completed ?? this.completed,
      completedDate: completedDate ?? this.completedDate,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      photoFileNames: photoFileNames ?? this.photoFileNames,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ExperienceProgress(experienceId: $experienceId, completed: $completed, '
      'rating: $rating, photos: ${photoFileNames.length})';
}
