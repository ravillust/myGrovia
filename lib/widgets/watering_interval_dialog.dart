import 'package:flutter/material.dart';

class WateringIntervalDialog extends StatefulWidget {
  const WateringIntervalDialog({super.key});
  @override
  State<WateringIntervalDialog> createState() => _WateringIntervalDialogState();
}

class _WateringIntervalDialogState extends State<WateringIntervalDialog> {
  final controller = TextEditingController();
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        TextField(
          controller: controller,
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
      FilledButton(
        onPressed: () {
          final value = int.tryParse(controller.text);
          if (value == null || value < 1 || value > 365) {
            setState(() => error = 'Enter a number from 1 to 365');
            return;
          }
          Navigator.pop(context, value);
        },
        child: const Text('Continue'),
      ),
    ],
  );
}
