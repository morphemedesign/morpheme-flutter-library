import 'dart:convert';

import 'package:equatable/equatable.dart';

class GherkinDocument extends Equatable {
  const GherkinDocument({
    required this.gherkinDocument,
  });

  final DataGherkinDocument? gherkinDocument;

  Map<String, dynamic> toMap() {
    return {
      'gherkinDocument': gherkinDocument?.toMap(),
    };
  }

  factory GherkinDocument.fromMap(Map<String, dynamic> map) {
    return GherkinDocument(
      gherkinDocument: map['gherkinDocument'] == null
          ? null
          : DataGherkinDocument.fromMap(map['gherkinDocument']),
    );
  }

  String toJson() => json.encode(toMap());

  factory GherkinDocument.fromJson(String source) =>
      GherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        gherkinDocument,
      ];
}

class DataGherkinDocument extends Equatable {
  const DataGherkinDocument({
    required this.uri,
    required this.feature,
    required this.comments,
  });

  final String? uri;
  final FeatureGherkinDocument? feature;
  final List<dynamic>? comments;

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'feature': feature?.toMap(),
      'comments': comments,
    };
  }

  factory DataGherkinDocument.fromMap(Map<String, dynamic> map) {
    return DataGherkinDocument(
      uri: map['uri'],
      feature: map['feature'] == null
          ? null
          : FeatureGherkinDocument.fromMap(map['feature']),
      comments: map['comments'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DataGherkinDocument.fromJson(String source) =>
      DataGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        uri,
        feature,
        comments,
      ];
}

class FeatureGherkinDocument extends Equatable {
  const FeatureGherkinDocument({
    required this.location,
    required this.tags,
    required this.language,
    required this.keyword,
    required this.name,
    required this.description,
    required this.children,
  });

  final LocationGherkinDocument? location;
  final List<TagsGherkinDocument>? tags;
  final String? language;
  final String? keyword;
  final String? name;
  final String? description;
  final List<ChildrenFeatureGherkinDocument>? children;

  Map<String, dynamic> toMap() {
    return {
      'location': location?.toMap(),
      'tags': tags?.map((e) => e.toMap()).toList(),
      'language': language,
      'keyword': keyword,
      'name': name,
      'description': description,
      'children': children?.map((e) => e.toMap()).toList(),
    };
  }

  factory FeatureGherkinDocument.fromMap(Map<String, dynamic> map) {
    return FeatureGherkinDocument(
      location: map['location'] == null
          ? null
          : LocationGherkinDocument.fromMap(map['location']),
      tags: map['tags'] == null
          ? null
          : List.from(
              (map['tags'] as List).map((e) => TagsGherkinDocument.fromMap(e))),
      language: map['language'],
      keyword: map['keyword'],
      name: map['name'],
      description: map['description'],
      children: map['children'] == null
          ? null
          : List.from((map['children'] as List)
              .map((e) => ChildrenFeatureGherkinDocument.fromMap(e))),
    );
  }

  String toJson() => json.encode(toMap());

  factory FeatureGherkinDocument.fromJson(String source) =>
      FeatureGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        location,
        tags,
        language,
        keyword,
        name,
        description,
        children,
      ];
}

class LocationGherkinDocument extends Equatable {
  const LocationGherkinDocument({
    required this.line,
    required this.column,
  });

  final int? line;
  final int? column;

  Map<String, dynamic> toMap() {
    return {
      'line': line,
      'column': column,
    };
  }

