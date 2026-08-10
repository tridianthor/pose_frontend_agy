import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/category_model.dart';
import '../../domain/product_model.dart';
import '../products_controller.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final ProductModel? product;
  final List<CategoryModel> categories;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.categories,
  });

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _unitController;
  late TextEditingController _minStockController;
  late TextEditingController _descriptionController;

  CategoryModel? _selectedCategory;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _sellingPriceController = TextEditingController(text: p != null ? p.sellingPrice.toInt().toString() : '');
    _costPriceController = TextEditingController(text: p != null && p.costPrice != null ? p.costPrice!.toInt().toString() : '');
    _unitController = TextEditingController(text: p?.unit ?? 'pcs');
    _minStockController = TextEditingController(text: p != null ? p.minimumStock.toString() : '5');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _isActive = p?.isActive ?? true;

    if (p != null && p.categoryId != null) {
      final index = widget.categories.indexWhere((c) => c.id == p.categoryId);
      if (index >= 0) {
        _selectedCategory = widget.categories[index];
      }
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _unitController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'name': _nameController.text.trim(),
      'sku': _skuController.text.trim(),
      'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      'category_id': _selectedCategory?.id,
      'selling_price': double.tryParse(_sellingPriceController.text.trim()) ?? 0.0,
      'cost_price': double.tryParse(_costPriceController.text.trim()),
      'unit': _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
      'minimum_stock': int.tryParse(_minStockController.text.trim()) ?? 5,
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'is_active': _isActive,
    };

    final success = await ref
        .read(productsControllerProvider.notifier)
        .saveProduct(payload, productId: widget.product?.id);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product != null ? 'Product updated!' : 'Product created!'),
          backgroundColor: AppTheme.accentSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final isEdit = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Product' : 'Add New Product',
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Product Name *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(labelText: 'SKU *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(labelText: 'Barcode'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<CategoryModel>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: widget.categories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c.name));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Selling Price (Rp) *'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final num = double.tryParse(val.trim());
                          if (num == null || num < 0) return 'Must be >= 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cost Price (Rp)'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return null;
                          final num = double.tryParse(val.trim());
                          if (num == null || num < 0) return 'Must be >= 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(labelText: 'Unit (e.g. pcs, kg, cup)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Minimum Stock Alert *'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final num = int.tryParse(val.trim());
                          if (num == null || num < 0) return 'Must be >= 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Active Status'),
                  subtitle: const Text('Inactive products are hidden from POS catalog'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.isSubmitting ? null : _saveProduct,
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit ? 'Save Changes' : 'Create Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
