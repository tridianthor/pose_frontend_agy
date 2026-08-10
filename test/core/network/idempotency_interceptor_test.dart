import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/idempotency_interceptor.dart';

void main() {
  test('IdempotencyInterceptor attaches UUID v4 header on POST requests', () {
    final interceptor = IdempotencyInterceptor();
    final options = RequestOptions(method: 'POST', path: '/api/sales/');
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.headers.containsKey('Idempotency-Key'), isTrue);
    final key = options.headers['Idempotency-Key'] as String;
    expect(key.length, equals(36)); // Standard UUID length (8-4-4-4-12)
  });

  test('IdempotencyInterceptor does NOT attach header on GET requests', () {
    final interceptor = IdempotencyInterceptor();
    final options = RequestOptions(method: 'GET', path: '/api/products/');
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.headers.containsKey('Idempotency-Key'), isFalse);
  });
}
