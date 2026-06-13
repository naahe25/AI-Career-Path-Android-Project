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
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'AUTH_ERROR');
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'NETWORK_ERROR');
}

class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({
    required super.message,
    String? code,
    super.originalException,
    this.errors,
  }) : super(code: code ?? 'VALIDATION_ERROR');
}

class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required super.message,
    String? code,
    super.originalException,
    this.statusCode,
  }) : super(code: code ?? 'SERVER_ERROR');
}

class CacheException extends AppException {
  CacheException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'CACHE_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'NOT_FOUND');
}

class TimeoutException extends AppException {
  TimeoutException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'TIMEOUT');
}
