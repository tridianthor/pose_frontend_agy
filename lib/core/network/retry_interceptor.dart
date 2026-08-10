import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryInterval = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Only retry GET requests on transient network or 5xx server errors
    if (requestOptions.method.toUpperCase() == 'GET' && _shouldRetry(err)) {
      int retryCount = requestOptions.extra['retry_count'] ?? 0;
      if (retryCount < maxRetries) {
        retryCount++;
        requestOptions.extra['retry_count'] = retryCount;

        await Future.delayed(retryInterval);

        try {
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return super.onError(e, handler);
          }
        }
      }
    }
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response != null &&
            err.response!.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
