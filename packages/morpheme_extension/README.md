# Morpheme Extension

Fork and modify from [dartx](https://pub.dev/packages/dartx) and export package [time](https://pub.dev/packages/time).

## Scope Functions

### .run

Calls the specified function [block] with [it] value as its receiver and returns its result.

```dart
String? getValue() => '1';
final value = getValue();

value?.run((it) => doSomething(it));
```

### .let

Calls the specified function [block] with [it] value as its argument and returns its result.

```dart
String? getValue() => '1';
final value = getValue();
final let = value?.let((it) => int.parse(it)); // 1 (int)
```

### .also

Calls the specified function [block] with [it] value as its argument and returns `block` value.

```dart
String? getValue() => '1';
final value = getValue();
int itValue = 0;
final also = value?.also((it) {
    itValue = int.parse(it);
});

print(also);        // 1 (String)
print(itValue);     // 1 (int)
```

### .takeIf

Returns [T] value if it satisfies the given [predicate] or `null`, if it doesn't.

```dart
final a = 10.takeIf((it) => it % 2 == 0); // 10
final b = 9.takeIf((it) => it % 2 == 0); // null
```

### .takeUnless

Returns [T] value if it _does not_ satisfy the given [predicate] or `null`, if it does.

```dart
final value = 10.takeUnless((it) => it % 2 == 0); // null
final value = 9.takeUnless((it) => it % 2 == 0); // 9
```

## int

### .plus

Return int this plus with [value].

```dart
final a = 1.plus(1);  // 2
final b = 200.plus(50);  // 250
```

### .minus

Return int this minus with [value].

```dart
final a = 1.minus(1);  // 0
final b = 200.minus(50);  // 150
```

### .ordinal

Returns an ordinal number of `String` type for any integer

```dart
final a = 1.ordinal();  // 1st
final b = 108.ordinal();  // 108th
```

## double

### .plus

Return double this plus with [value].

```dart
final a = 1.0.plus(1.5);  // 2.5
final b = 200.5.plus(50.5);  // 251.0
```

### .minus

Return double this minus with [value].

```dart
final a = 1.5.minus(1.0);  // 0.5
final b = 200.5.minus(50.5);  // 150
```

## String

### .isEmail

Return boolean checks whether the `String` is a valid email.

```dart
final isEmail = 'example@gmail.com'.isEmail; // true
final isNotEmail = 'example@'.isEmail; // false
```

### .capitalize

Returns a copy of the string having its first letter uppercased, or the original string, if it's empty or already starts with an upper case letter.

```dart
final word = 'abcd'.capitalize(); // Abcd
final anotherWord = 'Abcd'.capitalize(); // Abcd
```

### .decapitalize

Returns a copy of the string having its first letter lowercased, or the original string, if it's empty or already starts with a lower case letter.

```dart
final word = 'abcd'.decapitalize(); // abcd
final anotherWord = 'Abcd'.decapitalize(); // abcd
```

### .isBlank

Returns `true` if this string is empty or consists solely of whitespace characters.

```dart
final notBlank = '   .'.isBlank; // false
final blank = '  '.isBlank; // true
```

### .isDouble

Returns `true` if the string can be parsed as a double.

```dart
final a = ''.isDouble; // false
final b = 'a'.isDouble; // false
final c = '1'.isDouble; // true
final d = '1.0'.isDouble; // true
final e = '123456789.987654321'.isDouble; // true
final f = '1,000'.isDouble; // false
```

### .isInt

Returns `true` if the string can be parsed as an integer.

```dart
final a = ''.isInt; // false
final b = 'a'.isInt; // false
final c = '1'.isInt; // true
final d = '1.0'.isInt; // false
final e = '1,000'.isInt; // false
```

### .isLowerCase

Returns `true` if the entire string is lower case.

```dart
final a = 'abc'.isLowerCase; // true
final b = 'abC'.isLowerCase; // false
final c = '   '.isLowerCase; // true
final d = ''.isLowerCase; // false
```

### .isNotBlank

Returns `true` if this string is not empty and contains characters except whitespace characters.

```dart
final blank = '  '.isNotBlank; // false
final notBlank = '   .'.isNotBlank; // true
```

### .isNullOrEmpty

Returns `true` if the String is either `null` or empty.

```dart
final isNull = null.isNullOrEmpty; // true
final isEmpty = ''.isNullOrEmpty; // true
final isBlank = ' '.isNullOrEmpty; // false
final isLineBreak = '\n'.isNullOrEmpty; // false
```

### .isNotNullOrEmpty

Returns `true` if the String is neither `null` nor empty.

```dart
final isNull = null.isNullOrEmpty; // true
final isEmpty = ''.isNullOrEmpty; // true
final isBlank = ' '.isNullOrEmpty; // false
final isLineBreak = '\n'.isNullOrEmpty; // false
```

### .isNullOrBlank

Returns `true` if the String is either `null` or blank.

```dart
final isNull = null.isNullOrBlank; // true
final isEmpty = ''.isNullOrBlank; // true
final isBlank = ' '.isNullOrBlank; // true
final isLineBreak = '\n'.isNullOrBlank; // true
final isFoo = ' foo '.isNullOrBlank; // false
```

### .isNotNullOrBlank

Returns `true` if the String is neither `null` nor blank.

```dart
final isNull = null.isNullOrBlank; // true
final isEmpty = ''.isNullOrBlank; // true
final isBlank = ' '.isNullOrBlank; // true
final isLineBreak = '\n'.isNullOrBlank; // true
final isFoo = ' foo '.isNullOrBlank; // true
```

### .isUpperCase

Returns `true` if the entire string is upper case.

```dart
final a = 'ABC'.isUpperCase; // true
final b = 'ABc'.isUpperCase; // false
final c = '   '.isUpperCase; // true
final d = ''.isUpperCase; // false
```

### .urlEncode

Translates a string into application/x-www-form-urlencoded format using a specific encoding scheme.

```dart
const originalUrl = 'Hello Ladies + Gentlemen, a signed OAuth request!';
final encodedUrl = originalUrl.urlEncode;
// 'Hello%20Ladies%20+%20Gentlemen,%20a%20signed%20OAuth%20request!'
```

### .urlDecode

Decodes an application/x-www-form-urlencoded string using a specific encoding scheme.

```dart
const encodedUrl = 'Hello%20Ladies%20+%20Gentlemen,%20a%20signed%20OAuth%20request!';
final decodedUrl = encodingUrl.urlDecode;
// 'Hello Ladies + Gentlemen, a signed OAuth request!'
```

### .slice()

Returns a new substring containing all characters including indices [start] and [end].
If [end] is omitted, it is being set to `lastIndex`.

```dart
final sliceOne = 'awesomeString'.slice(0,6)); // awesome
final sliceTwo = 'awesomeString'.slice(7)); // String
```

### .toDoubleOrNull()

Parses the string as a `double` and returns the result or `null` if the String is not a valid representation of a number.

```dart
final numOne = '1'.toDoubleOrNull(); // 1.0
final numTwo = '1.2'.toDoubleOrNull(); // 1.2
final blank = ''.toDoubleOrNull(); // null
```

### .toInt()

Parses the string as an integer and returns the result. The radix (base) thereby defaults to 10. Throws a `FormatException` if parsing fails.

```dart
final a = '1'.toInt(); // 1
final b = '100'.toInt(radix: 2); // 4
final c = '100'.toInt(radix: 16); // 256
final d = '1.0'.toInt(); // throws FormatException
```

### .toIntOrNull()

Parses the string as an integer or returns `null` if it is not a number.

```dart
final number = '12345'.toIntOrNull(); // 12345
final notANumber = '123-45'.toIntOrNull(); // null
```

### .toUtf8()

Converts String to UTF-8 encoding.

```dart
final emptyString = ''.toUtf8(); // []
final hi = 'hi'.toUtf8(); // [104, 105]
final emoji = '😄'.toUtf8(); // [240, 159, 152, 132]

```

### .toUtf16()

Converts String to UTF-16 encoding.

```dart
final emptyString = ''.toUtf16(); // []
final hi = 'hi'.toUtf16(); // [104, 105]
final emoji = '😄'.toUtf16(); // [55357, 56836]
```

### .orEmpty()

Returns the string if it is not `null`, or the empty string otherwise.

```dart
String? nullableStr;
final str = nullableStr.orEmpty(); // ''
```

### .matches()

Returns `true` if this char sequence matches the given regular expression.

```dart
print('as'.matches(RegExp('^.s\$'))) // true
print('mst'.matches(RegExp('^.s\$'))) // false
```

## Iterable Num

### .sum

Return int this plus with [value].

```dart
final a = [50, 10, 40].sum();  // 100
```

### .average

Return int this plus with [value].

```dart
final a = [50, 10].average();  // 30.0
```

### .median

Return int this plus with [value].

```dart
final a = [1, 2, 3, 4, 5].median();  // 3
final b = [5, 4, 3, 2, 1].median();  // 3
```

### Time utils

Morpheme extension exports [@jogboms](https://github.com/jogboms) great [⏰ time.dart](https://github.com/jogboms/time.dart) package so you can do the following:

```dart
int secondsInADay = 1.days.inSeconds;

Duration totalTime = [12.5.seconds, 101.milliseconds, 2.5.minutes].sum();

DateTime oneWeekLater = DateTime.now() + 1.week;
```

Check out [⏰ time.dart](https://github.com/jogboms/time.dart) for more information and examples.
