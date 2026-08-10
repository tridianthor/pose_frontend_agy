import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../auth/domain/user_model.dart';
import '../data/users_repository.dart';

class UsersState {
  final bool isLoading;
  final bool isSubmitting;
  final List<UserModel> users;
  final String searchQuery;
  final Failure? failure;

  const UsersState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.users = const [],
    this.searchQuery = '',
    this.failure,
  });

  List<UserModel> get filteredUsers {
    return users.where((u) {
      final matchesSearch = searchQuery.isEmpty ||
          u.username.toLowerCase().contains(searchQuery.toLowerCase()) ||
          u.fullName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  UsersState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<UserModel>? users,
    String? searchQuery,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, UsersState>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return UsersController(repository);
});

class UsersController extends StateNotifier<UsersState> {
  final UsersRepository repository;

  UsersController(this.repository) : super(const UsersState()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final list = await repository.getUsers();
      state = state.copyWith(isLoading: false, users: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  Future<bool> saveUser(Map<String, dynamic> payload, {int? userId}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      if (userId != null) {
        await repository.updateUser(userId, payload);
      } else {
        await repository.createUser(payload);
      }

      await fetchUsers();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        failure: ServerFailure(message: e.toString()),
      );
      return false;
    }
  }
}
