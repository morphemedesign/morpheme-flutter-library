import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:morpheme_http/src/utils/auth_token_option.dart';
import 'package:morpheme_http/src/utils/middleware_response_option.dart';
import 'package:morpheme_http/src/utils/refresh_token_option.dart';
import 'package:morpheme_inspector/morpheme_inspector.dart'
    show MorphemeInspector, Inspector, RequestInspector, ResponseInspector;
import 'package:uuid/uuid.dart';

import 'cache_strategy/cache_strategy.dart';
import 'errors/morpheme_exceptions.dart' as morpheme_exception;

typedef CallbackProgressHttp = void Function(
    int received, int totalContentLength);

/// The base class for an HTTP client.
class MorphemeHttp {
  MorphemeHttp({
    int timeout = 30000,
    MorphemeInspector? morphemeInspector,
    bool showLog = true,
    Map<String, String>? headers,
    AuthTokenOption? authTokenOption,
    RefreshTokenOption? refreshTokenOption,
    MiddlewareResponseOption? middlewareResponseOption,
    void Function(Object error, StackTrace stackTrace)? onErrorResponse,
  })  : _timeout = timeout,
        _morphemeInspector = morphemeInspector,
        _showLog = showLog,
        _headers = headers,
        _authTokenOption = authTokenOption,
        _refreshTokenOption = refreshTokenOption,
        _middlewareResponseOption = middlewareResponseOption,
        _storage = CacheStorage(),
        _onErrorResponse = onErrorResponse;

