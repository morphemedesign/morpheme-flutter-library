import 'dart:convert';

import 'package:http/http.dart';

/// Callback refresh token response trigger condition from [condition]
typedef RefreshTokenResponse = Future<void> Function(Response response);

/// Callback refresh token error response trigger condition from [condition] and response is error
/// return [Future<bool>] for retry request or not
typedef RefreshTokenErrorResponse = Future<bool> Function(Response response);

/// Refresh token condition return [Future<bool>] from condition [BaseRequest] or [Response]
typedef ConditionRequireRefreshToken = Future<bool> Function(
    BaseRequest request, Response response);

/// Re fetch condition without refresh token return [Future<bool>] from condition [BaseRequest] or [Response]
typedef ConditionReFetchWithoutRefreshToken = Future<bool> Function(
    BaseRequest request, Response response);

/// Function async for get headers http call
typedef GetHeaders = Future<Map<String, String>?> Function();

/// Function async for get body http call
typedef GetBody = Future<Map<String, String>?> Function();

/// Enum for method http call refresh token
enum RefreshTokenMethod {
  get('GET'),
  post('POST');

  const RefreshTokenMethod(this.method);

  final String method;

  @override
  String toString() => method;
}

/// [RefreshTokenOption] handle refresh token authorization
final class RefreshTokenOption {
  RefreshTokenOption({
    required this.method,
    required this.url,
    this.getHeaders,
    this.getBody,
    this.encoding,
    required this.condition,
    required this.onResponse,
    this.onErrorResponse,
    this.conditionReFetchWithoutRefreshToken,
  });

  /// Method http call refresh token
  final RefreshTokenMethod method;

  /// Url for send http call refresh token
  final Uri url;

  /// Function async get headers refresh token
  final GetHeaders? getHeaders;

  /// Function async get body refresh token
  final GetBody? getBody;

  /// [encoding] and used as the body of the request. The content-type of the
  /// request will default to "text/plain".
  ///
  /// If [getBody] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// If [getBody] is a Map, it's encoded as form fields using [encoding]. The
  /// content-type of the request will be set to
  /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  /// [encoding] defaults to [utf8].
  final Encoding? encoding;

  /// Condition for trigger [RefreshTokenResponse]
  final ConditionRequireRefreshToken condition;

  /// Condition for trigger re fetch without refresh token
  final ConditionReFetchWithoutRefreshToken?
      conditionReFetchWithoutRefreshToken;

  /// Callbak from [condition] is true
  final RefreshTokenResponse onResponse;

  /// Callbak from [condition] is true and response is error
  final RefreshTokenErrorResponse? onErrorResponse;
}
