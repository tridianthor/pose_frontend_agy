import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/inventory_movement_model.dart';
import 'inventory_controller.dart';

class InventoryHistoryScreen extends ConsumerStatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  ConsumerState<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends ConsumerState<InventoryHistoryScreen> {
  String? _selectedMovementType;

  final List<String> _types = ['All', 'Stock In', 'Stock Out', 'Sale', 'Adjustment'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

    return Column(
      children: [
        // Movement Type Filter Pills
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _types.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = _types[index];
              final isSelected = (type == 'All' && _selectedMovementType == null) ||
                  _selectedMovementType == type;

              return FilterChip(
                selected: isSelected,
                label: Text(type),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                onSelected: (_) {
                  setState(() {
                    _selectedMovementType = type == 'All' ? null : type;
                  });
                  ref.read(inventoryControllerProvider.notifier).fetchHistory(
                        movementType: _selectedMovementType,
                      );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // History List
        Expanded(
          child: state.history.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_toggle_off_rounded,
                            size: 56, color: Theme.of(context).disabledColor),
                        const SizedBox(height: 16),
                        Text(
                          'No inventory movements found.',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: state.history.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.history[index];
                    return _HistoryTile(item: item);
                  },
                ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final InventoryMovementModel item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPositive = item.quantity > 0;
    final color = isPositive ? AppTheme.accentSuccess : AppTheme.accentDanger;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          isPositive ? Icons.add_rounded : Icons.remove_rounded,
          color: color,
        ),
      ),
      title: Text(
        item.productName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${item.movementType} • ${item.createdAt.toString().split('.')[0]} • By: ${item.userName ?? "System"}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isPositive ? "+" : ""}${item.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
          Text(
            '${item.previousStock} -> ${item.resultingStock}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
