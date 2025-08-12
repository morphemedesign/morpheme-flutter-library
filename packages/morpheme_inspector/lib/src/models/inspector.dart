import 'dart:convert';

import 'request_inspector.dart';
import 'response_inspector.dart';

/// Data class for inspector will used to save to local storage.
final class Inspector {
  Inspector({
    required this.uuid,
    required this.request,
    this.response,
    required this.createdAt,
    this.updatedAt,
  });

  /// The unique uuid.
  final String uuid;

  /// The request inspector will save to local storage.
  final RequestInspector request;

  /// The response inspector will save to local storage.
  final ResponseInspector? response;

  /// The datetime created of inspector.
  final DateTime createdAt;

  /// The datetime updated of inspector.
  final DateTime? updatedAt;

  /// Return to Map&ltString, dynamic&gt from [Inspector] data class.
  Map<String, dynamic> toMap() {
    return {
      'id': uuid,
      'request': request.toJson(),
      'response': response?.toJson() ?? '{}',
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Return to [Inspector] from  Map&ltString, dynamic&gt.
  factory Inspector.fromMap(Map<String, dynamic> map) {
    return Inspector(
      uuid: map['id'] ?? '',
      request: RequestInspector.fromJson(map['request']),
      response: map['response'] != null
          ? ResponseInspector.fromJson(map['response'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  /// Return string json from [toMap].
  String toJson() => json.encode(toMap());

  /// Return [Inspector] from json string with given [source].
  factory Inspector.fromJson(String source) =>
      Inspector.fromMap(json.decode(source));
}
