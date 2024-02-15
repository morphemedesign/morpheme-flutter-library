import 'dart:convert';

/// Data class for request inspector will used to save to local storage.
final class RequestInspector {
  RequestInspector({
    required this.url,
    required this.method,
    this.headers,
    this.body,
    this.size,
    this.dateTime,
  });

  /// The url http.
  final Uri url;

  /// The method request send http.
  final String method;

  /// The headers request send http.
  final Map<dynamic, dynamic>? headers;

  /// The body request send http.
  final Object? body;

  /// The number size request http.
  final int? size;

  /// The date time when instance created.
  final DateTime? dateTime;

  /// Return to Map<String, dynamic> from [RequestInspector] data class.
  Map<String, dynamic> toMap() {
    return {
      'url': url.toString(),
      'method': method,
      'headers': headers,
      'body': body is Map ? body : body?.toString(),
      'size': size,
      'date_time': dateTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Return to [RequestInspector] from  Map<String, dynamic>.
  factory RequestInspector.fromMap(Map<String, dynamic> map) {
    return RequestInspector(
      url: Uri.parse(map['url']),
      method: map['method'] ?? '',
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
    );
  }

  /// Return string json from [toMap].
  String toJson() => json.encode(toMap());

  /// Return [RequestInspector] from json string with given [source].
  factory RequestInspector.fromJson(String source) =>
      RequestInspector.fromMap(json.decode(source));
}
