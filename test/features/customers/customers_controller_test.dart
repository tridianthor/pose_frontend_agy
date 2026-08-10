import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/customers/data/customers_repository.dart';
import 'package:pose_frontend/features/customers/domain/customer_model.dart';
import 'package:pose_frontend/features/customers/presentation/customers_controller.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';

class MockCustomersRepository extends CustomersRepository {
  MockCustomersRepository() : super(ApiClient(Dio()));

  @override
  Future<List<CustomerModel>> getCustomers({int page = 1, String? search}) async {
    return [
      CustomerModel.walkIn(),
      const CustomerModel(id: 1, name: 'Alice Smith', phone: '08123456789', email: 'alice@example.com'),
      const CustomerModel(id: 2, name: 'Bob Johnson', phone: '08987654321', email: 'bob@example.com'),
    ];
  }

  @override
  Future<CustomerModel> createCustomer(Map<String, dynamic> payload) async {
    return CustomerModel.fromJson({'id': 99, ...payload});
  }

  @override
  Future<List<SaleModel>> getCustomerHistory(int customerId) async {
    return [
      SaleModel(
        id: 1,
        transactionNumber: 'POS-CUST-1',
        createdAt: DateTime.now(),
        paymentMethodId: 1,
        subtotal: 30000,
        total: 30000,
        amountPaid: 30000,
        change: 0,
        status: 'COMPLETED',
      ),
    ];
  }
}

void main() {
  late MockCustomersRepository mockRepository;
  late CustomersController controller;

  setUp(() {
    mockRepository = MockCustomersRepository();
    controller = CustomersController(mockRepository);
  });

  test('fetchCustomers loads customers and includes Walk-in Customer', () async {
    await controller.fetchCustomers();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.customers.length, equals(3));
    expect(controller.state.customers.first.isWalkIn, isTrue);
  });

  test('Search query filters customer list by name or phone', () async {
    await controller.fetchCustomers();

    controller.setSearchQuery('Alice');
    expect(controller.state.filteredCustomers.length, equals(1));
    expect(controller.state.filteredCustomers.first.name, equals('Alice Smith'));

    controller.setSearchQuery('08987654321');
    expect(controller.state.filteredCustomers.length, equals(1));
    expect(controller.state.filteredCustomers.first.name, equals('Bob Johnson'));
  });

  test('Modifying Walk-in Customer is blocked by immutability guard', () async {
    final success = await controller.saveCustomer({'name': 'Hacked Walk-in'}, customerId: 0);

    expect(success, isFalse);
    expect(controller.state.failure, isNotNull);
    expect(controller.state.failure!.message, contains('cannot be modified'));
  });

  test('saveCustomer dispatches successfully for regular customer', () async {
    final success = await controller.saveCustomer({'name': 'Charlie Brown', 'phone': '08555444333'});

    expect(success, isTrue);
  });
}
