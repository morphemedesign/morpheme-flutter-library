import 'package:flutter_test/flutter_test.dart';
import 'package:morpheme_extension/morpheme_extension.dart';

void main() {
  String? getValue() => '1';
  String? getValueNull() => null;

  group('Scope functions run test.', () {
    test('Should count call zero for null value.', () {
      int count = 0;
      final value = getValueNull();
      value?.run((it) => count++);
      expect(count, 0);
    });

    test('Should count call once for non nullable.', () {
      int count = 0;
      final value = getValue();
      value?.run((it) => count++);
      expect(count, 1);
    });
  });

  group('Scope functions let test.', () {
    test('Should let value is null.', () {
      final nullable = getValueNull();
      final let = nullable?.let((it) => int.parse(it));
      expect(let, isNull);
    });

    test('Should let value is number 1.', () {
      final value = getValue();
      final let = value?.let((it) => int.parse(it));
      expect(let, 1);
    });
  });

  group('Scope functions also test.', () {
    test('Should also value is null and count is zero.', () {
      int itValue = 0;
      final value = getValueNull();
      final also = value?.also((it) {
        itValue = int.parse(it);
      });
      expect(also, isNull);
      expect(itValue, 0);
    });

    test('Should also value is "1" and itValue is 1.', () {
      int itValue = 0;
      final value = getValue();
      final also = value?.also((it) {
        itValue = int.parse(it);
      });
      expect(also, '1');
      expect(itValue, 1);
    });
  });

  group('Scope functions takeIf test.', () {
    test('Should return value 10.', () {
      final value = 10.takeIf((it) => it % 2 == 0);
      expect(value, 10);
    });
    test('Should return value null.', () {
      final value = 9.takeIf((it) => it % 2 == 0);
      expect(value, isNull);
    });
  });

  group('Scope functions takeUnless test.', () {
    test('Should return value 10.', () {
      final value = 10.takeUnless((it) => it % 2 == 0);
      expect(value, isNull);
    });
    test('Should return value null.', () {
      final value = 9.takeUnless((it) => it % 2 == 0);
      expect(value, 9);
    });
  });
}
