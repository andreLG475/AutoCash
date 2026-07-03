import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Tira uma foto usando a câmera
  static Future<File?> takePhotoFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
      return null;
    }
  }

  /// Escolhe uma foto da galeria
  static Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      debugPrint('Erro ao escolher foto: $e');
      return null;
    }
  }

  /// Escolhe um arquivo (PDF, imagem, etc)
  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'bmp'],
        allowCompression: true,
      );

      return result != null && result.files.single.path != null
          ? File(result.files.single.path!)
          : null;
    } catch (e) {
      debugPrint('Erro ao escolher arquivo: $e');
      return null;
    }
  }

  /// Escolhe múltiplas fotos
  static Future<List<File>?> pickMultiplePhotos() async {
    try {
      final List<XFile>? photos = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      return photos != null ? photos.map((p) => File(p.path)).toList() : null;
    } catch (e) {
      debugPrint('Erro ao escolher múltiplas fotos: $e');
      return null;
    }
  }

  /// Obtém o nome do arquivo
  static String getFileName(File file) {
    return file.path.split('/').last;
  }

  /// Obtém o tamanho do arquivo em MB
  static double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Verifica se é imagem
  static bool isImage(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Verifica se é PDF
  static bool isPDF(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ext == 'pdf';
  }
}
