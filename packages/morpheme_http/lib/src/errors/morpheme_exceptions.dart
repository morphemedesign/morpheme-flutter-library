import '../../morpheme_http.dart';

/// The interface for Morpheme HTTP Exception.
sealed class MorphemeException {
  MorphemeException({
    this.statusCode,
    this.jsonBody,
  });

  final int? statusCode;
  final String? jsonBody;

  /// Convert to [MorphemeFailure].
  MorphemeFailure toMorphemeFailure();

  /// Convert status code to name.
  String toStatusCodeName() {
    switch (statusCode) {
      case 300:
        return 'Multiple Choices';
      case 301:
        return 'Moved Permanently';
      case 302:
        return 'Found (Previously "Moved Temporarily")';
      case 303:
        return 'See Other';
      case 304:
        return 'Not Modified';
      case 305:
        return 'Use Proxy';
      case 306:
        return 'Switch Proxy';
      case 307:
        return 'Temporary Redirect';
      case 308:
        return 'Permanent Redirect';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 402:
        return 'Payment Required';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 405:
        return 'Method Not Allowed';
      case 406:
        return 'Not Acceptable';
      case 407:
        return 'Proxy Authentication Required';
      case 408:
        return 'Request Timeout';
      case 409:
        return 'Conflict';
      case 410:
        return 'Gone';
      case 411:
        return 'Length Required';
      case 412:
        return 'Precondition Failed';
      case 413:
        return 'Payload Too Large';
      case 414:
        return 'URI Too Long';
      case 415:
        return 'Unsupported Media Type';
      case 416:
        return 'Range Not Satisfiable';
      case 417:
        return 'Expectation Failed';
      case 418:
        return 'I\'m a Teapot';
      case 421:
        return 'Misdirected Request';
      case 422:
        return 'Unprocessable Entity';
      case 423:
        return 'Locked';
      case 424:
        return 'Failed Dependency';
      case 425:
        return 'Too Early';
      case 426:
        return 'Upgrade Required';
      case 428:
        return 'Precondition Required';
      case 429:
        return 'Too Many Requests';
      case 431:
        return 'Request Header Fields Too Large';
      case 451:
        return 'Unavailable For Legal Reasons';
      case 500:
        return 'Internal Server Error';
      case 501:
        return 'Not Implemented';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Timeout';
      case 505:
        return 'HTTP Version Not Supported';
      case 506:
        return 'Variant Also Negotiates';
      case 507:
        return 'Insufficient Storage';
      case 508:
        return 'Loop Detected';
      case 510:
        return 'Not Extended';
      case 511:
        return 'Network Authentication Required';
      default:
        return 'Unknown Error';
    }
  }
}

/// An exception caused by an error status code 300-399.
final class RedirectionException extends MorphemeException {
  RedirectionException({
    required super.statusCode,
    required super.jsonBody,
  });

  @override
  MorphemeFailure toMorphemeFailure() {
    return RedirectionFailure(
      toString(),
      statusCode: statusCode,
      jsonBody: jsonBody,
    );
  }

  @override
  String toString() =>
      'RedirectionException with status code $statusCode or ${toStatusCodeName()}';
}

/// An exception caused by an error status code 400-499.
final class ClientException extends MorphemeException {
  ClientException({
    required super.statusCode,
    required super.jsonBody,
  });

  @override
  MorphemeFailure toMorphemeFailure() {
    return ClientFailure(
      toString(),
      statusCode: statusCode,
      jsonBody: jsonBody,
    );
  }

  @override
  String toString() =>
      'ClientException with status code $statusCode or ${toStatusCodeName()}';
}

/// An exception caused by an error status code 500-599.
final class ServerException extends MorphemeException {
  ServerException({
    required super.statusCode,
    required super.jsonBody,
  });

  @override
  MorphemeFailure toMorphemeFailure() {
    return ServerFailure(
      toString(),
      statusCode: statusCode,
      jsonBody: jsonBody,
    );
  }

  @override
  String toString() =>
      'ServerException with status code $statusCode or ${toStatusCodeName()}';
}

/// An exception caused by an error status code 401.
final class UnauthorizedException extends MorphemeException {
  UnauthorizedException({
    required super.statusCode,
    required super.jsonBody,
  });

  @override
  MorphemeFailure toMorphemeFailure() {
    return UnauthorizedFailure(
      toString(),
      statusCode: statusCode,
      jsonBody: jsonBody,
    );
  }

  @override
  String toString() =>
      'UnauthorizedException with status code $statusCode or ${toStatusCodeName()}';
}

/// An exception caused by an error timeout fetch http client.
final class TimeoutException extends MorphemeException {
  @override
  MorphemeFailure toMorphemeFailure() {
    return TimeoutFailure(toString());
  }

  @override
  String toString() =>
      'TimeoutException timeout request and receive response api';
}

/// An exception caused by an error in internal app.
final class InternalException extends MorphemeException {
  @override
  MorphemeFailure toMorphemeFailure() {
    return InternalFailure(toString());
  }

  @override
  String toString() => 'InternalException something error with internal code';
}

/// An exception caused by an error status code 300-599 in do refresh token.
final class RefreshTokenException extends MorphemeException {
  RefreshTokenException({
    required super.statusCode,
    required super.jsonBody,
  });

  @override
  MorphemeFailure toMorphemeFailure() {
    return ServerFailure(
      toString(),
      statusCode: statusCode,
      jsonBody: jsonBody,
    );
  }

  @override
  String toString() =>
      'RefreshTokenException with status code $statusCode or ${toStatusCodeName()}';
}

/// An exception caused by an error no internet connection.
final class NoInternetException extends MorphemeException {
  @override
  MorphemeFailure toMorphemeFailure() {
    return NoInternetFailure(toString());
  }

  @override
  String toString() => 'No internet connection';
}

/// An exception caused by an error no found data in cache.
final class CacheException extends MorphemeException {
  @override
  MorphemeFailure toMorphemeFailure() {
    return CacheFailure(toString());
  }

  @override
  String toString() => 'No found data in cache';
}
