import 'dart:convert';

import 'package:http/http.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
final class CacheWrapper {
  CacheWrapper({
    required this.key,
    required this.cacheDate,
    this.response,
  });

  @Id()
  int id = 0;

  @Index(type: IndexType.value)
  @Unique(onConflict: ConflictStrategy.replace)
  final String key;

  final int cacheDate;

  @Transient()
  Response? response;

  String get dbResponse => json.encode(
        {
          'body': response?.body,
          'status_code': response?.statusCode,
          'headers': response?.headers,
          'is_redirect': response?.isRedirect,
          'persistent_connection': response?.persistentConnection,
          'reason_phrase': response?.reasonPhrase,
          'request': {
            'url': response?.request?.url.toString(),
            'method': response?.request?.method,
          },
        },
      );

  set dbResponse(String value) {
    final map = json.decode(value);
    response = Response(
      map['body'] ?? '',
      map['status_code'] ?? 400,
      headers: Map<String, String>.from(map['headers'] ?? {}),
      isRedirect: map['is_redirect'],
      persistentConnection: map['persistent_connection'],
      reasonPhrase: map['reason_phrase'],
      request: Request(
        map['request']['method'] ?? '',
        Uri.parse(map['request']['url'] ?? ''),
      ),
    );
  }
}
