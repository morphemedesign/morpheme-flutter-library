import 'dart:async';
import 'dart:typed_data';

import 'package:morpheme_cached_network_image/src/model/cached_model.dart';
import 'package:http/http.dart' as http;
import 'package:morpheme_cached_network_image/src/model/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

typedef CallbackCachedManager = void Function(Uint8List? image, Object? error);

class MorphemeCachedNetworkImageManager {
  static final MorphemeCachedNetworkImageManager instance =
      MorphemeCachedNetworkImageManager._();

  factory MorphemeCachedNetworkImageManager() {
    return instance;
  }

  MorphemeCachedNetworkImageManager._();

  /// The name of the ObjectBox store used for caching network images.
  ///
  /// This constant defines the directory name where the ObjectBox store
  /// will be located. It is used to store and manage cached network images
  /// efficiently. The store is initialized and accessed using this name.
  static const _storeName = "morpheme_cached_network_image";

  /// Initializes the MorphemeCachedNetworkImageManager by opening the ObjectBox store.
  ///
  /// This method should be called before any operations that require access to the
  /// cached network images. It ensures that the ObjectBox store is opened and ready
  /// for use. If the store is already open, this method does nothing.
  ///
  /// Returns a [Future] that completes when the store is successfully opened.
  Future<void> init() => _openStore();

  /// `Duration ttl = const Duration(days: 30);` is declaring a default time-to-live (TTL) duration for
  /// cached images. The TTL is the amount of time that a cached image is considered valid before it
  /// needs to be refreshed. In this case, the default TTL is set to 30 days.
  Duration ttl = const Duration(days: 30);

  /// `int maxConcurrent = 10;` is declaring the maximum number of concurrent requests that can be made
  /// to download images. If the number of concurrent requests exceeds this limit, the requests will be
  /// queued and executed one by one.
  int maxConcurrent = 10;
  int _concurrent = 0;

  Store? _store;

  Box<CachedModel>? get _box => _store?.box<CachedModel>();
  Query<CachedModel>? queryByImageUrl(String imageUrl) =>
      _box?.query(CachedModel_.imageUrl.equals(imageUrl)).build();

  /// This function opens a Object box for storing cached network images if it is not already open.
  Future<void> _openStore() async {
    final storeExists = _store != null;
    if (!storeExists) {
      final docsDir = await getApplicationDocumentsDirectory();
      // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
      _store = await openStore(
        directory: '${docsDir.path}/$_storeName',
      );
    }
  }

  /// This function handles an asynchronous HTTP request for an image and caches the response.
  ///
  /// Args:
  ///   imageUrl (String): A string representing the URL of the image to be fetched and cached.
  ///   callback (void Function(Uint8List? image, Object? error)): The callback parameter is a function
  /// that takes two arguments: an optional Uint8List representing the image data, and an optional
  /// Object representing any error that occurred during the async operation. The function is called
  /// after the async operation completes, and is used to pass the results of the operation back to the
  /// caller.
  Future<void> _hanldeAsync(
    String imageUrl,
    void Function(Uint8List? image, Object? error) callback,
  ) async {
    _concurrent++;
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final cachedModel = CachedModel(
          imageUrl: imageUrl,
          image: response.bodyBytes,
          ttl: DateTime.now().add(ttl).millisecondsSinceEpoch,
        );
        _box?.put(cachedModel);
        callback(response.bodyBytes, null);
      } else {
        callback(
          null,
          Exception('Host url get return status code ${response.statusCode}'),
        );
      }
    } catch (e) {
      callback(null, e);
    }
    _concurrent--;
  }

  /// This function checks if an image is cached and returns it if it is not expired.
  ///
  /// Args:
  ///   imageUrl (String): The `imageUrl` parameter is a `String` that represents the URL of an image
  /// that is being requested.
  ///
  /// Returns:
  ///   If the cached image exists and its time-to-live (ttl) has not expired, then the cached image is
  /// returned as a Uint8List. Otherwise, null is returned.
  Uint8List? _handleCache(String imageUrl) {
    final cached = queryByImageUrl(imageUrl)?.findFirst();
    if (cached != null && cached.ttl > DateTime.now().millisecondsSinceEpoch) {
      return cached.image;
    }
    return null;
  }

  /// This function checks if an image is cached, and if not, handles it asynchronously while limiting
  /// the number of concurrent requests.
  ///
  /// Args:
  ///   imageUrl (String): A string representing the URL of an image to be cached or retrieved
  /// asynchronously.
  ///   callback (CallbackCachedManager): CallbackCachedManager is a function type that takes two
  /// parameters - the cached image (if available) and an error message (if any) - and returns nothing
  /// (void). It is used to handle the result of the cachedOrAsync function.
  ///
  /// Returns:
  ///   a `Future<void>`.
  Future<void> cachedOrAsync(
      String imageUrl, CallbackCachedManager callback) async {
    await _openStore();

    final cached = _handleCache(imageUrl);
    if (cached != null) {
      callback(cached, null);
      return;
    }

    if (_concurrent < maxConcurrent) {
      await _hanldeAsync(imageUrl, callback);
      return;
    }

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_concurrent < maxConcurrent) {
        await _hanldeAsync(imageUrl, callback);
        timer.cancel();
      }
    });
  }

  /// This function checks if an image is cached, and if not, retrieves it asynchronously and returns it
  /// as a Uint8List.
  ///
  /// Args:
  ///   imageUrl (String): The parameter `imageUrl` is a string that represents the URL of an image that
  /// needs to be retrieved.
  ///
  /// Returns:
  ///   The function `cachedOrAsyncProvider` returns a `Future` that resolves to a `Uint8List` or
  /// `null`.
  Future<Uint8List?> cachedOrAsyncProvider(String imageUrl) async {
    await _openStore();

    final cached = _handleCache(imageUrl);
    if (cached != null) {
      return cached;
    }

    Uint8List? image;
    await _hanldeAsync(imageUrl, (callbackImage, _) => image = callbackImage);

    return image;
  }

  /// This function removes an image cache from a box using its URL.
  ///
  /// Args:
  ///   imageUrl (String): The `imageUrl` parameter is a `String` that represents the URL of an image
  /// that needs to be removed from the cache.
  Future<void> removeCache(String imageUrl) async {
    await _openStore();
    queryByImageUrl(imageUrl)?.remove();
  }

  /// This function clears all data stored in a box.
  Future<void> clear() async {
    await _openStore();
    _box?.removeAll();
  }

  /// This function closes a box if it is open and sets it to null.
  Future<void> close() async {
    final isOpenStore = _store != null;
    if (isOpenStore) {
      _store?.close();
    }
    _store = null;
  }
}