  /// Logger used for logging request and response http to console.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      errorMethodCount: 0,
      methodCount: 0,
      printEmojis: false,
    ),
  );

  /// The number of duration to timeout send http in milis.
  final int _timeout;

  /// The feature [MorphemeInspector] for listener request and response http
  /// like chuck in android.
  ///
  /// Show local notification each send http.
  /// Can shake phone for open ui [MorphemeInspector]
  final MorphemeInspector? _morphemeInspector;

  /// Show logger send http request and response to console.
  final bool _showLog;

  /// The default headers always to implement to each send http.
  final Map<String, String>? _headers;

  /// Option to handle auth token.
  final AuthTokenOption? _authTokenOption;

  /// Option to handle refresh token.
  final RefreshTokenOption? _refreshTokenOption;

  /// Option to handle middleware response.
  final MiddlewareResponseOption? _middlewareResponseOption;

  final Storage _storage;

  final void Function(Object error, StackTrace stackTrace)? _onErrorResponse;

  /// Return new headers with given [url] and old [headers],
  /// include set authorization.
  Future<Map<String, String>?> _putIfAbsentHeader(
    Uri url,
    Map<String, String>? headers,
  ) async {
    final mapEntityToken = await _authTokenOption?.getMapEntryToken(url);

    if (mapEntityToken == null && _headers == null) {
      return headers;
    }

    final newHeaders = headers ?? {};
    if (mapEntityToken != null) {
      newHeaders.putIfAbsent(mapEntityToken.key, () => mapEntityToken.value);
    }
    _headers?.forEach((key, value) {
      newHeaders.putIfAbsent(key, () => value);
    });
    return newHeaders;
  }

  /// Return object body request for logger with given [request] and [body].
  Object? _getBodyRequest(BaseRequest request, Object? body) {
    if (request is MultipartRequest) {
      final files = request.files
          .map((e) => {
                'filename': e.filename,
                'mime_type': e.contentType.mimeType,
                'field': e.field,
                'length': e.length.toString(),
              })
          .toList();

      return {
        'files': files,
        'body': request.fields,
      };
    }
    return body;
  }

  /// Show log [request] http to console.
  void _loggerRequest(BaseRequest request, Object? body) {
    if (kReleaseMode || !_showLog) return;
    _logger.d('----> Request');
    _logger.d(
      '${request.method.toUpperCase()} ${request.url.toString()}',
    );
    if (request.headers.isNotEmpty) _logger.d(request.headers);
    if (body != null) _logger.d(_getBodyRequest(request, body));
  }

  /// Show log [response] http to console.
  void _loggerResponse(Response response) {
    if (kReleaseMode || !_showLog) return;
    _logger.d('<---- Response ${response.statusCode}');
    try {
      _logger.d(jsonDecode(response.body));
    } catch (e) {
      _logger.d(response.body);
    }
  }

  /// Handle [request] http for [MorphemeInspector].
  Future<void> _inspectorRequest(
    String uuid,
    BaseRequest request,
    Object? body,
  ) async {
    await _morphemeInspector?.inspectorRequest(
      Inspector(
        uuid: uuid,
        request: RequestInspector(
          url: request.url,
          method: request.method,
          headers: request.headers,
          body: body,
          size: request.contentLength,
        ),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Handle [response] http for [MorphemeInspector].
  Future<void> _inspectorResponse(String uuid, Response response) async {
    Object? body;
    final contentType = response.headers.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == 'content-type',
          orElse: () => const MapEntry('', ''),
        )
        .value
        .toLowerCase();

    if (contentType.contains(RegExp(
        r'application/(octet-stream|pdf|zip|xml|x-www-form-urlencoded|javascript|html|css|jpeg|png|gif|bmp|webp|svg\+xml)'))) {
      body = 'Binary data';
    } else {
      try {
        body = json.decode(response.body);
      } catch (e) {
        body = response.body;
      }
    }

    await _morphemeInspector?.inspectorResponse(
      uuid,
      ResponseInspector(
        headers: response.headers,
        body: body,
        status: response.statusCode,
        size: response.contentLength,
      ),
    );
  }

  /// Handle timeout http for [MorphemeInspector].
  Future<void> _inspectorResponseTimeout(String uuid) async {
    await _morphemeInspector?.inspectorResponseTimeout(uuid);
  }

  Future<StreamedResponse> send(BaseRequest request) {
    return request.send();
  }

  /// Sends a non-streaming [Request] and returns a non-streaming [Response].
  Future<Response> _fetch(
    BaseRequest request,
    Object? body, [
    bool enableTimeout = true,
  ]) async {
    final uuid = const Uuid().v4();
    _loggerRequest(request, body);
    await _inspectorRequest(uuid, request, body);
    late StreamedResponse streamResponse;
    if (enableTimeout) {
      streamResponse = await request.send().timeout(
        Duration(milliseconds: _timeout),
        onTimeout: () async {
          await _inspectorResponseTimeout(uuid);
          throw morpheme_exception.TimeoutException();
        },
      );
    } else {
      streamResponse = await request.send();
    }
    final response = await Response.fromStream(streamResponse);
    _loggerResponse(response);
    _inspectorResponse(uuid, response);
    return response;
  }

  /// Return [Request] with given [method], [url], [headers], [body] and [encoding].
  Request _getRequest(String method, Uri url, Map<String, String>? headers,
      [body, Encoding? encoding]) {
    var request = Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        try {
          request.bodyFields = body.cast<String, String>();
        } catch (e) {
          request.body = json.encode(body);
        }
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }
    return request;
  }

  String _getKeyCache({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
  }) =>
      '$method-${url.hashCode}-${headers.toString().hashCode}-${body.toString().hashCode}';

  /// Sends a non-streaming [Request] and returns a non-streaming [Response],
  /// include put new headers and handle refresh token.
  Future<Response> _sendUnstreamed(
    String method,
    Uri url,
    Map<String, String>? headers,
    CacheStrategy cacheStrategy, {
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);

      final request = _getRequest(method, url, newHeaders, body, encoding);
      final response = await cacheStrategy.applyStrategy(
        key: _getKeyCache(
            method: method, url: url, headers: newHeaders, body: body),
        storage: _storage,
        fetch: () async {
          Response response = await _fetch(request, body);

          // do refresh token if condition is true
          if (await _refreshTokenOption?.condition(request, response) ??
              false) {
            response = await _doRefreshTokenThenRetry(request, response, body);
          } else if (await _refreshTokenOption
                  ?.conditionReFetchWithoutRefreshToken
                  ?.call(request, response) ??
              false) {
            response = await _doReFetch(request, response, body);
          }

          if (await _middlewareResponseOption?.condition(request, response) ??
              false) {
            await _middlewareResponseOption?.onResponse(response);
          }

          return response;
        },
      );

      _handleErrorResponse(response);

      await _authTokenOption?.handleConditionAuthTokenOption(request, response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (e, stackTrace) {
      _onErrorResponse?.call(e, stackTrace);
      rethrow;
    }
  }

  /// Do refresh token then if success retry the previous request
  /// with given [reqeust], previous [response] and previous [body].
  Future<Response> _doRefreshTokenThenRetry(
      BaseRequest request, Response response, Object? body) async {
    await _sendRefreshToken(_refreshTokenOption!);

    return _doReFetch(request, response, body);
  }

  /// Do re fetch with given [request], previous [response] and previous [body].
  Future<Response> _doReFetch(
    BaseRequest request,
    Response response,
    Object? body, [
    bool enableTimeout = true,
  ]) async {
    final copyRequest = await _copyRequest(request);
    return _fetch(copyRequest, body, enableTimeout);
  }

  /// Sends a refresh token non-streaming [Request] and returns a non-streaming [Response],
  Future<void> _sendRefreshToken(
    RefreshTokenOption refreshTokenOption,
  ) async {
    final method = refreshTokenOption.method.toString();
    final url = refreshTokenOption.url;
    final headers = await refreshTokenOption.getHeaders?.call();
    final body = await refreshTokenOption.getBody?.call();
    final encoding = refreshTokenOption.encoding;

    var request = _getRequest(method, url, headers, body, encoding);
    final response = await _fetch(request, body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await refreshTokenOption.onResponse(response);
    } else {
      final isValidResponse =
          await (refreshTokenOption.onErrorResponse?.call(response) ??
              Future.value(false));
      if (!isValidResponse) {
        throw morpheme_exception.RefreshTokenException(
          statusCode: response.statusCode,
          jsonBody: response.body,
        );
      }
    }
  }

  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
    CacheStrategy? cacheStrategy,
  }) async {
    return _sendUnstreamed(
      'HEAD',
      url,
      headers,
      cacheStrategy ?? JustAsyncStrategy(),
    );
  }

  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    CacheStrategy? cacheStrategy,
  }) async {
    Map<String, String>? queryParameters = body?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final urlWithBody = queryParameters?.isNotEmpty ?? false
        ? url.replace(queryParameters: queryParameters)
        : url;
    return _sendUnstreamed(
      'GET',
      urlWithBody,
      headers,
      cacheStrategy ?? JustAsyncStrategy(),
    );
  }

  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    CacheStrategy? cacheStrategy,
  }) =>
      _sendUnstreamed(
        'POST',
        url,
        headers,
        cacheStrategy ?? JustAsyncStrategy(),
        body: body,
        encoding: encoding,
      );

  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    CacheStrategy? cacheStrategy,
  }) =>
      _sendUnstreamed(
        'PUT',
        url,
        headers,
        cacheStrategy ?? JustAsyncStrategy(),
        body: body,
        encoding: encoding,
      );

  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    CacheStrategy? cacheStrategy,
  }) =>
      _sendUnstreamed(
        'PATCH',
        url,
        headers,
        cacheStrategy ?? JustAsyncStrategy(),
        body: body,
        encoding: encoding,
      );

  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    CacheStrategy? cacheStrategy,
  }) =>
      _sendUnstreamed(
        'DELETE',
        url,
        headers,
        cacheStrategy ?? JustAsyncStrategy(),
        body: body,
        encoding: encoding,
      );

  Stream<String> _doStream(
    String method,
    Uri url,
    Map<String, String>? headers, {
    Object? body,
    Encoding? encoding,
  }) async* {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);
      final request = _getRequest(method, url, newHeaders, body, encoding);

      final uuid = const Uuid().v4();
      _loggerRequest(request, body);
      await _inspectorRequest(uuid, request, body);

      final streamResponse = await request.send();
      final stream = streamResponse.stream.transform(utf8.decoder);

      final response = Response.bytes(
        await streamResponse.stream.toBytes(),
        streamResponse.statusCode,
        request: streamResponse.request,
        headers: streamResponse.headers,
        isRedirect: streamResponse.isRedirect,
        persistentConnection: streamResponse.persistentConnection,
        reasonPhrase: streamResponse.reasonPhrase,
      );

      if (await _middlewareResponseOption?.condition(request, response) ??
          false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(response);

      await _authTokenOption?.handleConditionAuthTokenOption(request, response);

      String buffer = '';
      await for (var chunk in stream) {
        buffer += chunk;

        // misalnya format SSE: pisahkan per blok event
        final events = buffer.split('\n\n');
        buffer = events.removeLast(); // sisa event belum lengkap

        for (final event in events) {
          for (final line in event.split('\n')) {
            if (line.startsWith('data:')) {
              final data = line.substring(5).trim();
              final response = Response(
                data,
                streamResponse.statusCode,
                request: streamResponse.request,
                headers: streamResponse.headers,
                isRedirect: streamResponse.isRedirect,
                persistentConnection: streamResponse.persistentConnection,
                reasonPhrase: streamResponse.reasonPhrase,
              );
              _loggerResponse(response);
              yield data;
            }
          }
        }
      }

      await _inspectorResponse(
          uuid,
          Response(
            buffer,
            streamResponse.statusCode,
            request: streamResponse.request,
            headers: streamResponse.headers,
            isRedirect: streamResponse.isRedirect,
            persistentConnection: streamResponse.persistentConnection,
            reasonPhrase: streamResponse.reasonPhrase,
          ));
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (e, stackTrace) {
      _onErrorResponse?.call(e, stackTrace);
      rethrow;
    }
  }

  Stream<String> postStream(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _doStream('POST', url, headers, body: body);

  Stream<String> getStream(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Encoding? encoding,
  }) async* {
    Map<String, String>? queryParameters = body?.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final urlWithBody = queryParameters?.isNotEmpty ?? false
        ? url.replace(queryParameters: queryParameters)
        : url;

    yield* _doStream('GET', urlWithBody, headers);
  }

  /// Return [MultipartRequest] with given [url], [files], [headers], and [body].
  Future<MultipartRequest> _getMultiPartRequest(
    Uri url, {
    required method,
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    var request = MultipartRequest(method, url);
    final keys = files?.keys ?? [];
    for (var key in keys) {
      for (var file in files?[key] ?? []) {
        final path = file?.path ?? '';
        final mimeType = lookupMimeType(path);

        final multipartFile = await MultipartFile.fromPath(
          key,
          path,
          contentType: mimeType == null ? null : MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
      }
    }

    if (!(headers?.keys.any((key) =>
            key.toLowerCase() == HttpHeaders.contentTypeHeader.toLowerCase()) ??
        false)) {
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: "multipart/form-data",
      });
    }
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.fields.addAll(body);
    return request;
  }

  /// Sends an HTTP POST multipart request with the given headers, files and body to the given
  /// URL.
  ///
  /// [files] sets the files of the multipart request. It a [Map<String, File>].
  ///
  /// [headers] sets the headers of the multipart request. It a [Map<String, String>].
  ///
  /// [body] sets the body of the multipart request. It a [Map<String, String>].
  Future<Response> postMultipart(
    Uri url, {
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);

      final request = await _getMultiPartRequest(url,
          method: 'POST', files: files, headers: newHeaders, body: body);
      Response response = await _fetch(request, body, false);

      // do refresh token if condition is true
      if (await _refreshTokenOption?.condition(request, response) ?? false) {
        response = await _doRefreshTokenThenRetry(request, response, body);
      } else if (await _refreshTokenOption?.conditionReFetchWithoutRefreshToken
              ?.call(request, response) ??
          false) {
        response = await _doReFetch(request, response, body, false);
      }

      if (await _middlewareResponseOption?.condition(request, response) ??
          false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (e, stackTrace) {
      _onErrorResponse?.call(e, stackTrace);
      rethrow;
    }
  }

  /// Sends an HTTP PATCH multipart request with the given headers, files and body to the given
  /// URL.
  ///
  /// [files] sets the files of the multipart request. It a [Map<String, File>].
  ///
  /// [headers] sets the headers of the multipart request. It a [Map<String, String>].
  ///
  /// [body] sets the body of the multipart request. It a [Map<String, String>].
  Future<Response> patchMultipart(
    Uri url, {
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);

      final request = await _getMultiPartRequest(url,
          method: 'PATCH', files: files, headers: newHeaders, body: body);
      Response response = await _fetch(request, body, false);

      // do refresh token if condition is true
      if (await _refreshTokenOption?.condition(request, response) ?? false) {
        response = await _doRefreshTokenThenRetry(request, response, body);
      } else if (await _refreshTokenOption?.conditionReFetchWithoutRefreshToken
              ?.call(request, response) ??
          false) {
        response = await _doReFetch(request, response, body, false);
      }

      if (await _middlewareResponseOption?.condition(request, response) ??
          false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (e, stackTrace) {
      _onErrorResponse?.call(e, stackTrace);
      rethrow;
    }
  }

  /// Returns a copy of [request].
  Future<BaseRequest> _copyRequest(BaseRequest request) async {
    BaseRequest requestCopy;

    if (request is Request) {
      requestCopy = Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is MultipartRequest) {
      requestCopy = MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else if (request is StreamedRequest) {
      throw Exception('copying streamed requests is not supported');
    } else {
      throw Exception('request type is unknown, cannot copy');
    }

    final mapEntityToken =
        await _authTokenOption?.getMapEntryToken(request.url);
    request.headers.addAll({
      if (mapEntityToken != null) mapEntityToken.key: mapEntityToken.value,
    });

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
  }

  Future<Response> download(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    CallbackProgressHttp? onProgress,
  }) async {
    Map<String, String>? queryParameters = body?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final urlWithBody = queryParameters?.isNotEmpty ?? false
        ? url.replace(queryParameters: queryParameters)
        : url;

    return _sendStreamed(
      'GET',
      urlWithBody,
      headers,
      onProgress: onProgress,
    );
  }

  /// Sends a non-streaming [Request] and returns a non-streaming [Response],
  /// include put new headers and handle refresh token.
  Future<Response> _sendStreamed(
    String method,
    Uri url,
    Map<String, String>? headers, {
    Object? body,
    Encoding? encoding,
    CallbackProgressHttp? onProgress,
  }) async {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);
      final request = _getRequest(method, url, newHeaders, body, encoding);

      final response = await _fetchDownload(request, body, onProgress);

      if (await _middlewareResponseOption?.condition(request, response) ??
          false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(response);

      await _authTokenOption?.handleConditionAuthTokenOption(request, response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (e, stackTrace) {
      _onErrorResponse?.call(e, stackTrace);
      rethrow;
    }
  }

  /// Sends a non-streaming [Request] and returns a non-streaming [Response].
  Future<Response> _fetchDownload(BaseRequest request, Object? body,
      CallbackProgressHttp? onProgress) async {
    final uuid = const Uuid().v4();
    _loggerRequest(request, body);
    await _inspectorRequest(uuid, request, body);
    final streamResponse = await request.send();
    final contentLength = streamResponse.contentLength ?? 0;
    int received = 0;

    onProgress?.call(received, contentLength);

    List<int> bytes = [];
    final completer = Completer();
    late Response response;
    streamResponse.stream.listen(
      (value) {
        bytes.addAll(value);
        received += value.length;
        onProgress?.call(received, contentLength);
      },
      onError: (e) {
        response = Response.bytes(
          bytes,
          streamResponse.statusCode,
          request: streamResponse.request,
          headers: streamResponse.headers,
          isRedirect: streamResponse.isRedirect,
          persistentConnection: streamResponse.persistentConnection,
          reasonPhrase: streamResponse.reasonPhrase,
        );
        completer.complete();
      },
      onDone: () {
        response = Response.bytes(
          bytes,
          streamResponse.statusCode,
          request: streamResponse.request,
          headers: streamResponse.headers,
          isRedirect: streamResponse.isRedirect,
          persistentConnection: streamResponse.persistentConnection,
          reasonPhrase: streamResponse.reasonPhrase,
        );
        completer.complete();
      },
    );

    await completer.future;

    _loggerResponse(response);
    _inspectorResponse(uuid, response);
    return response;
  }

  /// Throws a [MorphemeException] if [response] is not successfull.
  ///
  /// Throw a [ServerException] if status code >=500
  ///
  /// Throw a [UnauthorizedException] if status code is 401
  ///
  /// Throw a [ClientException] if status code 400 - 499
  ///
  /// Throw a [RedirectionException] if status code 300 - 399
  void _handleErrorResponse(Response response) {
    if (response.statusCode >= 500) {
      throw morpheme_exception.ServerException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    } else if (response.statusCode == 401) {
      throw morpheme_exception.UnauthorizedException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    } else if (response.statusCode >= 400) {
      throw morpheme_exception.ClientException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    } else if (response.statusCode >= 300) {
      throw morpheme_exception.RedirectionException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    }
  }

  /// It returns a string that is a combination of the method and the url
  ///
  /// Args:
  ///   method (String): The HTTP method of the request.
  ///   url (Uri): The URL to be cached.
  ///
  /// Returns:
  ///   A string that is the prefix for the cache key.
  String? _getPrefixKeyCache({
    String? method,
    Uri? url,
  }) {
    String prefix = '';
    if (method != null) {
      prefix += method.toUpperCase();
    }
    if (url != null) {
      prefix += '-${url.hashCode}';
    }

    return prefix.isEmpty ? null : prefix;
  }

  /// It clears the cache
  ///
  /// Args:
  ///   method (String): The HTTP method of the request.
  ///   url (Uri): The URL to clear the cache for.
  Future<void> clearCache({
    String? method,
    Uri? url,
  }) async {
    await _storage.clear(prefix: _getPrefixKeyCache(method: method, url: url));
  }

  void close() {
    try {
      _logger.close();
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
