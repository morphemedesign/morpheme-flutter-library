import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'storage.dart';

final class CacheStorage implements Storage {
  static const _hiveBoxName = "morpheme_http_cache_storage";

  bool _hasInit = false;

  CacheStorage();

  Future<dynamic> openBox() async {
    if (!_hasInit && !kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    _hasInit = true;
    return Hive.openBox(_hiveBoxName);
  }

  @override
  Future<void> clear({String? prefix}) async {
    final box = await openBox();
    if (prefix == null) {
      await box.clear();
    } else {
      for (var key in box.keys) {
        if (key is String && key.startsWith(prefix)) {
          await box.delete(key);
        }
      }
    }
  }

  @override
  Future<void> delete(String key) async {
    final box = await openBox();
    return box.delete(key);
  }

  @override
  Future<String?> read(String key) async {
    final box = await openBox();
    return box.get(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final box = await openBox();
    return box.put(key, value);
  }

  @override
  Future<int> count({String? prefix}) async {
    final box = await openBox();
    if (prefix == null) {
      return box.length;
    } else {
      var count = 0;
      for (var key in box.keys) {
        if (key is String && key.startsWith(prefix)) {
          count++;
        }
      }
      return count;
    }
  }
}
