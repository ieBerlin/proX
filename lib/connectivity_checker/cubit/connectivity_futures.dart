import 'package:http/http.dart' as http;

Future<bool> booleanFuture() async {
  var url = Uri.parse('https://www.google.com');

  await http.get(url).timeout(const Duration(seconds: 6), onTimeout: () {
    throw Exception();
  });

  return true;
}
