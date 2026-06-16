import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Wrapper fino sobre `image_picker`. Devuelve el **path temporal** de la foto
/// elegida (o `null` si el usuario cancela); copiar ese archivo a un lugar
/// permanente es responsabilidad de `ImageStorageService`.
class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  // Reducimos el peso de las fotos sin pérdida visible en pantalla.
  static const double _maxWidth = 1920;
  static const int _imageQuality = 85;

  /// Elige una foto de la galería.
  Future<String?> pickFromGallery() => _pick(ImageSource.gallery);

  /// Toma una foto con la cámara.
  Future<String?> pickFromCamera() => _pick(ImageSource.camera);

  Future<String?> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxWidth,
      imageQuality: _imageQuality,
    );
    return picked?.path;
  }
}

final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => ImagePickerService(),
);
