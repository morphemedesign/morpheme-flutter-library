import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:morpheme_http/src/utils/auth_token_option.dart';
import 'package:morpheme_http/src/utils/middleware_response_option.dart';
import 'package:morpheme_http/src/utils/refresh_token_option.dart';
import 'package:morpheme_inspector/morpheme_inspector.dart'
    show MorphemeInspector, Inspector, RequestInspector, ResponseInspector;
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'cache_strategy/cache_strategy.dart';
import 'errors/morpheme_exceptions.dart' as morpheme_exception;

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
  })  : _timeout = timeout,
        _morphemeInspector = morphemeInspector,
        _showLog = showLog,
        _headers = headers,
        _authTokenOption = authTokenOption,
        _refreshTokenOption = refreshTokenOption,
        _middlewareResponseOption = middlewareResponseOption,
        _storage = CacheStorage();

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
    try {
      body = json.decode(response.body);
    } catch (e) {
      body = response.body;
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
  Future<Response> _fetch(BaseRequest request, Object? body) async {
    final uuid = const Uuid().v4();
    _loggerRequest(request, body);
    await _inspectorRequest(uuid, request, body);
    final streamResponse = await request.send().timeout(
      Duration(milliseconds: _timeout),
      onTimeout: () async {
        await _inspectorResponseTimeout(uuid);
        throw morpheme_exception.TimeoutException();
      },
    );
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
          if (_refreshTokenOption?.condition(request, response) ?? false) {
            response = await _doRefreshTokenThenRetry(request, response, body);
          }

          if (_middlewareResponseOption?.condition(request, response) ??
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
    } catch (e) {
      rethrow;
    }
  }

  /// Do refresh token then if success retry the previous request
  /// with given [reqeust], previous [response] and previous [body].
  Future<Response> _doRefreshTokenThenRetry(
      BaseRequest request, Response response, Object? body) async {
    await _sendRefreshToken(_refreshTokenOption!);

    final copyRequest = _copyRequest(request);
    return _fetch(copyRequest, body);
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
    _handleRefreshTokenErrorResponse(
      response,
    );
    await refreshTokenOption.onResponse(response);
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

  /// Return [MultipartRequest] with given [url], [files], [headers], and [body].
  Future<MultipartRequest> _getMultiPartRequest(
    Uri url, {
    Map<String, File>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    var request = MultipartRequest('POST', url);
    final keys = files?.keys ?? [];
    for (var key in keys) {
      final multipartFile =
          await MultipartFile.fromPath(key, files?[key]?.path ?? '');
      request.files.add(multipartFile);
    }

    if (!(headers != null &&
        headers.containsKey(HttpHeaders.contentTypeHeader))) {
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
    Map<String, File>? files,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    try {
      final newHeaders = await _putIfAbsentHeader(url, headers);

      final request = await _getMultiPartRequest(url,
          files: files, headers: newHeaders, body: body);
      Response response = await _fetch(request, body);

      // do refresh token if condition is true
      if (_refreshTokenOption?.condition(request, response) ?? false) {
        response = await _doRefreshTokenThenRetry(request, response, body);
      }

      if (_middlewareResponseOption?.condition(request, response) ?? false) {
        await _middlewareResponseOption?.onResponse(response);
      }

      _handleErrorResponse(response);
      return response;
    } on SocketException {
      throw morpheme_exception.NoInternetException();
    } catch (e) {
      rethrow;
    }
  }

  /// Returns a copy of [request].
  BaseRequest _copyRequest(BaseRequest request) {
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

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
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

  /// Throws an [RefreshTokenException] if [response] is not successfull.
  void _handleRefreshTokenErrorResponse(Response response) {
    if (response.statusCode >= 300) {
      throw morpheme_exception.RefreshTokenException(
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
