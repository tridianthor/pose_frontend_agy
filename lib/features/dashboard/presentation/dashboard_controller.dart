import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../products/domain/product_model.dart';
import '../domain/dashboard_summary_model.dart';

class DashboardState {
  final bool isLoading;
  final DashboardSummaryModel? summary;
  final List<ProductModel> lowStockProducts;
  final Failure? failure;

  const DashboardState({
    this.isLoading = false,
    this.summary,
    this.lowStockProducts = const [],
    this.failure,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardSummaryModel? summary,
    List<ProductModel>? lowStockProducts,
    Failure? failure,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      failure: failure ?? this.failure,
    );
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardController(apiClient);
});

class DashboardController extends StateNotifier<DashboardState> {
  final ApiClient apiClient;

  DashboardController(this.apiClient) : super(const DashboardState()) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final summaryResponse = await apiClient.get(ApiEndpoints.dashboard);
      DashboardSummaryModel? summary;
      if (summaryResponse.statusCode == 200 && summaryResponse.data != null) {
        summary = DashboardSummaryModel.fromJson(
            summaryResponse.data as Map<String, dynamic>);
      }

      final lowStockResponse = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'low_stock': true},
      );

      List<ProductModel> lowStockList = [];
      if (lowStockResponse.statusCode == 200 && lowStockResponse.data != null) {
        final data = lowStockResponse.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          lowStockList = (data['results'] as List)
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          lowStockList = data
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      state = state.copyWith(
        isLoading: false,
        summary: summary ??
            const DashboardSummaryModel(
              todaySales: 0,
              todayTransactions: 0,
              lowStockCount: 0,
              totalProducts: 0,
            ),
        lowStockProducts: lowStockList,
      );
    } on DioException catch (e) {
      Failure failure;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        failure = const NetworkFailure();
      } else if (e.response?.statusCode == 401) {
        failure = const AuthFailure(message: 'Session expired or unauthorized. Please log in again.');
      } else {
        final data = e.response?.data;
        final message = (data is Map<String, dynamic> && data['detail'] is String)
            ? data['detail'] as String
            : (e.response?.statusCode != null
                ? 'Server error (${e.response?.statusCode}).'
                : 'Failed to load dashboard data.');
        failure = ServerFailure(message: message);
      }
      state = state.copyWith(isLoading: false, failure: failure);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(message: e.toString()),
      );
    }
  }
}
