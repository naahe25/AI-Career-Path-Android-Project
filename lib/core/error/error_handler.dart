import '../exceptions/app_exceptions.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    appLogger.e('Error: $error', error: error, stackTrace: stackTrace);

    if (error is AppException) {
      return error;
    }

    if (error is TimeoutException) {
      return TimeoutException(
        message: 'Request timed out. Please try again.',
        originalException: error,
      );
    }

    if (error is NetworkException) {
      return NetworkException(
        message: 'Network error occurred.',
        originalException: error,
      );
    }

    if (error is SocketException) {
      return NetworkException(
        message: 'Network connection failed.',
        originalException: error,
      );
    }

    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format.',
        originalException: error,
      );
    }

    if (error is NoSuchMethodError) {
      return ServerException(
        message: 'Server error occurred.',
        statusCode: 500,
        originalException: error,
      );
    }

    return AppException(
      message: error.toString().isEmpty ? 'An unknown error occurred.' : error.toString(),
      originalException: error,
    );
  }

  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

// For imports
class SocketException implements Exception {
  final String message;
  SocketException(this.message);
}
