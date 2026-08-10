import 'package:flutter/foundation.dart';

@immutable
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed. Please check your connection.',
    super.code = 'NETWORK_ERROR',
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'An error occurred on the server. Please try again.',
    super.code = 'SERVER_ERROR',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please check your credentials.',
    super.code = 'AUTH_ERROR',
  });
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({
    super.message = 'Validation error occurred.',
    super.code = 'VALIDATION_ERROR',
    this.errors,
  });
}

class InsufficientStockFailure extends Failure {
  final String productName;
  final int availableStock;

  const InsufficientStockFailure({
    required this.productName,
    required this.availableStock,
    super.message = 'Insufficient stock for product.',
    super.code = 'INSUFFICIENT_STOCK',
  });
}
