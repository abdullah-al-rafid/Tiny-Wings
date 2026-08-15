void main() {
  var url = "http://httpbin.org/post?uploadType=media&name=organization_covers%2Forg1.jpg";
  var uri = Uri.parse(url);
  print("Parsed URL: ${uri.toString()}");
}
