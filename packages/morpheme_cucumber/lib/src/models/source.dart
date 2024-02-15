import 'dart:convert';

import 'package:equatable/equatable.dart';

class Source extends Equatable {
  const Source({
    required this.source,
  });

  final DataSource? source;

  Map<String, dynamic> toMap() {
    return {
      'source': source?.toMap(),
    };
  }

  factory Source.fromMap(Map<String, dynamic> map) {
    return Source(
      source: map['source'] == null ? null : DataSource.fromMap(map['source']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Source.fromJson(String source) => Source.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        source,
      ];
}

class DataSource extends Equatable {
  const DataSource({
    required this.uri,
    required this.data,
    required this.mediaType,
  });

  final String? uri;
  final String? data;
  final String? mediaType;

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'data': data,
      'mediaType': mediaType,
    };
  }

  factory DataSource.fromMap(Map<String, dynamic> map) {
    return DataSource(
      uri: map['uri'],
      data: map['data'],
      mediaType: map['mediaType'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DataSource.fromJson(String source) =>
      DataSource.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        uri,
        data,
        mediaType,
      ];
}
