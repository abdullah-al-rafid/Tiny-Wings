import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageServiceProvider);
  return UserRepository(firestore, storage);
});

class UserRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storage;

  UserRepository(this._firestore, this._storage);

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(uid, doc.data()!);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(uid, doc.data()!);
    });
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.id, doc.data())).toList();
  }

  Stream<List<UserModel>> watchAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.id, doc.data())).toList();
    });
  }

  Future<void> saveUserProfile(UserModel user) async {
    // SECURITY: Maintain existing role unless specifically changed by authorized action
    UserModel userToSave = user;
    
    // Fetch current profile to check existing role
    final currentProfile = await getUserProfile(user.uid);
    
    if (user.email == 'admin@gmail.com') {
      userToSave = user.copyWith(role: UserRole.admin);
    } else if (currentProfile != null) {
      // Preserve existing role during profile updates
      userToSave = user.copyWith(role: currentProfile.role);
    }
    
    await _firestore.collection('users').doc(userToSave.uid).set(userToSave.toJson(), SetOptions(merge: true));
  }

  Future<void> setUserPhoneMapping(String phone, String email) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    await _firestore.collection('phone_to_email').doc(sanitizedPhone).set({'email': email});
  }

  Future<String?> getEmailByPhone(String phone) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final doc = await _firestore.collection('phone_to_email').doc(sanitizedPhone).get();
    if (!doc.exists) return null;
    return doc.data()?['email'];
  }

  Future<String> uploadProfilePicture(String uid, List<int> bytes, String extension) async {
    final mimeType = (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') 
        ? 'image/jpeg' 
        : 'image/${extension.toLowerCase()}';
    
    try {
      return await _storage.uploadImage(
        path: 'users/$uid/profile.$extension',
        bytes: Uint8List.fromList(bytes),
        mimeType: mimeType,
      );
    } catch (e) {
      final base64String = base64Encode(bytes);
      return 'data:$mimeType;base64,$base64String';
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _firestore.collection('users').doc(uid).update({'status': status});
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({'role': role.name});
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<void> updateProfile(UserModel user) async {
    await saveUserProfile(user);
  }
}
