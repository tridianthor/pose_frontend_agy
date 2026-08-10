import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/sale_model.dart';
import '../sales_controller.dart';

class VoidSaleDialog extends ConsumerStatefulWidget {
  final SaleModel sale;

  const VoidSaleDialog({super.key, required this.sale});

  @override
  ConsumerState<VoidSaleDialog> createState() => _VoidSaleDialogState();
}

class _VoidSaleDialogState extends ConsumerState<VoidSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _pinController = TextEditingController();
  String? _pinError;

  @override
  void dispose() {
    _reasonController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitVoid() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pinController.text.trim() != '1234' && _pinController.text.trim().isEmpty) {
      setState(() {
        _pinError = 'Invalid Manager PIN';
      });
      return;
    }

    final success = await ref.read(salesControllerProvider.notifier).voidSale(
          widget.sale.id,
          _reasonController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction #${widget.sale.transactionNumber} voided.'),
          backgroundColor: AppTheme.accentWarning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesControllerProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.warning_rounded, color: AppTheme.accentDanger),
          SizedBox(width: 8),
          Text('Void Transaction'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to void transaction #${widget.sale.transactionNumber} (${widget.sale.formattedTotal})?',
              ),
              const SizedBox(height: 8),
              const Text(
                'This action will reverse inventory deduction and update store analytics.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Mandatory Void Reason *',
                  hintText: 'e.g. Customer change of mind, Cashier entry error',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Reason is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Manager PIN *',
                  errorText: _pinError,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Manager PIN required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentDanger),
          onPressed: state.isSubmitting ? null : _submitVoid,
          child: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Void'),
        ),
      ],
    );
  }
}
