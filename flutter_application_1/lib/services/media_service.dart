import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class MediaService {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<String?> takePhotoFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return photo == null ? null : persistMediaFile(photo);
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
      return null;
    }
  }

  static Future<String?> pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return photo == null ? null : persistMediaFile(photo);
    } catch (e) {
      debugPrint('Erro ao escolher foto: $e');
      return null;
    }
  }

  static Future<String?> pickFile({List<String>? allowedExtensions}) async {
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
      return persistMediaFile(File(path));
    } catch (e) {
      debugPrint('Erro ao escolher arquivo: $e');
      return null;
    }
  }

  static Future<String?> pickMultiplePhotos() async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      final savedPaths = <String>[];
      for (final photo in photos) {
        final savedPath = await persistMediaFile(photo);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }
      return savedPaths.isEmpty ? null : savedPaths.join('|');
    } catch (e) {
      debugPrint('Erro ao escolher múltiplas fotos: $e');
      return null;
    }
  }

  static Future<String?> persistMediaFile(
    dynamic mediaFile, {
    String subFolder = 'uploads',
  }) async {
    if (mediaFile is String) {
      if (mediaFile.startsWith('data:')) {
        return mediaFile;
      }
      return persistFile(File(mediaFile), subFolder: subFolder);
    }

    if (mediaFile is XFile) {
      if (kIsWeb) {
        final bytes = await mediaFile.readAsBytes();
        final mimeType = _guessMimeType(mediaFile.name);
        return 'data:$mimeType;base64,${base64Encode(bytes)}';
      }

      return persistFile(File(mediaFile.path), subFolder: subFolder);
    }

    if (mediaFile is File) {
      return persistFile(mediaFile, subFolder: subFolder);
    }

    return null;
  }

  static Future<String?> persistFile(
    File file, {
    String subFolder = 'uploads',
  }) async {
    try {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final mimeType = _guessMimeType(file.path);
        return 'data:$mimeType;base64,${base64Encode(bytes)}';
      }

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

  static String _guessMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'application/octet-stream';
    }
  }

  static String getFileName(File file) {
    return file.path.split('/').last;
  }

  static double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  static bool isImage(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  static bool isPDF(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ext == 'pdf';
  }
}
