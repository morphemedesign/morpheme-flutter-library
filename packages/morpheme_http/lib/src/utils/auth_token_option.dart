import 'package:http/http.dart';

/// Function async for get token can take from local data or static token
typedef GetToken = Future<String?> Function();

/// Callback auth token response trigger condition from [authCondition]
typedef OnAuthTokenResponse = Future<void> Function(Response response);

/// Auth token condition return [Future<bool>] from condition [BaseRequest] or [Response]
typedef AuthCondition = Future<bool> Function(
    BaseRequest request, Response response);

/// Clear token condition return [Future<bool>] from condition [BaseRequest] or [Response]
typedef ClearCondition = Future<bool> Function(
    BaseRequest request, Response response);

/// Callback clear token response trigger condition from [clearCondition]
typedef OnClearToken = Future<void> Function();

/// [AuthTokenOption] handle token authorization
final class AuthTokenOption {
  AuthTokenOption({
    this.typeHeader = 'Authorization',
    this.prefixHeader = 'Bearer',
    required this.getToken,
    required this.authCondition,
    required this.onAuthTokenResponse,
    this.clearCondition,
    this.onClearToken,
    this.excludeEndpointUsageToken,
  });

  /// Type header for auth default value 'Authorization'
  final String typeHeader;

  /// Prefix header for auth default value 'Bearer'
  final String prefixHeader;

  /// Function async to get token
  final GetToken getToken;

  /// Condition for trigger [OnAuthTokenResponse]
  final AuthCondition authCondition;

  /// Callbak from [authCondition] is true
  final OnAuthTokenResponse onAuthTokenResponse;

  /// Condition for trigger [OnClearToken]
  final ClearCondition? clearCondition;

  /// Callbak from [OnClearToken] is true
  final OnClearToken? onClearToken;

  /// Exclude endpoint to usage authorization
  final List<RegExp>? excludeEndpointUsageToken;
}

/// Extension for handling advantage [AuthTokenOption]
extension AuthTokenOptionExtension on AuthTokenOption {
  /// Get map entry token return [MapEntry]
  ///
  /// if [url] containts in [excludeEndpointUsageToken] then return null
  ///
  Future<MapEntry?> getMapEntryToken(Uri url) async {
    if (excludeEndpointUsageToken
            ?.where((element) => element.hasMatch(url.toString()))
            .isNotEmpty ??
        true) {
      return null;
    }

    final token = await getToken();
    return MapEntry(
      typeHeader,
      prefixHeader.isNotEmpty ? '$prefixHeader $token' : token,
    );
  }

  /// Hanlde condition from auth token option
  ///
  /// if [authCondition] is true then call [onAuthTokenResponse]
  /// if [clearCondition] is true then call [onClearToken]
  ///
  Future<void> handleConditionAuthTokenOption(
    BaseRequest request,
    Response response,
  ) async {
    if (await authCondition(request, response)) {
      await onAuthTokenResponse.call(response);
    }
    if (await clearCondition?.call(request, response) ?? false) {
      await onClearToken?.call();
    }
  }
}
