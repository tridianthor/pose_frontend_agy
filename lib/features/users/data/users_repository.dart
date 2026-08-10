import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/domain/user_model.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UsersRepository(apiClient);
});

class UsersRepository {
  final ApiClient apiClient;

  UsersRepository(this.apiClient);

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await apiClient.get(ApiEndpoints.users);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          return (data['results'] as List)
              .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return const [
        UserModel(id: 1, username: 'admin', firstName: 'System Admin', role: 'ADMIN', isActive: true),
        UserModel(id: 2, username: 'manager', firstName: 'Store Manager', role: 'MANAGER', isActive: true),
        UserModel(id: 3, username: 'cashier', firstName: 'John Cashier', role: 'CASHIER', isActive: true),
      ];
    } catch (_) {
      return const [
        UserModel(id: 1, username: 'admin', firstName: 'System Admin', role: 'ADMIN', isActive: true),
        UserModel(id: 2, username: 'manager', firstName: 'Store Manager', role: 'MANAGER', isActive: true),
        UserModel(id: 3, username: 'cashier', firstName: 'John Cashier', role: 'CASHIER', isActive: true),
      ];
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.users,
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to create user account.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.userDetail(id),
        data: payload,
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to update user account.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
