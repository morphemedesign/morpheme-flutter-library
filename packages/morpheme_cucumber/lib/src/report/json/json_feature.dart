import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'json_scenario.dart';
import 'json_tag.dart';

class JsonFeature extends Equatable {
  JsonFeature({
    required this.uri,
    required this.name,
    required this.description,
    required this.line,
    required this.id,
    required this.tags,
    required this.elements,
    required this.keyword,
  });

  final String uri;
  final String name;
  final String description;
  final int line;
  final String id;
  final List<JsonTag> tags;
  final List<JsonScenario> elements;
  final String keyword;

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'name': name,
      'description': description,
      'line': line,
      'id': id,
      'tags': tags.map((x) => x.toMap()).toList(),
      'elements': elements.map((x) => x.toMap()).toList(),
      'keyword': keyword,
    };
  }

  factory JsonFeature.fromMap(Map<String, dynamic> map) {
    return JsonFeature(
      uri: map['uri'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      line: map['line']?.toInt() ?? 0,
      id: map['id'] ?? '',
      tags: List<JsonTag>.from(map['tags']?.map((x) => JsonTag.fromMap(x))),
      elements: List<JsonScenario>.from(
          map['elements']?.map((x) => JsonScenario.fromMap(x))),
      keyword: map['keyword'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory JsonFeature.fromJson(String source) =>
      JsonFeature.fromMap(json.decode(source));

  JsonFeature copyWith({
    String? uri,
    String? name,
    String? description,
    int? line,
    String? id,
    List<JsonTag>? tags,
    List<JsonScenario>? elements,
    String? keyword,
  }) {
    return JsonFeature(
      uri: uri ?? this.uri,
      name: name ?? this.name,
      description: description ?? this.description,
      line: line ?? this.line,
      id: id ?? this.id,
      tags: tags ?? this.tags,
      elements: elements ?? this.elements,
      keyword: keyword ?? this.keyword,
    );
  }

  @override
  List<Object?> get props {
    return [
      uri,
      name,
      description,
      line,
      id,
      tags,
      elements,
      keyword,
    ];
  }
}
