void main() {
  var url = "http://example.com/o?name=a%2Fb";
  var uri = Uri.parse(url);
  print(uri.queryParameters['name']);
}
