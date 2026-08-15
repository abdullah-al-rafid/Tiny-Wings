import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final bucket = "tinywings-51743.appspot.com";
  final encodedFileName = Uri.encodeComponent("test_folder/test.jpg");
  final url = "https://firebasestorage.googleapis.com/v0/b/$bucket/o?name=$encodedFileName";
  
  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "image/jpeg"},
    body: [0,0,0,0],
  );
  print("Status: ${response.statusCode}");
  print(response.body);
}
