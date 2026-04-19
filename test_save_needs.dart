import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app/needs.json');
  final response = await http.post(url, body: json.encode({
    'organizationId': '123',
    'title': 'Test Need',
    'status': 'approved',
    'category': 'Food'
  }));
  print(response.statusCode);
  print(response.body);
}
