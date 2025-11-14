import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickAddButtons extends StatelessWidget {
  final Function(double) onAddWater;
  final String unit;

  const QuickAddButtons({
    super.key,
    required this.onAddWater,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final amounts = unit == 'oz' ? [8.0, 16.0, 32.0] : [250.0, 500.0, 1000.0];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Add',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...amounts.map((amount) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildQuickButton(
                      context,
                      '${amount.toInt()} $unit',
                      amount,
                      _getButtonIcon(amount, unit),
                    ),
                  ),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildCustomButton(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onAddWater(amount);
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            elevation: 2,
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCustomButton(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _showCustomInputDialog(context),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            elevation: 2,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          child: const Icon(Icons.add_rounded, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          'Custom',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getButtonIcon(double amount, String unit) {
    if (unit == 'oz') {
      if (amount <= 8) return Icons.local_cafe;
      if (amount <= 16) return Icons.local_drink;
      return Icons.sports_bar;
    } else {
      if (amount <= 250) return Icons.local_cafe;
      if (amount <= 500) return Icons.local_drink;
      return Icons.sports_bar;
    }
  }

  void _showCustomInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_drink,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Custom Amount',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount ($unit)',
                hintText: 'Enter amount...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.water_drop,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixText: unit,
              ),
              autofocus: true,
              onSubmitted: (value) {
                final amount = double.tryParse(value);
                if (amount != null && amount > 0) {
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                  onAddWater(amount);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: Add the exact amount you just drank',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.of(context).pop();
                HapticFeedback.lightImpact();
                onAddWater(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid amount'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Water'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
