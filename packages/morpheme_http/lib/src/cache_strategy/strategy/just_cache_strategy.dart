import 'package:http/http.dart';

import '../../errors/morpheme_exceptions.dart';
import '../storage/storage.dart';
import 'cache_strategy.dart';

final class JustCacheStrategy extends CacheStrategy {
  JustCacheStrategy({
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
    final cached = await invokeCache(
      key: key,
      storage: storage,
      ttlValue: ttlValue,
      keepExpiredCache: keepExpiredCache,
    );

    if (cached == null) {
      throw CacheException();
    }

    return cached;
  }

  @override
  List<Object?> get props => [ttlValue, keepExpiredCache];
}
