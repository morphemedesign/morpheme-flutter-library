import 'dart:convert';

import 'package:equatable/equatable.dart';

class JsonTag extends Equatable {
  JsonTag({
    required this.name,
    required this.line,
  });

  final String name;
  final int line;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'line': line,
    };
  }

  factory JsonTag.fromMap(Map<String, dynamic> map) {
    return JsonTag(
      name: map['name'] ?? '',
      line: map['line'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory JsonTag.fromJson(String source) =>
      JsonTag.fromMap(json.decode(source));

  JsonTag copyWith({
    String? name,
    int? line,
  }) {
    return JsonTag(
      name: name ?? this.name,
      line: line ?? this.line,
    );
  }

  @override
  List<Object?> get props => [name, line];
}
