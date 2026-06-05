import 'dart:async' as async;

import '../exceptions/app_exceptions.dart';

class ErrorMessages {
  static const String networkError = 'Network connection failed. Please check your internet connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String authenticationError = 'Authentication failed. Please log in again.';
  static const String validationError = 'Please check your input and try again.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String unauthorizedError = 'You are not authorized to perform this action.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String loadingError = 'Failed to load data. Please try again.';
  static const String savingError = 'Failed to save changes. Please try again.';
  static const String deletingError = 'Failed to delete item. Please try again.';
  static const String updatingError = 'Failed to update data. Please try again.';
  static const String emptyError = 'No data available.';
  static const String offlineError = 'You are offline. Some features may not be available.';

  static String getErrorMessage(Object error) {
    if (error is async.TimeoutException || error is TimeoutException) {
      return timeoutError;
    } else if (error is NetworkException) {
      return networkError;
    } else if (error is AuthenticationException) {
      return authenticationError;
    } else if (error is ValidationException) {
      return validationError;
    } else if (error is NotFoundException) {
      return notFoundError;
    } else if (error is ServerException) {
      return serverError;
    } else if (error is AppException) {
      return error.message;
    }
    return unknownError;
  }

  static String getFieldError(Map<String, String>? errors, String field) {
    return errors?[field] ?? '';
  }
}
