import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/core/network/api_endpoints.dart';
import 'package:pose_frontend/features/dashboard/presentation/dashboard_controller.dart';

class MockDashboardApiClient extends ApiClient {
  MockDashboardApiClient() : super(Dio());

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (path == ApiEndpoints.dashboard) {
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'today_sales': 1500000,
          'today_transactions': 25,
          'low_stock_count': 3,
          'total_products': 80,
        } as T,
      );
    } else if (path == ApiEndpoints.products) {
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'count': 1,
          'results': [
            {
              'id': 101,
              'name': 'Arabica Coffee',
              'sku': 'COF-001',
              'selling_price': 25000,
              'stock_quantity': 2,
              'minimum_stock': 10,
            }
          ]
        } as T,
      );
    }
    throw UnimplementedError();
  }
}

void main() {
  test('DashboardController fetches summary and low stock products', () async {
    final mockApiClient = MockDashboardApiClient();
    final controller = DashboardController(mockApiClient);

    await controller.fetchDashboardData();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.summary, isNotNull);
    expect(controller.state.summary!.formattedTodaySales, equals('Rp1,500,000'));
    expect(controller.state.summary!.todayTransactions, equals(25));
    expect(controller.state.lowStockProducts.length, equals(1));
    expect(controller.state.lowStockProducts.first.name, equals('Arabica Coffee'));
  });
}
