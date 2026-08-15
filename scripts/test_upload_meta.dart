import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  var url = "http://httpbin.org/post?uploadType=media&name=test.jpg";
  var response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "image/jpeg",
      "x-goog-meta-firebaseStorageDownloadTokens": "12345-67890-uuid"
    },
    body: [0,0,0,0],
  );
  print(response.body);
}
