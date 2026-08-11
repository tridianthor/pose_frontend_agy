import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/customers/data/customers_repository.dart';
import 'package:pose_frontend/features/customers/domain/customer_model.dart';
import 'package:pose_frontend/features/customers/presentation/customer_list_screen.dart';

class MockCustomersRepository extends CustomersRepository {
  MockCustomersRepository() : super(ApiClient(Dio()));

  @override
  Future<List<CustomerModel>> getCustomers({int page = 1, String? search}) async {
    return [
      CustomerModel.walkIn(),
      const CustomerModel(id: 1, name: 'Alice Smith', phone: '08123456789', email: 'alice@example.com'),
    ];
  }
}

void main() {
  testWidgets('CustomerListScreen renders Walk-in customer tag without overflow on narrow screen', (tester) async {
    // Set a narrow screen size (e.g. 320x600)
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customersRepositoryProvider.overrideWithValue(MockCustomersRepository()),
        ],
        child: const MaterialApp(
          home: CustomerListScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Walk-in Customer tile is rendered
    expect(find.text('Walk-in Customer'), findsOneWidget);
    expect(find.text('SYSTEM DEFAULT'), findsOneWidget);

    // Verify no exception / overflow occurred
    expect(tester.takeException(), isNull);
  });
}
