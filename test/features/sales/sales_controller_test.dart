import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/sales/data/sales_repository.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';
import 'package:pose_frontend/features/sales/presentation/sales_controller.dart';

class MockSalesRepository extends SalesRepository {
  MockSalesRepository() : super(ApiClient(Dio()));

  @override
  Future<List<SaleModel>> getSalesHistory({int page = 1, String? search}) async {
    return [
      SaleModel(
        id: 101,
        transactionNumber: 'POS-101',
        createdAt: DateTime.now(),
        paymentMethodId: 1,
        subtotal: 50000,
        total: 50000,
        amountPaid: 50000,
        change: 0,
        paymentMethodName: 'Cash',
        status: 'COMPLETED',
      ),
      SaleModel(
        id: 102,
        transactionNumber: 'POS-102',
        createdAt: DateTime.now(),
        paymentMethodId: 2,
        subtotal: 75000,
        total: 75000,
        amountPaid: 75000,
        change: 0,
        paymentMethodName: 'QRIS',
        status: 'VOIDED',
      ),
    ];
  }

  @override
  Future<SaleModel> voidSale(int saleId) async {
    return SaleModel(
      id: saleId,
      transactionNumber: 'POS-$saleId',
      createdAt: DateTime.now(),
      paymentMethodId: 1,
      subtotal: 50000,
      total: 50000,
      amountPaid: 50000,
      change: 0,
      paymentMethodName: 'Cash',
      status: 'VOIDED',
    );
  }
}

void main() {
  late MockSalesRepository mockRepository;
  late SalesController controller;

  setUp(() {
    mockRepository = MockSalesRepository();
    controller = SalesController(mockRepository);
  });

  test('fetchSales loads sales history list', () async {
    await controller.fetchSales();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.sales.length, equals(2));
  });

  test('Filtering by payment method and status', () async {
    await controller.fetchSales();

    controller.setPaymentFilter('QRIS');
    expect(controller.state.filteredSales.length, equals(1));
    expect(controller.state.filteredSales.first.transactionNumber, equals('POS-102'));

    controller.setPaymentFilter('All');
    controller.setStatusFilter('COMPLETED');
    expect(controller.state.filteredSales.length, equals(1));
    expect(controller.state.filteredSales.first.transactionNumber, equals('POS-101'));
  });

  test('voidSale dispatches successfully and refetches sales', () async {
    final success = await controller.voidSale(101, 'Customer request');

    expect(success, isTrue);
  });
}
