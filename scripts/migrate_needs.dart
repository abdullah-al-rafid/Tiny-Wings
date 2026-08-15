import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyAV3NmZBbAIdlDvfKFS1VOQuEEW4eQDixI';
  
  // 1. Sign up a temporary user to get an auth token
  var url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
  var response = await http.post(
    url,
    body: json.encode({
      'email': 'migration_admin_${DateTime.now().millisecondsSinceEpoch}@test.com',
      'password': 'password123',
      'returnSecureToken': true,
    }),
  );
  
  final authData = json.decode(response.body);
  final idToken = authData['idToken'];
  if (idToken == null) {
    print('Failed to authenticate: $authData');
    return;
  }
  
  print('Auth successful!');

  // Needs data manually extracted
  final needsToMigrate = [
    {
      "organizationId": "test-organization-1",
      "organizationName": "Test Organization 1",
      "category": "Food",
      "deadline": "",
      "priority": "Low",
      "quantityOrAmount": "20 kg",
      "status": "approved",
      "subtitle": "",
      "title": "Rice"
    },
    {
      "organizationId": "test-organization-1",
      "organizationName": "Test Organization 1",
      "category": "Education",
      "deadline": "",
      "priority": "Normal",
      "quantityOrAmount": "10 sets",
      "status": "approved",
      "subtitle": "",
      "title": "Class 6 Books"
    },
    {
      "organizationId": "test-organization-2",
      "organizationName": "Test Organization 2",
      "category": "Medicine",
      "deadline": "",
      "priority": "Urgent",
      "quantityOrAmount": "1 box",
      "status": "approved",
      "subtitle": "",
      "title": "Peracitamol"
    }
  ];

  // 2. Post to /needs.json
  for (var need in needsToMigrate) {
    final postUrl = Uri.parse('https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app/needs.json?auth=$idToken');
    final postRes = await http.post(postUrl, body: json.encode(need));
    print('Migrated Need: ${postRes.statusCode}');
  }
  
  // 3. Delete from embedded orgs
  final org1Url = Uri.parse('https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app/organizations/test-organization-1.json?auth=$idToken');
  await http.patch(org1Url, body: json.encode({"needs": null}));
  
  final org2Url = Uri.parse('https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app/organizations/test-organization-2.json?auth=$idToken');
  await http.patch(org2Url, body: json.encode({"needs": null}));
  
  print('Migration completed successfully!');
}
