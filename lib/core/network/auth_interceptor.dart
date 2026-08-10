import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService secureStorage;
  final Dio dio;
  final Function()? onUnauthenticated;

  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
    this.onUnauthenticated,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding auth header for login or refresh requests
    if (options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.refresh)) {
      return handler.next(options);
    }

    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiEndpoints.login) &&
        !err.requestOptions.path.contains(ApiEndpoints.refresh)) {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: dio.options.baseUrl,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final response = await refreshDio.post(
            ApiEndpoints.refresh,
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['access'] as String;
            await secureStorage.saveAccessToken(newAccessToken);

            // Retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retriedResponse = await dio.fetch(requestOptions);
            return handler.resolve(retriedResponse);
          }
        } catch (refreshError) {
          // Token refresh failed - session expired
          await secureStorage.clearSession();
          onUnauthenticated?.call();
          return handler.reject(err);
        }
      } else {
        await secureStorage.clearSession();
        onUnauthenticated?.call();
      }
    }
    return handler.next(err);
  }
}
