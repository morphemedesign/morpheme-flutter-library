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

/// Callback function for progress updates during HTTP requests.
typedef CallbackProgressHttp = void Function(
    int received, int totalContentLength);

/// Callback function for handling error responses.
typedef CallbackErrorResponse = void Function(
    BaseRequest request, Response response);

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
    CallbackErrorResponse? onErrorResponse,
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

  /// The storage used for caching responses.
  final Storage _storage;

  /// The callback function to handle error responses.
  final CallbackErrorResponse? _onErrorResponse;

  /// Completer used to handle refresh token requests.
  Completer<void>? _refreshCompleter;

  // Stores callbacks to execute after refresh
  final List<Function> _pendingRequests = [];

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

  /// Generate a unique key for caching based on the request method, URL, headers, and body.
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
          if (_refreshCompleter != null &&
              _refreshCompleter?.isCompleted == false) {
            // If refresh in progress, we wait, then retry manually
            final completer = Completer<Response>();

            _pendingRequests.add(() async {
              try {
                final newResponse =
                    await _fetch(await _copyRequest(request), body, true);
                completer.complete(newResponse);
              } catch (e) {
                completer.completeError(e);
              }
            });

            return completer.future;
          }

          Response response = await _fetch(request, body);

          // do refresh token if condition is true
          if (await _refreshTokenOption?.condition(request, response) ??
              false) {
            response = await _doRefreshTokenThenRetry(request, response, body);
          }

          return response;
        },
      );

      if (await _middlewareResponseOption?.condition(request, response) ??
          false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(request, response);

      await _authTokenOption?.handleConditionAuthTokenOption(request, response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (_, __) {
      rethrow;
    }
  }

  /// Do refresh token then if success retry the previous request
  /// with given [reqeust], previous [response] and previous [body].
  Future<Response> _doRefreshTokenThenRetry(
      BaseRequest request, Response response, Object? body) async {
    await _handleRefreshToken();

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

  /// Handle error response from [request] and [response].
  /// If the response status code is not 2xx,
  /// it will throw an exception or call the [onErrorResponse] callback.
  /// If the response status code is 2xx, it will return normally.
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

  /// Sends a non-streaming [Request] with the HTTP GET method and returns a non-streaming [Response].
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

  /// Sends a non-streaming [Request] with the HTTP POST method and returns a non-streaming [Response].
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

  /// Sends a non-streaming [Request] with the HTTP PUT method and returns a non-streaming [Response].
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

  /// Sends a non-streaming [Request] with the HTTP PATCH method and returns a non-streaming [Response].
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

  /// Sends a non-streaming [Request] with the HTTP DELETE method and returns a non-streaming [Response].
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

  /// Sends a Server-Sent Events (SSE) stream request and returns a stream of [String].
  ///
  /// The [splitBuffer] parameter is used to split the buffer into separate events,
  /// the [splitEvent] parameter is used to split each event into lines,
  /// the [dataStartWith] parameter is used to identify the start of the data in each line,
  /// the [substringData] parameter is used to get the actual data from the line.
  /// Args:
  ///   - [method] (String): The HTTP method to use for the request (e.g., 'GET', 'POST').
  ///   - [url] (Uri): The URL to send the request to.
  ///   - [headers] (Map&ltString, String&gt?): Optional headers to include in the request.
  ///   - [splitBuffer] (String): The string used to split the buffer into separate events.
  ///   - [splitEvent] (String): The string used to split each event into lines.
  ///   - [dataStartWith] (String): The string that indicates the start of the data in each line.
  ///   - [substringData] (int): The number of characters to skip at the start of the data line.
  /// Returns:
  ///   A [Stream<String>] that emits the data from each event as a string.
  Stream<String> _doStreamSse(
    String method,
    Uri url,
    Map<String, String>? headers, {
    String splitBuffer = '\n\n',
    String splitEvent = '\n',
    String dataStartWith = 'data:',
    int substringData = 5,
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

      // ini kenapa kosong, karena untuk handling header awalan saja di sse
      // kenapa tidak ambil dari bodynya/bytes streamResponse.stream.toBytes(), karena varibale streamResponse.stream
      // hanya bisa diakses sekali saja, nanti akan ada error Stream has already been listened to.

      final response = Response.bytes(
        utf8.encode('{}'),
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

      _handleErrorResponse(request, response);
      await _authTokenOption?.handleConditionAuthTokenOption(request, response);

      String buffer =
          ''; // Hanya sisa data dari chunk terakhir (biasanya 1 event partial)
      String fullRawData = ''; // untuk menyimpan data lengkap dari stream

      await for (var chunk in stream) {
        buffer += chunk;
        fullRawData += chunk;

        // misalnya format SSE: pisahkan per blok event
        final events = buffer.split(splitBuffer);
        buffer = events.removeLast(); // sisa event belum lengkap

        for (final event in events) {
          for (final line in event.split(splitEvent)) {
            if (line.startsWith(dataStartWith)) {
              final data = line.substring(substringData).trim();
              _loggerResponse(Response(
                data,
                streamResponse.statusCode,
                request: streamResponse.request,
                headers: streamResponse.headers,
                isRedirect: streamResponse.isRedirect,
                persistentConnection: streamResponse.persistentConnection,
                reasonPhrase: streamResponse.reasonPhrase,
              ));
              yield data;
            }
          }
        }
      }

      await _inspectorResponse(
          uuid,
          Response(
            fullRawData,
            streamResponse.statusCode,
            request: streamResponse.request,
            headers: streamResponse.headers,
            isRedirect: streamResponse.isRedirect,
            persistentConnection: streamResponse.persistentConnection,
            reasonPhrase: streamResponse.reasonPhrase,
          ));
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (_, __) {
      rethrow;
    }
  }

  /// Sends a Server-Sent Events (SSE) stream request with the HTTP GET method
  /// and returns a stream of [String].
  /// Args:
  /// - [url] (Uri): The URL to send the request to.
  /// - [headers] (Map&ltString, String&gt?): Optional headers to include in the request.
  /// - [body] (Map&ltString, dynamic&gt?): The body of the request, which can be a Map of query parameters.
  /// - [encoding] (Encoding?): The encoding to use for the request body.
  /// Returns:
  /// A [Stream&ltString&gt] that emits the data from each event as a string.
  /// If the request fails, it will throw a [NoInternetException] if there is no internet connection,
  /// or call the provided [onErrorResponse] callback with the error and stack trace.
  /// If the request is successful, it will yield the data from each event as a string.
  Stream<String> getSse(
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

    yield* _doStreamSse('GET', urlWithBody, headers);
  }

  /// Sends a Server-Sent Events (SSE) stream request with the HTTP POST method
  /// and returns a stream of [String].
  /// Args:
  /// - [url] (Uri): The URL to send the request to.
  /// - [headers] (Map&ltString, String&gt?): Optional headers to include in the request.
  /// - [body] (Object?): The body of the request, which can be a String, List, or Map.
  /// - [encoding] (Encoding?): The encoding to use for the request body.
  /// Returns:
  /// A [Stream&ltString&gt] that emits the data from each event as a string.
  /// If the request fails, it will throw a [NoInternetException] if there is no internet connection,
  /// or call the provided [onErrorResponse] callback with the error and stack trace.
  /// If the request is successful, it will yield the data from each event as a string.
  Stream<String> postSse(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _doStreamSse('POST', url, headers, body: body);

  /// Sends a Server-Sent Events (SSE) stream request with the HTTP PUT method
  /// and returns a stream of [String].
  /// Args:
  /// - [url] (Uri): The URL to send the request to.
  /// - [headers] (Map&ltString, String&gt?): Optional headers to include in the request.
  /// - [body] (Object?): The body of the request, which can be a String, List, or Map.
  /// - [encoding] (Encoding?): The encoding to use for the request body.
  /// Returns:
  /// A [Stream&ltString&gt] that emits the data from each event as a string.
  /// If the request fails, it will throw a [NoInternetException] if there is no internet connection,
  /// or call the provided [onErrorResponse] callback with the error and stack trace.
  /// If the request is successful, it will yield the data from each event as a string.
  Stream<String> putSse(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _doStreamSse('PUT', url, headers, body: body);

  /// Sends a Server-Sent Events (SSE) stream request with the HTTP PATCH method
  /// and returns a stream of [String].
  /// Args:
  /// - [url] (Uri): The URL to send the request to.
  /// - [headers] (Map&ltString, String&gt?): Optional headers to include in the request.
  /// - [body] (Object?): The body of the request, which can be a String, List, or Map.
  /// - [encoding] (Encoding?): The encoding to use for the request body.
  /// Returns:
  /// A [Stream&ltString&gt] that emits the data from each event as a string.
  /// If the request fails, it will throw a [NoInternetException] if there is no internet connection,
  /// or call the provided [onErrorResponse] callback with the error and stack trace.
  /// If the request is successful, it will yield the data from each event as a string.
  Stream<String> patchSse(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _doStreamSse('PATCH', url, headers, body: body);

  /// Sends a Server-Sent Events (SSE) stream request with the HTTP DELETE method
  /// and returns a stream of [String].
  /// Args:
  /// - [url] (Uri): The URL to send the request to.
  /// - [headers] (Map&ltString, String&gt?): Optional headers to include in the request.
  /// - [body] (Object?): The body of the request, which can be a String, List, or Map.
  /// - [encoding] (Encoding?): The encoding to use for the request body.
  /// Returns:
  /// A [Stream&ltString&gt] that emits the data from each event as a string.
  /// If the request fails, it will throw a [NoInternetException] if there is no internet connection,
  /// or call the provided [onErrorResponse] callback with the error and stack trace.
  /// If the request is successful, it will yield the data from each event as a string.
  Stream<String> deleteSse(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      _doStreamSse('DELETE', url, headers, body: body);

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
      for (var file in files?[key] ?? <File>[]) {
        final path = file.path;
        final mimeType = lookupMimeType(path);

        final multipartFile = MultipartFile.fromBytes(
          key,
          file.readAsBytesSync(),
          contentType: mimeType == null ? null : MediaType.parse(mimeType),
          filename: file.path.split('/').last,
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

  /// Sends an HTTP multipart request with the given method, headers, files and body to the given
  /// URL.
  ///
  /// [url] is the URL to send the request to.
  ///
  /// [method] is the HTTP method to use (e.g. 'POST', 'PATCH').
  ///
  /// [files] sets the files of the multipart request. It a [Map<String, File>].
  ///
  /// [headers] sets the headers of the multipart request. It a [Map<String, String>].
  ///
  /// [body] sets the body of the multipart request. It a [Map<String, String>].
  Future<Response> _multipart(
    Uri url,
    String method, {
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);

      final request = await _getMultiPartRequest(url,
          method: method, files: files, headers: newHeaders, body: body);

      Response response;

      if (_refreshCompleter != null &&
          _refreshCompleter?.isCompleted == false) {
        // If refresh in progress, we wait, then retry manually
        final completer = Completer<Response>();

        _pendingRequests.add(() async {
          try {
            final newResponse = await _fetch(
                await _copyRequest(request, files: files), body, false);
            completer.complete(newResponse);
          } catch (e) {
            completer.completeError(e);
          }
        });

        response = await completer.future;
      } else {
        response = await _fetch(request, body, false);

        // do refresh token if condition is true
        if (await _refreshTokenOption?.condition(request, response) ?? false) {
          response = await _doRefreshTokenThenRetry(request, response, body);
        }
      }

      if (await _middlewareResponseOption?.condition(request, response) ??
          false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(request, response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (_, __) {
      rethrow;
    }
  }

  /// Sends an HTTP GET multipart request with the given method, headers, files and body to the given
  /// URL.
  ///
  /// [url] is the URL to send the request to.
  ///
  /// [files] sets the files of the multipart request. It a [Map<String, File>].
  ///
  /// [headers] sets the headers of the multipart request. It a [Map<String, String>].
  ///
  /// [body] sets the body of the multipart request. It a [Map<String, String>].
  Future<Response> getMultipart(
    Uri url, {
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) =>
      _multipart(
        url,
        'GET',
        files: files,
        headers: headers,
        body: body,
      );

  /// Sends an HTTP POST multipart request with the given method, headers, files and body to the given
  /// URL.
  ///
  /// [url] is the URL to send the request to.
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
  }) =>
      _multipart(
        url,
        'POST',
        files: files,
        headers: headers,
        body: body,
      );

  /// Sends an HTTP PATCH multipart request with the given method, headers, files and body to the given
  /// URL.
  ///
  /// [url] is the URL to send the request to.
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
  }) =>
      _multipart(
        url,
        'PATCH',
        files: files,
        headers: headers,
        body: body,
      );

  /// Sends an HTTP PUT multipart request with the given method, headers, files and body to the given
  /// URL.
  ///
  /// [url] is the URL to send the request to.
  ///
  /// [files] sets the files of the multipart request. It a [Map<String, File>].
  ///
  /// [headers] sets the headers of the multipart request. It a [Map<String, String>].
  ///
  /// [body] sets the body of the multipart request. It a [Map<String, String>].
  Future<Response> putMultipart(
    Uri url, {
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) =>
      _multipart(
        url,
        'PUT',
        files: files,
        headers: headers,
        body: body,
      );

  /// Sends an HTTP DELETE multipart request with the given method, headers, files and body to the given
  /// URL.
  ///
  /// [url] is the URL to send the request to.
  ///
  /// [files] sets the files of the multipart request. It a [Map<String, File>].
  ///
  /// [headers] sets the headers of the multipart request. It a [Map<String, String>].
  ///
  /// [body] sets the body of the multipart request. It a [Map<String, String>].
  Future<Response> deleteMultipart(
    Uri url, {
    Map<String, List<File>>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) =>
      _multipart(
        url,
        'DELETE',
        files: files,
        headers: headers,
        body: body,
      );

  /// Returns a copy of [request].
  Future<BaseRequest> _copyRequest(
    BaseRequest request, {
    Map<String, List<File>>? files,
  }) async {
    BaseRequest requestCopy;

    if (request is Request) {
      requestCopy = Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is MultipartRequest) {
      MultipartRequest multipartRequest =
          MultipartRequest(request.method, request.url)
            ..fields.addAll(request.fields);
      final keys = files?.keys ?? [];
      for (var key in keys) {
        for (var file in files?[key] ?? <File>[]) {
          final path = file.path;
          final mimeType = lookupMimeType(path);

          final multipartFile = MultipartFile.fromBytes(
            key,
            file.readAsBytesSync(),
            contentType: mimeType == null ? null : MediaType.parse(mimeType),
            filename: file.path.split('/').last,
          );

          multipartRequest.files.add(multipartFile);
        }
      }
      requestCopy = multipartRequest;
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

  /// Downloads a file from the given [url] and returns a [Response].
  /// The [url] should be a valid URI,
  /// and the [headers] and [body] parameters are optional.
  /// The [onProgress] callback is called with the number of bytes received and the total content length.
  /// If the request fails, it will throw a [NoInternetException] if there is no internet connection,
  /// or call the provided [onErrorResponse] callback with the error and stack trace.
  /// If the request is successful, it will return a [Response] with the downloaded file data.
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

      _handleErrorResponse(request, response);

      await _authTokenOption?.handleConditionAuthTokenOption(request, response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (_, __) {
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
  void _handleErrorResponse(BaseRequest request, Response response) {
    morpheme_exception.MorphemeException? exception;
    if (response.statusCode >= 500) {
      exception = morpheme_exception.ServerException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    } else if (response.statusCode == 401) {
      exception = morpheme_exception.UnauthorizedException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    } else if (response.statusCode >= 400) {
      exception = morpheme_exception.ClientException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    } else if (response.statusCode >= 300) {
      exception = morpheme_exception.RedirectionException(
        statusCode: response.statusCode,
        jsonBody: response.body,
      );
    }

    if (exception != null) {
      _onErrorResponse?.call(request, response);
      throw exception;
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

  /// Handles the refresh token logic.
  Future<void> _handleRefreshToken() async {
    if (_refreshCompleter != null) {
      // A refresh is already in progress, wait for it to complete
      await _refreshCompleter!.future;
      return;
    }

    _refreshCompleter = Completer<void>();

    try {
      await _sendRefreshToken(_refreshTokenOption!);

      // Refresh token successful, complete the completer
      _refreshCompleter?.complete();
      for (var retry in _pendingRequests) {
        retry();
      }
    } catch (e) {
      _refreshCompleter?.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.clear();
      _refreshCompleter = null;
    }
  }
}
