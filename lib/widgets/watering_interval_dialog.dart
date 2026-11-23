import 'package:flutter/material.dart';

class WateringIntervalDialog extends StatefulWidget {
  const WateringIntervalDialog({super.key});
  @override
  State<WateringIntervalDialog> createState() => _WateringIntervalDialogState();
}

class _WateringIntervalDialogState extends State<WateringIntervalDialog> {
  final intervalController = TextEditingController();
  String? error;
  @override
  void dispose() {
    intervalController.dispose();
    super.dispose();
  }

  void confirmInterval() {
    final days = int.tryParse(intervalController.text.trim());
    if (days == null || days < 1 || days > 365) {
      setState(() => error = 'Enter a number from 1 to 365');
      return;
    }
    Navigator.pop(context, days);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Set watering interval'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'This plant has no suggested watering interval. Choose one that suits your plant and its conditions.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: intervalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Interval (days)',
            errorText: error,
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: confirmInterval, child: const Text('Continue')),
    ],
  );
}
