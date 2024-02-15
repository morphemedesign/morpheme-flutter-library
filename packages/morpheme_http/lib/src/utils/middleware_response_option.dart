import 'package:http/http.dart';

/// Callback middleware response trigger condition from [condition]
typedef OnMiddlewareResponse = Future<void> Function(Response response);

/// Middleware response condition return [bool] from condition [BaseRequest] or [Response]
typedef ConditionMiddlewareResponse = bool Function(
    BaseRequest request, Response response);

final class MiddlewareResponseOption {
  MiddlewareResponseOption({
    required this.condition,
    required this.onResponse,
  });

  /// Condition for trigger [OnMiddlewareResponse]
  final ConditionMiddlewareResponse condition;

  /// Callbak from [condition] is true
  final OnMiddlewareResponse onResponse;
}
