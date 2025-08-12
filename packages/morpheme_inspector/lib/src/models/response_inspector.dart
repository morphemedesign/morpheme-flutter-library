import 'dart:convert';

/// Data class for response inspector will used to save to local storage.
final class ResponseInspector {
  ResponseInspector({
    this.status,
    this.headers,
    this.body,
    this.size,
    this.dateTime,
    this.isTimeout,
  });

  /// Status code response
  final int? status;

  /// The headers response send http.
  final Map<dynamic, dynamic>? headers;

  /// The body response send http.
  final Object? body;

  /// The number size response http.
  final int? size;

  /// The date time when instance created.
  final DateTime? dateTime;

  /// Flag instance is timeout.
  final bool? isTimeout;

  /// Return to Map&ltString, dynamic&gt from [ResponseInspector] data class.
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'headers': headers,
      'body': body is Map ? body : body?.toString(),
      'size': size,
      'date_time': dateTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      'is_timeout': isTimeout,
    };
  }

  /// Return to [ResponseInspector] from  Map&ltString, dynamic&gt.
  factory ResponseInspector.fromMap(Map<String, dynamic> map) {
    return ResponseInspector(
      status: map['status']?.toInt(),
      headers: map['headers'] != null
          ? Map<dynamic, dynamic>.from(map['headers'])
          : null,
      body: map['body'] != null
          ? map['body'] is Map?
              ? Map<dynamic, dynamic>.from(map['body'])
              : map['body']?.toString()
          : null,
      size: map['size']?.toInt(),
      dateTime: map['date_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_time'])
          : null,
      isTimeout: map['is_timeout'] ?? false,
    );
  }

  /// Return string json from [toMap].
  String toJson() => json.encode(toMap());

  /// Return [ResponseInspector] from json string with given [source].
  factory ResponseInspector.fromJson(String source) =>
      ResponseInspector.fromMap(json.decode(source));
}
