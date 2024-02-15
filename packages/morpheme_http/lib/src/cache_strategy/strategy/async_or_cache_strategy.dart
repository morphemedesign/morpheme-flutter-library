import 'package:http/http.dart';

import '../storage/storage.dart';
import 'cache_strategy.dart';

final class AsyncOrCacheStrategy extends CacheStrategy {
  AsyncOrCacheStrategy({
    this.ttlValue = CacheStrategy.defaultTTLValue,
    this.keepExpiredCache = false,
  });

  final Duration ttlValue;
  final bool keepExpiredCache;

  @override
  Future<Response> applyStrategy({
    required String key,
    required Storage storage,
    required Future<Response> Function() fetch,
  }) async {
    final response =
        await invokeAsync(key: key, storage: storage, fetch: fetch);
    if (response.statusCode >= 200 &&
        response.statusCode <= 299 &&
        response.statusCode == 401) {
      return response;
    }

    final cached = await invokeCache(
      key: key,
      storage: storage,
      ttlValue: ttlValue,
      keepExpiredCache: keepExpiredCache,
    );
    return cached ?? response;
  }

  @override
  List<Object?> get props => [ttlValue, keepExpiredCache];
}
