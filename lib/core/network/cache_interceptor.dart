import 'package:dio/dio.dart';

class _CacheItem {
  final Response response;
  final DateTime timestamp;

  _CacheItem(this.response) : timestamp = DateTime.now();

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class CacheInterceptor extends Interceptor {
  final Map<String, _CacheItem> _cache = {};
  final Duration ttl;

  CacheInterceptor({this.ttl = const Duration(minutes: 5)});

  void clearCache() {
    _cache.clear();
  }

  void invalidatePath(String path) {
    _cache.removeWhere((key, _) => key.contains(path));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'GET') {
      final key = options.uri.toString();
      final cachedItem = _cache[key];
      if (cachedItem != null && !cachedItem.isExpired(ttl)) {
        return handler.resolve(cachedItem.response);
      }
    } else {
      // Invalidate cache on mutations (POST, PATCH, DELETE)
      invalidatePath(options.path);
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final key = response.requestOptions.uri.toString();
      _cache[key] = _CacheItem(response);
    }
    return handler.next(response);
  }
}
