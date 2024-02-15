import 'dart:convert';

import 'package:equatable/equatable.dart';

class Pickle extends Equatable {
  const Pickle({
    required this.pickle,
  });

  final DataPickle? pickle;

  Map<String, dynamic> toMap() {
    return {
      'pickle': pickle?.toMap(),
    };
  }

  factory Pickle.fromMap(Map<String, dynamic> map) {
    return Pickle(
      pickle: map['pickle'] == null ? null : DataPickle.fromMap(map['pickle']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pickle.fromJson(String source) => Pickle.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        pickle,
      ];
}

class DataPickle extends Equatable {
  const DataPickle({
    required this.id,
    required this.uri,
    required this.name,
    required this.language,
    required this.steps,
    required this.tags,
    required this.astNodeIds,
  });

  final String? id;
  final String? uri;
  final String? name;
  final String? language;
  final List<StepsPickle>? steps;
  final List<TagsPickle>? tags;
  final List<String>? astNodeIds;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uri': uri,
      'name': name,
      'language': language,
      'steps': steps?.map((e) => e.toMap()).toList(),
      'tags': tags?.map((e) => e.toMap()).toList(),
      'astNodeIds': astNodeIds,
    };
  }

  factory DataPickle.fromMap(Map<String, dynamic> map) {
    return DataPickle(
      id: map['id'],
      uri: map['uri'],
      name: map['name'],
      language: map['language'],
      steps: map['steps'] == null
          ? null
          : List.from(
              (map['steps'] as List).map((e) => StepsPickle.fromMap(e))),
      tags: map['tags'] == null
          ? null
          : List.from((map['tags'] as List).map((e) => TagsPickle.fromMap(e))),
      astNodeIds:
          map['astNodeIds'] == null ? null : List.from(map['astNodeIds']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DataPickle.fromJson(String source) =>
      DataPickle.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        id,
        uri,
        name,
        language,
        steps,
        tags,
        astNodeIds,
      ];
}

class StepsPickle extends Equatable {
  const StepsPickle({
    required this.astNodeIds,
    required this.id,
    required this.type,
    required this.text,
  });

  final List<String>? astNodeIds;
  final String? id;
  final String? type;
  final String? text;

  Map<String, dynamic> toMap() {
    return {
      'astNodeIds': astNodeIds,
      'id': id,
      'type': type,
      'text': text,
    };
  }

  factory StepsPickle.fromMap(Map<String, dynamic> map) {
    return StepsPickle(
      astNodeIds:
          map['astNodeIds'] == null ? null : List.from(map['astNodeIds']),
      id: map['id'],
      type: map['type'],
      text: map['text'],
    );
  }

  String toJson() => json.encode(toMap());

  factory StepsPickle.fromJson(String source) =>
      StepsPickle.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        astNodeIds,
        id,
        type,
        text,
      ];
}

class TagsPickle extends Equatable {
  const TagsPickle({
    required this.name,
    required this.astNodeId,
  });

  final String? name;
  final String? astNodeId;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'astNodeId': astNodeId,
    };
  }

  factory TagsPickle.fromMap(Map<String, dynamic> map) {
    return TagsPickle(
      name: map['name'],
      astNodeId: map['astNodeId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TagsPickle.fromJson(String source) =>
      TagsPickle.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        name,
        astNodeId,
      ];
}
