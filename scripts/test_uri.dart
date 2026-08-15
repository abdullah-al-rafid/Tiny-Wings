void main() {
  var uri = Uri.parse('http://example.com/a%2Fb');
  print(uri.toString());
}
