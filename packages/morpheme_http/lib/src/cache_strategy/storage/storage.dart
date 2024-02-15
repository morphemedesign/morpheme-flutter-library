abstract interface class Storage {
  /// A function that takes a key and a value and returns a future.
  Future<void> write(String key, String value);

  /// Returning a future that will return a string or null.
  Future<String?> read(String key);

  /// Deleting a key from the storage.
  Future<void> delete(String key);

  /// Counting the number of keys in the storage.
  Future<int> count({String? prefix});

  /// A function that takes a string and returns a future.
  Future<void> clear({String? prefix});
}
