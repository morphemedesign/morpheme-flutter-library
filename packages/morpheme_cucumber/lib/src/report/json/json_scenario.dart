import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'json_step.dart';
import 'json_tag.dart';

class JsonScenario extends Equatable {
  JsonScenario({
    required this.description,
    required this.id,
    required this.keyword,
    required this.line,
    required this.name,
    required this.type,
    required this.tags,
    required this.steps,
  });

  final String description;
  final String id;
  final String keyword;
  final int line;
  final String name;
  final String type;
  final List<JsonTag> tags;
  final List<JsonStep> steps;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'id': id,
      'keyword': keyword,
      'line': line,
      'name': name,
      'type': type,
      'tags': tags.map((x) => x.toMap()).toList(),
      'steps': steps.map((x) => x.toMap()).toList(),
    };
  }

  factory JsonScenario.fromMap(Map<String, dynamic> map) {
    return JsonScenario(
      description: map['description'] ?? '',
      id: map['id'] ?? '',
      keyword: map['keyword'] ?? '',
      line: map['line']?.toInt() ?? 0,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      tags: List<JsonTag>.from(map['tags']?.map((x) => JsonTag.fromMap(x))),
      steps: List<JsonStep>.from(map['steps']?.map((x) => JsonStep.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory JsonScenario.fromJson(String source) =>
      JsonScenario.fromMap(json.decode(source));

  JsonScenario copyWith({
    String? description,
    String? id,
    String? keyword,
    int? line,
    String? name,
    String? type,
    List<JsonTag>? tags,
    List<JsonStep>? steps,
  }) {
    return JsonScenario(
      description: description ?? this.description,
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      line: line ?? this.line,
      name: name ?? this.name,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      steps: steps ?? this.steps,
    );
  }

  @override
  List<Object?> get props {
    return [
      description,
      id,
      keyword,
      line,
      name,
      type,
      tags,
      steps,
    ];
  }
}
