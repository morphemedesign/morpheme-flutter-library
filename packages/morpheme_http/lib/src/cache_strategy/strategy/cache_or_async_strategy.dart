import 'package:http/http.dart';

import '../storage/storage.dart';
import 'cache_strategy.dart';

final class CacheOrAsyncStrategy extends CacheStrategy {
  CacheOrAsyncStrategy({
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
    return await invokeCache(
          key: key,
          storage: storage,
          ttlValue: ttlValue,
          keepExpiredCache: keepExpiredCache,
        ) ??
        await invokeAsync(key: key, storage: storage, fetch: fetch);
  }

  @override
  List<Object?> get props => [ttlValue, keepExpiredCache];
}
