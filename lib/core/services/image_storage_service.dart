import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Guarda y resuelve las fotos de los recuerdos en el sistema de archivos.
///
/// Regla del Design (§4): en Hive solo viven **nombres de archivo**; la ruta
/// absoluta se reconstruye en tiempo de lectura como
/// `{appDocs}/photos/{experienceId}/{fileName}` (la base cambia en iOS entre
/// arranques). Por eso el directorio base se **inyecta**.
class ImageStorageService {
  ImageStorageService(this.baseDir, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  /// Directorio de documentos de la app (`getApplicationDocumentsDirectory`).
  final Directory baseDir;
  final Uuid _uuid;

  Directory _photosDir(String experienceId) =>
      Directory('${baseDir.path}/photos/$experienceId');

  /// Copia la foto de [sourcePath] al directorio de [experienceId] con un nombre
  /// único y devuelve **solo el nombre de archivo** (lo que se guarda en Hive).
  Future<String> savePhoto({
    required String experienceId,
    required String sourcePath,
  }) async {
    final dir = _photosDir(experienceId);
    await dir.create(recursive: true);
    final fileName = '${_uuid.v4()}${_extensionOf(sourcePath)}';
    final destPath = '${dir.path}/$fileName';
    await File(sourcePath).copy(destPath);
    return fileName;
  }

  /// Reconstruye el [File] de una foto a partir de su nombre. No garantiza que
  /// exista (úsese `File.exists()` si hace falta comprobarlo).
  File resolveFile(String experienceId, String fileName) =>
      File('${_photosDir(experienceId).path}/$fileName');

  /// Borra una foto puntual. No falla si el archivo ya no existe.
  Future<void> deletePhoto(String experienceId, String fileName) async {
    final file = resolveFile(experienceId, fileName);
    if (await file.exists()) await file.delete();
  }

  /// Borra todas las fotos de una experiencia (la carpeta entera).
  Future<void> deleteExperiencePhotos(String experienceId) async {
    final dir = _photosDir(experienceId);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Extensión en minúsculas de un path (ej. `.jpg`), con `.jpg` por defecto.
  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    final slash = path.lastIndexOf(RegExp(r'[\\/]'));
    if (dot != -1 && dot > slash) {
      final ext = path.substring(dot).toLowerCase();
      if (ext.length <= 5) return ext;
    }
    return '.jpg';
  }
}

/// Directorio de documentos de la app. Se **sobreescribe** en `main` con el
/// valor real de `path_provider` (y en tests con un directorio temporal).
final appDocsDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(
    'appDocsDirProvider debe sobreescribirse en main() con getApplicationDocumentsDirectory().',
  ),
);

final imageStorageServiceProvider = Provider<ImageStorageService>(
  (ref) => ImageStorageService(ref.watch(appDocsDirProvider)),
);
