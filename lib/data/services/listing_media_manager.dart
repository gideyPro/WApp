import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/listing_form_data.dart';

class ListingMediaManager {
  ListingMediaManager._();

  static String? _baseDir;

  static Future<String> _getBaseDir() async {
    if (_baseDir == null) {
      final appDir = await getApplicationDocumentsDirectory();
      _baseDir = '${appDir.path}/listing_media';
      await Directory(_baseDir!).create(recursive: true);
    }
    return _baseDir!;
  }

  static Future<XFile> persistFile(XFile file) async {
    final baseDir = await _getBaseDir();
    final ext = _extension(file.path);
    final destPath =
        '$baseDir/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(file.path).copy(destPath);
    return XFile(destPath);
  }

  static Future<List<XFile>> persistFiles(List<XFile> files) async {
    final results = <XFile>[];
    for (final f in files) {
      results.add(await persistFile(f));
    }
    return results;
  }

  static Future<void> cleanFormDataFiles(ListingFormData formData) async {
    final futures = <Future<void>>[];
    for (final file in formData.images) {
      futures.add(_deleteIfExists(file.path));
    }
    if (formData.sitePlan != null) {
      futures.add(_deleteIfExists(formData.sitePlan!.path));
    }
    if (formData.ownershipProof != null) {
      futures.add(_deleteIfExists(formData.ownershipProof!.path));
    }
    if (formData.videoFile != null) {
      futures.add(_deleteIfExists(formData.videoFile!.path));
    }
    await Future.wait(futures);
  }

  static Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String _extension(String path) {
    final dot = path.lastIndexOf('.');
    return dot >= 0 ? path.substring(dot + 1) : '';
  }
}
