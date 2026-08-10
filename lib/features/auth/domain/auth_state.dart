import '../../../core/errors/failures.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? username;
  final String? role;
  final Failure? failure;

  const AuthState({
    this.status = AuthStatus.initial,
    this.username,
    this.role,
    this.failure,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? username,
    String? role,
    Failure? failure,
  }) {
    return AuthState(
      status: status ?? this.status,
      username: username ?? this.username,
      role: role ?? this.role,
      failure: failure ?? this.failure,
    );
  }

  @override
  String toString() =>
      'AuthState(status: $status, username: $username, role: $role, failure: $failure)';
}
