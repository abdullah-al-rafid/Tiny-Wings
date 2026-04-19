import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authModelProvider = StateProvider<AuthModel?>((ref) => null);

class AuthModel {
  final String token;
  final String uid;
  final String email;

  AuthModel({required this.token, required this.uid, required this.email});
}

final profileSetupDataProvider = StateProvider<Map<String, String>?>((ref) => null);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  final Ref ref;
  final String _apiKey = 'AIzaSyAV3NmZBbAIdlDvfKFS1VOQuEEW4eQDixI';

  AuthRepository(this.ref);

  Future<AuthModel?> signInWithEmailAndPassword(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey');
    
    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw responseData['error']['message'];
    }

    final authModel = AuthModel(
      token: responseData['idToken'],
      uid: responseData['localId'],
      email: responseData['email'],
    );
    ref.read(authModelProvider.notifier).state = authModel;
    return authModel;
  }

  Future<AuthModel?> createUserWithEmailAndPassword(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey');
    
    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw responseData['error']['message'];
    }

    final authModel = AuthModel(
      token: responseData['idToken'],
      uid: responseData['localId'],
      email: responseData['email'],
    );
    ref.read(authModelProvider.notifier).state = authModel;
    return authModel;
  }

  Future<void> updatePassword(String newPassword) async {
    final authData = ref.read(authModelProvider);
    if (authData == null) throw 'User not authenticated';

    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:update?key=$_apiKey');
    
    final response = await http.post(
      url,
      body: json.encode({
        'idToken': authData.token,
        'password': newPassword,
        'returnSecureToken': true,
      }),
    );

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw responseData['error']['message'];
    }

    // Update local state with new token if returned
    if (responseData['idToken'] != null) {
      final updatedModel = AuthModel(
        token: responseData['idToken'],
        uid: responseData['localId'],
        email: responseData['email'],
      );
      ref.read(authModelProvider.notifier).state = updatedModel;
    }
  }

  void signOut() {
    ref.read(authModelProvider.notifier).state = null;
  }
}


