import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_repository.dart';

final firebaseClientProvider = Provider<FirebaseClient>((ref) {
  return FirebaseClient(ref);
});

class FirebaseClient {
  final Ref _ref;
  final String _baseUrl = 'https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app';

  FirebaseClient(this._ref);

  String? get token => _ref.read(authModelProvider)?.token;

  String _buildUrl(String path) {
    // Ensure path starts with / and ends with .json
    final sanitizedPath = path.startsWith('/') ? path : '/$path';
    final jsonPath = sanitizedPath.endsWith('.json') ? sanitizedPath : '$sanitizedPath.json';
    
    var url = '$_baseUrl$jsonPath';
    
    // Add auth token if available
    final authData = _ref.read(authModelProvider);
    if (authData != null) {
      url += '?auth=${authData.token}';
    }
    
    return url;
  }

  Future<http.Response> get(String path) async {
    final url = Uri.parse(_buildUrl(path));
    final response = await http.get(url);
    return _handleResponse(response);
  }

  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final url = Uri.parse(_buildUrl(path));
    final response = await http.post(
      url,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<http.Response> put(String path, Map<String, dynamic> data) async {
    final url = Uri.parse(_buildUrl(path));
    final response = await http.put(
      url,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<http.Response> patch(String path, Map<String, dynamic> data) async {
    final url = Uri.parse(_buildUrl(path));
    final response = await http.patch(
      url,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path) async {
    final url = Uri.parse(_buildUrl(path));
    final response = await http.delete(url);
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      final body = json.decode(response.body);
      throw body['error'] ?? 'An error occurred during the HTTP request';
    }
  }
}
