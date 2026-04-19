import 'dart:convert';
import '../../../core/api/firebase_client.dart';
import '../../../models/organization_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final client = ref.watch(firebaseClientProvider);
  return OrganizationRepository(client);
});

class OrganizationRepository {
  final FirebaseClient _client;

  OrganizationRepository(this._client);

  Future<List<Organization>> getOrganizations() async {
    final response = await _client.get('organizations');
    
    if (response.body == 'null') return [];

    final Map<String, dynamic> data = json.decode(response.body);
    final List<Organization> organizations = [];

    data.forEach((id, orgData) {
      organizations.add(Organization.fromJson(id, orgData));
    });

    return organizations;
  }

  Future<Organization?> getOrganizationById(String id) async {
    final response = await _client.get('organizations/$id');
    
    if (response.body == 'null') return null;

    final Map<String, dynamic> data = json.decode(response.body);
    return Organization.fromJson(id, data);
  }

  Future<void> saveOrganization(Organization organization) async {
    await _client.put('organizations/${organization.id}', organization.toJson());
  }

  Future<String> uploadOrganizationCover(String orgId, List<int> bytes, String extension) async {
    final base64String = base64Encode(bytes);
    final mimeType = (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') 
        ? 'image/jpeg' 
        : 'image/${extension.toLowerCase()}';
    
    return 'data:$mimeType;base64,$base64String';
  }
}
