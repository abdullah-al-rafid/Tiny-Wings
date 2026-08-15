import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/organization_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageServiceProvider);
  return OrganizationRepository(firestore, storage);
});

/// REPOSITORY PATTERN
/// This class acts as a 'Single Source of Truth' for Organization data.
/// It abstracts the complexities of Firebase Firestore and Storage SDKs, 
/// providing a clean interface for the rest of the application.
class OrganizationRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storage;

  OrganizationRepository(this._firestore, this._storage);

  /// Fetches all organizations from the 'organizations' collection in Firestore.
  Future<List<Organization>> getOrganizations() async {
    final snapshot = await _firestore.collection('organizations').get();
    return snapshot.docs.map((doc) => Organization.fromJson(doc.id, doc.data())).toList();
  }

  /// Streams all organizations from Firestore for real-time updates.
  Stream<List<Organization>> watchOrganizations() {
    return _firestore.collection('organizations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Organization.fromJson(doc.id, doc.data())).toList();
    });
  }

  Future<Organization?> getOrganizationById(String id) async {
    final doc = await _firestore.collection('organizations').doc(id).get();
    if (!doc.exists) return null;
    return Organization.fromJson(doc.id, doc.data()!);
  }

  Future<void> saveOrganization(Organization organization) async {
    await _firestore.collection('organizations').doc(organization.id).set(organization.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteOrganization(String id) async {
    await _firestore.collection('organizations').doc(id).delete();
  }

  Future<String> uploadOrganizationCover(String orgId, List<int> bytes, String extension) async {
    final mimeType = (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') 
        ? 'image/jpeg' 
        : 'image/${extension.toLowerCase()}';
    
    try {
      return await _storage.uploadImage(
        path: 'organizations/$orgId/cover.$extension',
        bytes: Uint8List.fromList(bytes),
        mimeType: mimeType,
      );
    } catch (e) {
      final base64String = base64Encode(bytes);
      return 'data:$mimeType;base64,$base64String';
    }
  }

  Future<void> deleteAllOrganizations() async {
    final snapshot = await _firestore.collection('organizations').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
