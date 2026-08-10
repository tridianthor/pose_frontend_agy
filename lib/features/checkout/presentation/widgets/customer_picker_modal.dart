import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customers/domain/customer_model.dart';

class CustomerPickerModal extends StatefulWidget {
  final CustomerModel selectedCustomer;
  final ValueChanged<CustomerModel> onCustomerSelected;

  const CustomerPickerModal({
    super.key,
    required this.selectedCustomer,
    required this.onCustomerSelected,
  });

  @override
  State<CustomerPickerModal> createState() => _CustomerPickerModalState();
}

class _CustomerPickerModalState extends State<CustomerPickerModal> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isCreatingNew = false;

  final List<CustomerModel> _mockCustomers = [
    CustomerModel.walkIn(),
    const CustomerModel(id: 1, name: 'Alice Smith', phone: '08123456789'),
    const CustomerModel(id: 2, name: 'Bob Johnson', phone: '08987654321'),
    const CustomerModel(id: 3, name: 'Charlie Brown', phone: '08555444333'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredList = _mockCustomers.where((c) {
      return c.name.toLowerCase().contains(query) ||
          (c.phone != null && c.phone!.contains(query));
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxHeight: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isCreatingNew ? 'Create New Customer' : 'Select Customer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(_isCreatingNew ? Icons.list_rounded : Icons.person_add_alt_1_rounded),
                onPressed: () {
                  setState(() {
                    _isCreatingNew = !_isCreatingNew;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isCreatingNew) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) return;
                final newCustomer = CustomerModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                );
                widget.onCustomerSelected(newCustomer);
                Navigator.of(context).pop();
              },
              child: const Text('Save & Select Customer'),
            ),
          ] else ...[
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search customer name or phone...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final customer = filteredList[index];
                  final isSelected = widget.selectedCustomer.id == customer.id;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      child: Icon(
                        customer.isWalkIn
                            ? Icons.directions_walk_rounded
                            : Icons.person_rounded,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    title: Text(
                      customer.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: customer.phone != null ? Text(customer.phone!) : null,
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      widget.onCustomerSelected(customer);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
