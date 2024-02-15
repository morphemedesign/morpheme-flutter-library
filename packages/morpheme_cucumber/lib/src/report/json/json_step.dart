import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'json_match.dart';
import 'json_result.dart';

class JsonStep extends Equatable {
  JsonStep({
    required this.name,
    required this.line,
    required this.keyword,
    required this.match,
    required this.result,
  });

  final String name;
  final int line;
  final String keyword;
  final JsonMatch match;
  final JsonResult result;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'line': line,
      'keyword': keyword,
      'match': match.toMap(),
      'result': result.toMap(),
    };
  }

  factory JsonStep.fromMap(Map<String, dynamic> map) {
    return JsonStep(
      name: map['name'] ?? '',
      line: map['line']?.toInt() ?? 0,
      keyword: map['keyword'] ?? '',
      match: JsonMatch.fromMap(map['match']),
      result: JsonResult.fromMap(map['result']),
    );
  }

  String toJson() => json.encode(toMap());

  factory JsonStep.fromJson(String source) =>
      JsonStep.fromMap(json.decode(source));

  JsonStep copyWith({
    String? name,
    int? line,
    String? keyword,
    JsonMatch? match,
    JsonResult? result,
  }) {
    return JsonStep(
      name: name ?? this.name,
      line: line ?? this.line,
      keyword: keyword ?? this.keyword,
      match: match ?? this.match,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props {
    return [
      name,
      line,
      keyword,
      match,
      result,
    ];
  }
}
