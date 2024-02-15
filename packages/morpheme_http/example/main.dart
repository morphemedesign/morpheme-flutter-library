// ignore_for_file: avoid_print

import 'package:morpheme_http/morpheme_http.dart';

void main(List<String> args) async {
  final http = MorphemeHttp();

  try {
    final response = await http.post(
      Uri.parse('https://reqres.in/api/login'),
      body: {"email": "eve.holt@reqres.in", "password": "cityslicka"},
    );
    print(response.body);
  } on MorphemeException catch (e) {
    final failure = e.toMorphemeFailure();
    print(failure.toString());
  } catch (e) {
    print(e.toString());
  }
}
