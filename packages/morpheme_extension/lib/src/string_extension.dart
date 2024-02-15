import 'dart:convert';

extension GEStringExtension on String {
  /// Checks whether the `String` is a valid mail.
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(this);

  /// Checks whether the `String` is a valid url.
  bool get isUrl =>
      RegExp(r'^http[s]?:\/\/\w+(\.\w+)*(:[0-9]+)?\/?(\/[.\S]*)*$')
          .hasMatch(this);

  /// Returns a copy of this string having its first letter uppercased, or the
  /// original string, if it's empty or already starts with an upper case
  /// letter.
  ///
  /// ```dart
  /// print('abcd'.capitalize()) // Abcd
  /// print('Abcd'.capitalize()) // Abcd
  /// ```
  String capitalize() {
    switch (length) {
      case 0:
        return this;
      case 1:
        return toUpperCase();
      default:
        return substring(0, 1).toUpperCase() + substring(1);
    }
  }

  /// Returns a copy of this string having its first letter lowercased, or the
  /// original string, if it's empty or already starts with a lower case letter.
  ///
  /// ```dart
  /// print('abcd'.decapitalize()) // abcd
  /// print('Abcd'.decapitalize()) // abcd
  /// ```
  String decapitalize() {
    switch (length) {
      case 0:
        return this;
      case 1:
        return toLowerCase();
      default:
        return substring(0, 1).toLowerCase() + substring(1);
    }
  }

  /// Returns `true` if this string is empty or consists solely of whitespace
  /// characters.
  bool get isBlank => trimLeft().isEmpty;

  /// Returns `true` if this char sequence is not empty and contains some
  /// characters except of whitespace characters.
  bool get isNotBlank => !isBlank;

  /// Returns `true` if the whole string is upper case.
  ///
  /// ```dart
  /// 'HI'.isUpperCase // true
  /// 'Hi'.isUpperCase // false
  /// '!'.isUpperCase // false
  /// 'HEY, YOU!'.isUpperCase // true
  /// ```
  bool get isUpperCase => this == toUpperCase() && this != toLowerCase();

  /// Returns `true` if the first character is lower case.
  bool get isDecapitalized => isNotEmpty && this[0].isLowerCase;

  /// Returns `true` if the whole string is lower case.
  ///
  /// ```dart
  /// 'hi'.isLowerCase // true
  /// 'Hi'.isLowerCase // false
  /// '!'.isLowerCase // false
  /// 'hey, you!'.isLowerCase // true
  /// ```
  bool get isLowerCase => this == toLowerCase() && this != toUpperCase();

  /// Returns `true` if the first character is upper case.
  bool get isCapitalized => isNotEmpty && this[0].isUpperCase;

  /// Returns `true` if the string can be parsed as an integer.
  bool get isInt => toIntOrNull() != null;

  /// Parses the string as an [int] number and returns the result.
  ///
  /// The [radix] must be in the range 2..36. The dimorpheme used are
  /// first the decimal dimorpheme 0..9, and then the letters 'a'..'z' with
  /// values 10 through 35. Also accepts upper-case letters with the same
  /// values as the lower-case ones.
  ///
  /// If no [radix] is given then it defaults to 10.
  int toInt({int? radix}) => int.parse(this, radix: radix);

  /// Parses the string as an [int] number and returns the result or `null` if
  /// the string is not a valid representation of a number.
  ///
  /// The [radix] must be in the range 2..36. The dimorpheme used are
  /// first the decimal dimorpheme 0..9, and then the letters 'a'..'z' with
  /// values 10 through 35. Also accepts upper-case letters with the same
  /// values as the lower-case ones.
  ///
  /// If no [radix] is given then it defaults to 10.
  int? toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// Returns `true` if the string can be parsed as a `double`.
  bool get isDouble => toDoubleOrNull() != null;

  /// Parses the string as a [double] number and returns the result.
  double toDouble() => double.parse(this);

  /// Parses the string as a [double] number and returns the result or `null`
  /// if the String is not a valid representation of a number.
  double? toDoubleOrNull() => double.tryParse(this);

  /// Encodes String as UTF-8.
  List<int> toUtf8() => utf8.encode(this);

  /// Encodes String as UTF-16.
  List<int> toUtf16() => codeUnits;

  /// Returns a new substring containing all characters between [start]
  /// (inclusive) and [end] (inclusive).
  /// If [end] is omitted, it is being set to `lastIndex`.
  ///
  ///  ```dart
  /// print('awesomeString'.slice(0,6)); // awesome
  /// print('awesomeString'.slice(7)); // String
  /// ```
  String slice(int start, [int end = -1]) {
    final startRange = start < 0 ? start + length : start;
    final endRange = end < 0 ? end + length : end;

    RangeError.checkValidRange(startRange, endRange, length);

    return substring(startRange, endRange + 1);
  }

  /// Returns `true` if this char sequence matches the given regular expression.
  bool matches(RegExp regex) => regex.hasMatch(this);

  /// Translates a string into application/x-www-form-urlencoded format using a specific encoding scheme.
  String get urlEncode => Uri.encodeFull(this);

  /// Decodes an application/x-www-form-urlencoded string using a specific encoding scheme.
  String get urlDecode => Uri.decodeFull(this);
}

extension GEStringNullExtension on String? {
  /// Returns `true` if the string is either `null` or empty.
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  /// Returns `true` if the string is neither null nor empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns `true` if the string is either `null` or blank.
  bool get isNullOrBlank => this?.isBlank ?? true;

  /// Returns `true` if the string is neither null nor blank.
  bool get isNotNullOrBlank => !isNullOrBlank;

  /// Returns the string if it is not `null`, or the empty string otherwise.
  String orEmpty() => this ?? '';
}
