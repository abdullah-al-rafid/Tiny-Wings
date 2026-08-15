import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String path,
    Uint8List? bytes,
    String? mimeType,
  }) async {
    final ref = _storage.ref().child(path);
    
    if (bytes == null) {
      throw ArgumentError('Bytes must be provided');
    }

    final task = ref.putData(bytes, SettableMetadata(contentType: mimeType));
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    if (!url.startsWith('https://firebasestorage.googleapis.com')) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore errors if image doesn't exist or is not a storage URL
    }
  }
}
