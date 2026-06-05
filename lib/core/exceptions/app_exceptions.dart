class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  AuthenticationException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'AUTH_ERROR',
    originalException: originalException,
  );
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'NETWORK_ERROR',
    originalException: originalException,
  );
}

class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({
    required String message,
    String? code,
    dynamic originalException,
    this.errors,
  }) : super(
    message: message,
    code: code ?? 'VALIDATION_ERROR',
    originalException: originalException,
  );
}

class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required String message,
    String? code,
    dynamic originalException,
    this.statusCode,
  }) : super(
    message: message,
    code: code ?? 'SERVER_ERROR',
    originalException: originalException,
  );
}

class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'CACHE_ERROR',
    originalException: originalException,
  );
}

class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'NOT_FOUND',
    originalException: originalException,
  );
}

class TimeoutException extends AppException {
  TimeoutException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'TIMEOUT',
    originalException: originalException,
  );
}
