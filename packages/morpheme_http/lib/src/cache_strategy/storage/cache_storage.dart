import 'package:morpheme_http/src/cache_strategy/model/cache_wrapper.dart';
import 'package:morpheme_http/src/cache_strategy/model/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

import 'storage.dart';

final class CacheStorage implements Storage {
  /// The name of the ObjectBox store used for caching HTTP responses.
  ///
  /// This constant defines the directory name where the ObjectBox store
  /// will be located. It is used to store and manage cached HTTP responses
  /// efficiently. The store is initialized and accessed using this name.
  static const _storeName = "morpheme_http_cache_storage";

  /// The ObjectBox store instance used for managing cached data.
  ///
  /// This variable holds the reference to the ObjectBox store, which is
  /// responsible for storing and retrieving cached HTTP responses.
  Store? _store;

  /// Provides access to the ObjectBox box for `CacheWrapper` entities.
  ///
  /// This getter returns the box that contains `CacheWrapper` entities,
  /// allowing for operations such as querying, inserting, and deleting
  /// cached data.
  Box<CacheWrapper>? get _box => _store?.box<CacheWrapper>();

  /// Queries the ObjectBox store for a `CacheWrapper` entity by its key.
  ///
  /// This method builds a query to find a `CacheWrapper` entity with a
  /// specific key, which is typically the URL of the cached HTTP response.
  ///
  /// Args:
  ///   imageUrl (String): The key to query for, usually the URL of the cached response.
  ///
  /// Returns:
  ///   A query object that can be used to execute the search.
  Query<CacheWrapper>? queryByKey(String imageUrl) =>
      _box?.query(CacheWrapper_.key.equals(imageUrl)).build();

  /// Queries the ObjectBox store for `CacheWrapper` entities with keys
  /// that start with a given prefix.
  ///
  /// This method builds a query to find all `CacheWrapper` entities whose
  /// keys start with the specified prefix, allowing for batch operations
  /// on related cached data.
  ///
  /// Args:
  ///   prefix (String): The prefix to query for.
  ///
  /// Returns:
  ///   A query object that can be used to execute the search.
  Query<CacheWrapper>? queryByPrefixKey(String prefix) =>
      _box?.query(CacheWrapper_.key.startsWith(prefix)).build();

  /// Constructs a new `CacheStorage` instance and opens the ObjectBox store.
  ///
  /// This constructor initializes the `CacheStorage` by opening the
  /// ObjectBox store, ensuring that it is ready for use.
  CacheStorage() {
    _openStore();
  }

  /// Opens the ObjectBox store for caching HTTP responses.
  ///
  /// This method checks if the store is already open. If not, it retrieves
  /// the application documents directory and opens the store at the specified
  /// location.
  Future<void> _openStore() async {
    final storeExists = _store != null;
    if (!storeExists) {
      final docsDir = await getApplicationDocumentsDirectory();
      _store = await openStore(
        directory: '${docsDir.path}/$_storeName',
      );
    }
  }

  /// Clears cached data from the ObjectBox store.
  ///
  /// This method removes all cached data if no prefix is provided. If a
  /// prefix is specified, it removes only the cached data with keys that
  /// start with the given prefix.
  ///
  /// Args:
  ///   prefix (String?, optional): The prefix to filter keys for removal.
  ///
  /// Returns:
  ///   A future that completes with the number of entries removed.
  @override
  Future<int?> clear({String? prefix}) async {
    if (prefix == null) {
      return await _box?.removeAllAsync();
    } else {
      return await queryByPrefixKey(prefix)?.removeAsync();
    }
  }

  /// Deletes a cached entry from the ObjectBox store by its key.
  ///
  /// This method removes a specific cached entry identified by the given
  /// key, which is typically the URL of the cached HTTP response.
  ///
  /// Args:
  ///   key (String): The key of the cached entry to delete.
  ///
  /// Returns:
  ///   A future that completes with the number of entries removed.
  @override
  Future<int?> delete(String key) async {
    return await queryByKey(key)?.removeAsync();
  }

  /// Reads a cached entry from the ObjectBox store by its key.
  ///
  /// This method retrieves a specific cached entry identified by the given
  /// key, which is typically the URL of the cached HTTP response.
  ///
  /// Args:
  ///   key (String): The key of the cached entry to read.
  ///
  /// Returns:
  ///   A future that completes with the `CacheWrapper` entity if found, or null.
  @override
  Future<CacheWrapper?> read(String key) async {
    return await queryByKey(key)?.findFirstAsync();
  }

  /// Writes a `CacheWrapper` entity to the ObjectBox store.
  ///
  /// This method stores a `CacheWrapper` entity in the ObjectBox store,
  /// allowing it to be retrieved later by its key.
  ///
  /// Args:
  ///   value (CacheWrapper): The `CacheWrapper` entity to store.
  ///
  /// Returns:
  ///   A future that completes with the ID of the stored entity.
  @override
  Future<int?> write(CacheWrapper value) async {
    return await _box?.putAsync(value);
  }

  /// Counts the number of cached entries in the ObjectBox store.
  ///
  /// This method returns the total number of cached entries if no prefix
  /// is provided. If a prefix is specified, it counts only the entries
  /// with keys that start with the given prefix.
  ///
  /// Args:
  ///   prefix (String?, optional): The prefix to filter keys for counting.
  ///
  /// Returns:
  ///   A future that completes with the number of entries counted.
  @override
  Future<int> count({String? prefix}) async {
    if (prefix == null) {
      return _box?.count() ?? 0;
    } else {
      return queryByPrefixKey(prefix)?.count() ?? 0;
    }
  }

  /// Closes the ObjectBox store if it is open and sets it to null.
  ///
  /// This method ensures that the ObjectBox store is properly closed and
  /// the reference is set to null, releasing any resources held by the store.
  Future<void> close() async {
    final isOpenStore = _store != null;
    if (isOpenStore) {
      _store?.close();
    }
    _store = null;
  }
}
