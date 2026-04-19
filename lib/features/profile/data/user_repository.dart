import 'dart:convert';
import '../../../core/api/firebase_client.dart';
import '../../../models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(firebaseClientProvider);
  return UserRepository(client);
});

class UserRepository {
  final FirebaseClient _client;

  UserRepository(this._client);

  Future<UserModel?> getUserProfile(String uid) async {
    final response = await _client.get('users/$uid');
    
    if (response.body == 'null') return null;

    final Map<String, dynamic> data = json.decode(response.body);
    return UserModel.fromJson(uid, data);
  }

  Future<List<UserModel>> getAllUsers() async {
    final response = await _client.get('users');
    
    if (response.body == 'null') return [];

    final Map<String, dynamic> data = json.decode(response.body);
    final List<UserModel> users = [];

    data.forEach((uid, userData) {
      users.add(UserModel.fromJson(uid, userData));
    });

    return users;
  }

  Future<void> saveUserProfile(UserModel user) async {
    await _client.put('users/${user.uid}', user.toJson());
  }

  Future<void> setUserPhoneMapping(String phone, String email) async {
    // Sanitize phone number (remove +, spaces, etc. if needed, but keeping it simple for now)
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    await _client.put('phone_to_email/$sanitizedPhone', {'email': email});
  }

  Future<String?> getEmailByPhone(String phone) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final response = await _client.get('phone_to_email/$sanitizedPhone');
    
    if (response.body == 'null') return null;
    
    final data = json.decode(response.body);
    return data['email'];
  }

  Future<String> uploadProfilePicture(String uid, List<int> bytes, String extension) async {
    final base64String = base64Encode(bytes);
    final mimeType = (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') 
        ? 'image/jpeg' 
        : 'image/${extension.toLowerCase()}';
    
    return 'data:$mimeType;base64,$base64String';
  }
}
