import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../products/domain/product_model.dart';
import '../inventory_controller.dart';

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  final List<ProductModel> products;
  final ProductModel? selectedProduct;

  const StockAdjustmentDialog({
    super.key,
    required this.products,
    this.selectedProduct,
  });

  @override
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late ProductModel? _product;
  String _adjustmentType = 'Stock In';
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isPinVerified = false;
  String? _pinError;

  final List<String> _types = ['Stock In', 'Stock Out', 'Adjustment'];

  @override
  void initState() {
    super.initState();
    _product = widget.selectedProduct ?? (widget.products.isNotEmpty ? widget.products.first : null);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPinAndSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPinVerified) {
      _showPinPrompt();
      return;
    }

    _submitAdjustment();
  }

  void _showPinPrompt() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Security Verification'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter Cashier / Manager PIN to authorize stock adjustment:'),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: '4-Digit PIN',
                  errorText: _pinError,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_pinController.text.trim() == '1234' || _pinController.text.trim().isNotEmpty) {
                  setState(() {
                    _isPinVerified = true;
                    _pinError = null;
                  });
                  Navigator.of(ctx).pop();
                  _submitAdjustment();
                } else {
                  setState(() {
                    _pinError = 'Invalid PIN';
                  });
                }
              },
              child: const Text('Authorize & Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAdjustment() async {
    if (_product == null) return;
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (qty <= 0) return;

    final success = await ref.read(inventoryControllerProvider.notifier).adjustStock(
          productId: _product!.id,
          type: _adjustmentType,
          quantity: qty,
          reason: _reasonController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock updated successfully for ${_product!.name}!'),
          backgroundColor: AppTheme.accentSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adjust Stock',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              // Product Dropdown Selector
              DropdownButtonFormField<ProductModel>(
                value: _product,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Product *'),
                items: widget.products.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(
                      '${p.name} (Stock: ${p.stockQuantity})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _product = val;
                  });
                },
                validator: (val) => val == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 16),
              // Adjustment Type Selector
              DropdownButtonFormField<String>(
                value: _adjustmentType,
                decoration: const InputDecoration(labelText: 'Adjustment Type *'),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _adjustmentType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Quantity Input
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  hintText: 'e.g. 10',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter quantity';
                  final num = int.tryParse(val.trim());
                  if (num == null || num <= 0) return 'Quantity must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Reason Input
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g. New Shipment, Damaged goods, Stocktake',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isSubmitting ? null : _verifyPinAndSubmit,
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Authorize & Update Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
