import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://tinywings-51743-default-rtdb.asia-southeast1.firebasedatabase.app/needs.json');
  final response = await http.get(url);
  print(response.statusCode);
  print(response.body);
}