  factory LocationGherkinDocument.fromMap(Map<String, dynamic> map) {
    return LocationGherkinDocument(
      line: int.tryParse(map['line']?.toString() ?? ''),
      column: int.tryParse(map['column']?.toString() ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationGherkinDocument.fromJson(String source) =>
      LocationGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        line,
        column,
      ];
}

class TagsGherkinDocument extends Equatable {
  const TagsGherkinDocument({
    required this.location,
    required this.name,
    required this.id,
  });

  final LocationGherkinDocument? location;
  final String? name;
  final String? id;

  Map<String, dynamic> toMap() {
    return {
      'location': location?.toMap(),
      'name': name,
      'id': id,
    };
  }

  factory TagsGherkinDocument.fromMap(Map<String, dynamic> map) {
    return TagsGherkinDocument(
      location: map['location'] == null
          ? null
          : LocationGherkinDocument.fromMap(map['location']),
      name: map['name'],
      id: map['id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TagsGherkinDocument.fromJson(String source) =>
      TagsGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        location,
        name,
        id,
      ];
}

class ChildrenFeatureGherkinDocument extends Equatable {
  const ChildrenFeatureGherkinDocument({
    required this.background,
    required this.scenario,
    required this.rule,
  });

  final ScenarioGherkinDocument? background;
  final ScenarioGherkinDocument? scenario;
  final RuleGherkinDocument? rule;

  Map<String, dynamic> toMap() {
    return {
      'background': background?.toMap(),
      'scenario': scenario?.toMap(),
      'rule': rule?.toMap(),
    };
  }

  factory ChildrenFeatureGherkinDocument.fromMap(Map<String, dynamic> map) {
    return ChildrenFeatureGherkinDocument(
      background: map['background'] == null
          ? null
          : ScenarioGherkinDocument.fromMap(map['background']),
      scenario: map['scenario'] == null
          ? null
          : ScenarioGherkinDocument.fromMap(map['scenario']),
      rule:
          map['rule'] == null ? null : RuleGherkinDocument.fromMap(map['rule']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChildrenFeatureGherkinDocument.fromJson(String source) =>
      ChildrenFeatureGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        background,
        scenario,
        rule,
      ];
}

class ScenarioGherkinDocument extends Equatable {
  const ScenarioGherkinDocument({
    required this.location,
    required this.keyword,
    required this.name,
    required this.description,
    required this.steps,
    required this.id,
    required this.tags,
  });

  final LocationGherkinDocument? location;
  final String? keyword;
  final String? name;
  final String? description;
  final List<StepsGherkinDocument>? steps;
  final String? id;
  final List<TagsGherkinDocument>? tags;

  Map<String, dynamic> toMap() {
    return {
      'location': location?.toMap(),
      'keyword': keyword,
      'name': name,
      'description': description,
      'steps': steps?.map((e) => e.toMap()).toList(),
      'id': id,
      'tags': tags?.map((e) => e.toMap()).toList(),
    };
  }

  factory ScenarioGherkinDocument.fromMap(Map<String, dynamic> map) {
    return ScenarioGherkinDocument(
      location: map['location'] == null
          ? null
          : LocationGherkinDocument.fromMap(map['location']),
      keyword: map['keyword'],
      name: map['name'],
      description: map['description'],
      steps: map['steps'] == null
          ? null
          : List.from((map['steps'] as List)
              .map((e) => StepsGherkinDocument.fromMap(e))),
      id: map['id'],
      tags: map['tags'] == null
          ? null
          : List.from(
              (map['tags'] as List).map((e) => TagsGherkinDocument.fromMap(e))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ScenarioGherkinDocument.fromJson(String source) =>
      ScenarioGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        location,
        keyword,
        name,
        description,
        steps,
        id,
        tags,
      ];
}

class StepsGherkinDocument extends Equatable {
  const StepsGherkinDocument({
    required this.location,
    required this.keyword,
    required this.keywordType,
    required this.text,
    required this.id,
  });

  final LocationGherkinDocument? location;
  final String? keyword;
  final String? keywordType;
  final String? text;
  final String? id;

  Map<String, dynamic> toMap() {
    return {
      'location': location?.toMap(),
      'keyword': keyword,
      'keywordType': keywordType,
      'text': text,
      'id': id,
    };
  }

  factory StepsGherkinDocument.fromMap(Map<String, dynamic> map) {
    return StepsGherkinDocument(
      location: map['location'] == null
          ? null
          : LocationGherkinDocument.fromMap(map['location']),
      keyword: map['keyword'],
      keywordType: map['keywordType'],
      text: map['text'],
      id: map['id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory StepsGherkinDocument.fromJson(String source) =>
      StepsGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        location,
        keyword,
        keywordType,
        text,
        id,
      ];
}

class RuleGherkinDocument extends Equatable {
  const RuleGherkinDocument({
    required this.location,
    required this.tags,
    required this.language,
    required this.keyword,
    required this.name,
    required this.description,
    required this.children,
    required this.id,
  });

  final LocationGherkinDocument? location;
  final List<TagsGherkinDocument>? tags;
  final String? language;
  final String? keyword;
  final String? name;
  final String? description;
  final List<ChildrenFeatureGherkinDocument>? children;
  final String? id;

  Map<String, dynamic> toMap() {
    return {
      'location': location?.toMap(),
      'tags': tags?.map((e) => e.toMap()).toList(),
      'language': language,
      'keyword': keyword,
      'name': name,
      'description': description,
      'children': children?.map((e) => e.toMap()).toList(),
      'id': id,
    };
  }

  factory RuleGherkinDocument.fromMap(Map<String, dynamic> map) {
    return RuleGherkinDocument(
      location: map['location'] == null
          ? null
          : LocationGherkinDocument.fromMap(map['location']),
      tags: map['tags'] == null
          ? null
          : List.from(
              (map['tags'] as List).map((e) => TagsGherkinDocument.fromMap(e))),
      language: map['language'],
      keyword: map['keyword'],
      name: map['name'],
      description: map['description'],
      children: map['children'] == null
          ? null
          : List.from((map['children'] as List)
              .map((e) => ChildrenFeatureGherkinDocument.fromMap(e))),
      id: map['id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RuleGherkinDocument.fromJson(String source) =>
      RuleGherkinDocument.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        location,
        tags,
        language,
        keyword,
        name,
        description,
        children,
        id,
      ];
}
