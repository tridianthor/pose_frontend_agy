import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/auth_state.dart';

final authStateProvider =
    StateNotifierProvider<LoginController, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return LoginController(apiClient, secureStorage);
});

class LoginController extends StateNotifier<AuthState> {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  LoginController(this.apiClient, this.secureStorage)
      : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await secureStorage.getAccessToken();
    final role = await secureStorage.getUserRole();
    final username = await secureStorage.getUsername();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        username: username ?? 'User',
        role: role ?? 'Cashier',
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, failure: null);
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access'] as String? ?? data['token'] as String? ?? '';
        final refreshToken = data['refresh'] as String? ?? '';

        final userMap = data['user'] as Map<String, dynamic>? ?? {};
        final userRole = userMap['role'] as String? ?? 'Cashier';

        await secureStorage.saveAccessToken(accessToken);
        if (refreshToken.isNotEmpty) {
          await secureStorage.saveRefreshToken(refreshToken);
        }
        await secureStorage.saveUserRole(userRole);
        await secureStorage.saveUsername(username);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          username: username,
          role: userRole,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          failure: const AuthFailure(message: 'Invalid credentials.'),
        );
        return false;
      }
    } on DioException catch (e) {
      Failure failure;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        failure = const NetworkFailure();
      } else if (e.response?.statusCode == 401) {
        failure = const AuthFailure(message: 'Invalid username or password.');
      } else {
        failure = ServerFailure(
          message: e.response?.data?['detail'] ?? 'An unexpected error occurred.',
        );
      }

      state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        failure: ServerFailure(message: e.toString()),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await secureStorage.clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
