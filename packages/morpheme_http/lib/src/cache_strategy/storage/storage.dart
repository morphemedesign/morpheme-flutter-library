import 'package:morpheme_http/src/cache_strategy/cache_strategy.dart';

abstract interface class Storage {
  /// A function that takes a key and a value and returns a future.
  Future<int?> write(CacheWrapper value);

  /// Returning a future that will return a string or null.
  Future<CacheWrapper?> read(String key);

  /// Deleting a key from the storage.
  Future<int?> delete(String key);

  /// Counting the number of keys in the storage.
  Future<int> count({String? prefix});

  /// A function that takes a string and returns a future.
  Future<int?> clear({String? prefix});
}
