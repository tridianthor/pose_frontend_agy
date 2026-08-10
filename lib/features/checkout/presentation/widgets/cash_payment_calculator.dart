import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CashPaymentCalculator extends StatefulWidget {
  final double grandTotal;
  final double amountPaid;
  final ValueChanged<double> onAmountPaidChanged;

  const CashPaymentCalculator({
    super.key,
    required this.grandTotal,
    required this.amountPaid,
    required this.onAmountPaidChanged,
  });

  @override
  State<CashPaymentCalculator> createState() => _CashPaymentCalculatorState();
}

class _CashPaymentCalculatorState extends State<CashPaymentCalculator> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.amountPaid > 0) {
      _amountController.text = widget.amountPaid.toInt().toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get change {
    final diff = widget.amountPaid - widget.grandTotal;
    return diff < 0 ? 0.0 : diff;
  }

  String _formatRupiah(double amount) {
    final intPrice = amount.toInt();
    final buffer = StringBuffer();
    final str = intPrice.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  void _applyPreset(double amount) {
    _amountController.text = amount.toInt().toString();
    widget.onAmountPaidChanged(amount);
  }

  @override
  Widget build(BuildContext context) {
    final presets = [
      widget.grandTotal, // Exact Amount
      50000.0,
      100000.0,
      200000.0,
    ].where((a) => a >= widget.grandTotal).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash Received & Change',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount Paid (Rp)',
            prefixIcon: Icon(Icons.attach_money_rounded),
          ),
          onChanged: (val) {
            final paid = double.tryParse(val) ?? 0.0;
            widget.onAmountPaidChanged(paid);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((amount) {
            final isExact = (amount - widget.grandTotal).abs() < 0.01;
            return ChoiceChip(
              selected: (widget.amountPaid - amount).abs() < 0.01,
              label: Text(isExact ? 'Exact (${_formatRupiah(amount)})' : _formatRupiah(amount)),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              onSelected: (_) => _applyPreset(amount),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: change > 0
                ? AppTheme.accentSuccess.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: change > 0
                  ? AppTheme.accentSuccess.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Change',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatRupiah(change),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.accentSuccess,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
