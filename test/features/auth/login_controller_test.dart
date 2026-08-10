import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/core/storage/secure_storage_service.dart';
import 'package:pose_frontend/features/auth/domain/auth_state.dart';
import 'package:pose_frontend/features/auth/presentation/login_controller.dart';
import 'package:dio/dio.dart';

class MockApiClient extends ApiClient {
  bool shouldSucceed = true;

  MockApiClient() : super(Dio());

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (shouldSucceed) {
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'access': 'mock_access_token',
          'refresh': 'mock_refresh_token',
          'user': {'role': 'Admin', 'username': 'admin_user'}
        } as T,
      );
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 401,
          data: {'detail': 'Invalid username or password.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }
}

class MockSecureStorage extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _data[key];
  }

  @override
  Future<void> clearAll() async {
    _data.clear();
  }
}

void main() {
  late MockApiClient mockApiClient;
  late MockSecureStorage mockSecureStorage;
  late LoginController controller;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockSecureStorage();
    controller = LoginController(mockApiClient, mockSecureStorage);
  });

  test('Initial state checks auth status from storage', () async {
    final storage = MockSecureStorage();
    await storage.saveAccessToken('existing_token');
    await storage.saveUserRole('Manager');
    await storage.saveUsername('stored_user');

    final newController = LoginController(mockApiClient, storage);
    await Future.delayed(Duration.zero);

    expect(newController.state.status, equals(AuthStatus.authenticated));
    expect(newController.state.username, equals('stored_user'));
    expect(newController.state.role, equals('Manager'));
  });

  test('Successful login updates state to authenticated and saves tokens and username', () async {
    mockApiClient.shouldSucceed = true;

    final result = await controller.login('admin', 'password123');

    expect(result, isTrue);
    expect(controller.state.status, equals(AuthStatus.authenticated));
    expect(controller.state.username, equals('admin'));
    expect(controller.state.role, equals('Admin'));
    expect(await mockSecureStorage.getAccessToken(), equals('mock_access_token'));
    expect(await mockSecureStorage.getRefreshToken(), equals('mock_refresh_token'));
    expect(await mockSecureStorage.getUsername(), equals('admin'));
  });

  test('Failed login updates state to error with AuthFailure', () async {
    mockApiClient.shouldSucceed = false;

    final result = await controller.login('wrong_user', 'wrong_pass');

    expect(result, isFalse);
    expect(controller.state.status, equals(AuthStatus.error));
    expect(controller.state.failure, isNotNull);
  });

  test('Logout clears session storage and resets state to unauthenticated', () async {
    await mockSecureStorage.saveAccessToken('token');
    await mockSecureStorage.saveUsername('admin');
    await controller.logout();

    expect(controller.state.status, equals(AuthStatus.unauthenticated));
    expect(await mockSecureStorage.getAccessToken(), isNull);
    expect(await mockSecureStorage.getUsername(), isNull);
  });
}
