import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/login_controller.dart';
import 'users_controller.dart';
import 'widgets/user_form_dialog.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openUserForm([UserModel? user]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UserFormDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.role == null || authState.role!.toUpperCase() == 'ADMIN';

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined,
                    size: 64, color: AppTheme.accentDanger),
                const SizedBox(height: 16),
                Text(
                  'Access Restricted',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDanger,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Staff User Management requires Administrator credentials.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final state = ref.watch(usersControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User & Role Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage staff accounts, credentials, and access roles (Admin, Manager, Cashier)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openUserForm(),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Add Staff User'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(usersControllerProvider.notifier).setSearchQuery(val);
                },
                decoration: const InputDecoration(
                  hintText: 'Search username or full name...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              'No staff accounts found matching search.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.filteredUsers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = state.filteredUsers[index];
                              return _UserTile(
                                user: user,
                                onEdit: () => _openUserForm(user),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const _UserTile({required this.user, required this.onEdit});

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return AppTheme.accentDanger;
      case 'MANAGER':
        return AppTheme.accentWarning;
      case 'CASHIER':
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.role);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: roleColor.withValues(alpha: 0.15),
        child: Icon(Icons.person_rounded, color: roleColor),
      ),
      title: Row(
        children: [
          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text('Username: ${user.username} • Email: ${user.email ?? "N/A"}'),
      trailing: IconButton(
        tooltip: 'Edit Staff User',
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ),
    );
  }
}
