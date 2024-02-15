import 'package:http/http.dart';

import '../storage/storage.dart';
import 'cache_strategy.dart';

final class JustAsyncStrategy extends CacheStrategy {
  @override
  Future<Response> applyStrategy(
      {required String key,
      required Storage storage,
      required Future<Response> Function() fetch}) {
    return invokeAsync(key: key, storage: storage, fetch: fetch);
  }

  @override
  List<Object?> get props => [];
}
