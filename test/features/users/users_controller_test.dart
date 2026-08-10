import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/auth/domain/user_model.dart';
import 'package:pose_frontend/features/users/data/users_repository.dart';
import 'package:pose_frontend/features/users/presentation/users_controller.dart';

class MockUsersRepository extends UsersRepository {
  MockUsersRepository() : super(ApiClient(Dio()));

  @override
  Future<List<UserModel>> getUsers() async {
    return const [
      UserModel(id: 1, username: 'admin', firstName: 'System Admin', role: 'ADMIN'),
      UserModel(id: 2, username: 'cashier1', firstName: 'Jane Cashier', role: 'CASHIER'),
    ];
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    return UserModel.fromJson({'id': 99, ...payload});
  }
}

void main() {
  late MockUsersRepository mockRepository;
  late UsersController controller;

  setUp(() {
    mockRepository = MockUsersRepository();
    controller = UsersController(mockRepository);
  });

  test('fetchUsers loads staff accounts list', () async {
    await controller.fetchUsers();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.users.length, equals(2));
  });

  test('Search filtering user list', () async {
    await controller.fetchUsers();

    controller.setSearchQuery('Jane');
    expect(controller.state.filteredUsers.length, equals(1));
    expect(controller.state.filteredUsers.first.username, equals('cashier1'));
  });

  test('saveUser dispatches successfully for new staff account', () async {
    final success = await controller.saveUser({
      'username': 'newstaff',
      'full_name': 'New Staff Member',
      'role': 'CASHIER',
      'password': 'password123',
    });

    expect(success, isTrue);
  });
}
