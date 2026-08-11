import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/customer_model.dart';
import 'customers_controller.dart';
import 'widgets/customer_detail_dialog.dart';
import 'widgets/customer_form_dialog.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCustomerForm([CustomerModel? customer]) {
    if (customer?.isWalkIn ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Walk-in Customer is system default and cannot be edited.')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomerFormDialog(customer: customer),
    );
  }

  void _openCustomerHistory(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) => CustomerDetailDialog(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Directory',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage customer contacts, purchase analytics, and loyalty records',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openCustomerForm(),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Add Customer'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref
                      .read(customersControllerProvider.notifier)
                      .setSearchQuery(val);
                },
                decoration: const InputDecoration(
                  hintText: 'Search customer name, phone, or email...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.filteredCustomers.isEmpty
                        ? Center(
                            child: Text(
                              'No customers found matching search.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.filteredCustomers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final customer = state.filteredCustomers[index];
                              return _CustomerTile(
                                customer: customer,
                                onInspect: () => _openCustomerHistory(customer),
                                onEdit: customer.isWalkIn
                                    ? null
                                    : () => _openCustomerForm(customer),
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

class _CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onInspect;
  final VoidCallback? onEdit;

  const _CustomerTile({
    required this.customer,
    required this.onInspect,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: customer.isWalkIn
            ? AppTheme.primaryColor.withValues(alpha: 0.15)
            : Theme.of(context).dividerColor.withValues(alpha: 0.1),
        child: Icon(
          customer.isWalkIn
              ? Icons.directions_walk_rounded
              : Icons.person_rounded,
          color: customer.isWalkIn ? AppTheme.primaryColor : null,
        ),
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(
            customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (customer.isWalkIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SYSTEM DEFAULT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        'Phone: ${customer.phone ?? "N/A"} • Email: ${customer.email ?? "N/A"}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Purchase History',
            icon: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor),
            onPressed: onInspect,
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit Customer',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
