import 'package:http/http.dart' as http;
void main() async {
  var url = "http://httpbin.org/post?uploadType=media&name=organization_covers%2Forg1.jpg";
  var uri = Uri.parse(url);
  var response = await http.post(uri, body: "test");print(response.body);
}
