import 'dart:convert';

import 'package:http/http.dart';

final class CacheWrapper {
  CacheWrapper({
    required this.cacheDate,
    required this.response,
  });

  final int cacheDate;
  final Response response;

  Map<String, dynamic> toMap() {
    return {
      'cacheDate': cacheDate,
      'response': {
        'body': response.body,
        'status_code': response.statusCode,
        'headers': response.headers,
        'is_redirect': response.isRedirect,
        'persistent_connection': response.persistentConnection,
        'reason_phrase': response.reasonPhrase,
        'request': {
          'url': response.request?.url.toString(),
          'method': response.request?.method,
        },
      },
    };
  }

  factory CacheWrapper.fromMap(Map<String, dynamic> map) {
    return CacheWrapper(
      cacheDate: map['cacheDate']?.toInt() ?? 0,
      response: Response(
        map['response']['body'] ?? '',
        map['response']['status_code'] ?? 400,
        headers: Map<String, String>.from(map['response']['headers'] ?? {}),
        isRedirect: map['response']['is_redirect'],
        persistentConnection: map['response']['persistent_connection'],
        reasonPhrase: map['response']['reason_phrase'],
        request: Request(
          map['response']['request']['method'] ?? '',
          Uri.parse(map['response']['request']['url'] ?? ''),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CacheWrapper.fromJson(String source) =>
      CacheWrapper.fromMap(json.decode(source));
}
