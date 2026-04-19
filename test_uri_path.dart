void main() {
  var uri = Uri.parse("http://ex.com/o/a%2Fb");
  print(uri.toString());
}
