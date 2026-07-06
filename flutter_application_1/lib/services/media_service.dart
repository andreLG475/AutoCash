import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'bmp'],
        allowCompression: true,
      );

      final path = result?.files.single.path;
      if (path == null) {
        return null;
      }
      return File(path);
    } catch (e) {
      debugPrint('Erro ao escolher arquivo: $e');
      return null;
    }
  }

  /// Escolhe múltiplas fotos
  static Future<List<File>?> pickMultiplePhotos() async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      return photos.map((p) => File(p.path)).toList();
    } catch (e) {
      debugPrint('Erro ao escolher múltiplas fotos: $e');
      return null;
    }
  }

  /// Copia um arquivo para o diretório de documentos do app para garantir persistência.
  static Future<String?> persistFile(
    File file, {
    String subFolder = 'uploads',
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDir.path}/$subFolder');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final lastSegment = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'arquivo';
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_$lastSegment';
      final copiedFile = File('${targetDir.path}/$fileName');
      await file.copy(copiedFile.path);
      return copiedFile.path;
    } catch (e) {
      debugPrint('Erro ao persistir arquivo: $e');
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
