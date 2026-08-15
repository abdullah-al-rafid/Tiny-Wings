import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app/organizations.json');
  final response = await http.get(url);
  if(response.body == "null") { print("No orgs"); return; }
  final data = json.decode(response.body) as Map<String, dynamic>;
  for (var org in data.values) {
    org.remove('imageUrl');
  }
  print(json.encode(data));
}
