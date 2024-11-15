import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:morpheme_http/morpheme_http.dart';

abstract class CacheStrategy extends Equatable {
  static const defaultTTLValue = Duration(hours: 1);

  /// It takes a key, a response, and a storage object, and then it stores the response in the storage
  /// object under the key
  ///
  /// Args:
  ///   key (String): The key to store the data under.
  ///   response (Response): The response from the server.
  ///   storage (Storage): The storage object that you created in the previous step.
  Future _storeCacheData<T>(
    String key,
    Response response,
    Storage storage,
  ) async {
    final cacheWrapper = CacheWrapper(
      key: key,
      cacheDate: DateTime.now().millisecondsSinceEpoch,
      response: response,
    );
    await storage.write(cacheWrapper);
  }

  /// If the cache is expired,
  /// return false. Otherwise, return true
  ///
  /// Args:
  ///   cacheWrapper (CacheWrapper): The wrapper object that contains the cached data and the date it
  /// was cached.
  ///   keepExpiredCache (bool): This is a boolean value that determines whether to keep expired cache
  /// or not.
  ///   ttlValue (Duration): The time to live value for the cache.
  bool _isValid<T>(CacheWrapper cacheWrapper, bool keepExpiredCache,
          Duration ttlValue) =>
      keepExpiredCache ||
      DateTime.now().millisecondsSinceEpoch <
          cacheWrapper.cacheDate + ttlValue.inMilliseconds;

  /// "Invoke the fetch function, store the result in the cache, and return the result."
  ///
  /// The `fetch` function is the function that will be called to get the data. It's a function that
  /// returns a `Future<Response>`
  ///
  /// Args:
  ///   key (String): The key to store the data under.
  ///   storage (Storage): The storage to use.
  ///   fetch (Future<Response> Function()): The function that will be called to fetch the data.
  ///
  /// Returns:
  ///   A Future<Response>
  Future<Response> invokeAsync({
    required String key,
    required Storage storage,
    required Future<Response> Function() fetch,
  }) async {
    final response = await fetch();
    if (response.statusCode >= 200 &&
        response.statusCode <= 299 &&
        (this is AsyncOrCacheStrategy || this is CacheOrAsyncStrategy)) {
      await _storeCacheData(key, response, storage);
    }
    return response;
  }

  /// It reads the cache from the storage, checks if it's valid, and returns the response if it is
  ///
  /// Args:
  ///   key (String): The key to store the cache data.
  ///   storage (Storage): The storage to use.
  ///   keepExpiredCache (bool): If true, the cache will be returned even if it has expired. Defaults to
  /// false
  ///   ttlValue (Duration): The time to live value for the cache. Defaults to defaultTTLValue
  ///
  /// Returns:
  ///   A Future<Response?>
  Future<Response?> invokeCache({
    required String key,
    required Storage storage,
    bool keepExpiredCache = false,
    Duration ttlValue = defaultTTLValue,
  }) async {
    final cacheWrapper = await storage.read(key);
    if (cacheWrapper != null) {
      if (_isValid(cacheWrapper, keepExpiredCache, ttlValue)) {
        if (kDebugMode) {
          print("Fetch cache data for key $key: ${cacheWrapper.response}");
        }
        return cacheWrapper.response;
      }
    }
    return null;
  }

  /// It's a function that returns a `Future<Response>`
  Future<Response> applyStrategy({
    required String key,
    required Storage storage,
    required Future<Response> Function() fetch,
  });
}
