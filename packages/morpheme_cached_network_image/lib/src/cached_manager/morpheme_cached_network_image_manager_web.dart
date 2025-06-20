// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html';

import 'package:http/http.dart' as http;

typedef CallbackCachedManager = void Function(Uint8List? image, Object? error);

class MorphemeCachedNetworkImageManager {
  static final MorphemeCachedNetworkImageManager instance =
      MorphemeCachedNetworkImageManager._();

  factory MorphemeCachedNetworkImageManager() {
    return instance;
  }

  MorphemeCachedNetworkImageManager._();

  /// The name of the cache used for caching network images.
  ///
  /// This constant defines the key prefix used for storing cached network images
  /// in the browser's local storage.
  static const _cachePrefix = "morpheme_cached_network_image_";

  /// Initializes the MorphemeCachedNetworkImageManager.
  ///
  /// This method should be called before any operations that require access to the
  /// cached network images. It ensures that the cache is ready for use.
  ///
  /// Returns a [Future] that completes when the cache is successfully initialized.
  Future<void> init() async {
    // No specific initialization needed for web local storage.
  }

  /// `Duration ttl = const Duration(days: 30);` is declaring a default time-to-live (TTL) duration for
  /// cached images. The TTL is the amount of time that a cached image is considered valid before it
  /// needs to be refreshed. In this case, the default TTL is set to 30 days.
  Duration ttl = const Duration(days: 30);

  /// `int maxConcurrent = 10;` is declaring the maximum number of concurrent requests that can be made
  /// to download images. If the number of concurrent requests exceeds this limit, the requests will be
  /// queued and executed one by one.
  int maxConcurrent = 10;
  int _concurrent = 0;

  /// This function handles an asynchronous HTTP request for an image and caches the response.
  ///
  /// Args:
  ///   imageUrl (String): A string representing the URL of the image to be fetched and cached.
  ///   callback (void Function(Uint8List? image, Object? error)): The callback parameter is a function
  /// that takes two arguments: an optional Uint8List representing the image data, and an optional
  /// Object representing any error that occurred during the async operation. The function is called
  /// after the async operation completes, and is used to pass the results of the operation back to the
  /// caller.
  Future<void> _handleAsync(
    String imageUrl,
    void Function(Uint8List? image, Object? error) callback,
  ) async {
    _concurrent++;
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final cachedData = {
          'image': base64Encode(response.bodyBytes),
          'ttl': DateTime.now().add(ttl).millisecondsSinceEpoch,
        };
        window.localStorage[_cachePrefix + imageUrl] = jsonEncode(cachedData);
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
    final cachedData = window.localStorage[_cachePrefix + imageUrl];
    if (cachedData != null) {
      final data = jsonDecode(cachedData);
      if (data['ttl'] > DateTime.now().millisecondsSinceEpoch) {
        return Uint8List.fromList(List<int>.from(base64Decode(data['image'])));
      }
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
    final cached = _handleCache(imageUrl);
    if (cached != null) {
      callback(cached, null);
      return;
    }

    if (_concurrent < maxConcurrent) {
      await _handleAsync(imageUrl, callback);
      return;
    }

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_concurrent < maxConcurrent) {
        await _handleAsync(imageUrl, callback);
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
    final cached = _handleCache(imageUrl);
    if (cached != null) {
      return cached;
    }

    Uint8List? image;
    await _handleAsync(imageUrl, (callbackImage, _) => image = callbackImage);

    return image;
  }

  /// This function removes an image cache using its URL.
  ///
  /// Args:
  ///   imageUrl (String): The `imageUrl` parameter is a `String` that represents the URL of an image
  /// that needs to be removed from the cache.
  Future<void> removeCache(String imageUrl) async {
    window.localStorage.remove(_cachePrefix + imageUrl);
  }

  /// This function clears all data stored in the cache.
  Future<void> clear() async {
    window.localStorage.keys
        .where((key) => key.startsWith(_cachePrefix))
        .toList()
        .forEach(window.localStorage.remove);
  }

  /// This function clears expired images from the cache by removing those with a TTL less than the current time.
  Future<void> clearExpiredImage() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    window.localStorage.keys
        .where((key) => key.startsWith(_cachePrefix))
        .forEach((key) {
      final cachedData = jsonDecode(window.localStorage[key] ?? '{}');
      if (cachedData['ttl'] < now) {
        window.localStorage.remove(key);
      }
    });
  }

  /// This function is a placeholder for closing resources, but no action is needed for web local storage.
  Future<void> close() async {
    // No specific close operation needed for web local storage.
  }
}
