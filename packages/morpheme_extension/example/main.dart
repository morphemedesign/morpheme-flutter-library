// ignore_for_file: avoid_print

import 'package:morpheme_extension/morpheme_extension.dart';

void main() {
  String? getValue() => '1';
  final value = getValue();

  value?.run((it) => print(it));
  final let = value?.let((it) => int.parse(it));
  print(let);

  int itValue = 0;
  final also = value?.also((it) {
    itValue = int.parse(it);
  });

  print(also);
  print(itValue);
}
