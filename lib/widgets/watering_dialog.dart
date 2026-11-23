import 'package:flutter/material.dart';

import '../model/plant.dart';
import 'plant_widgets.dart';

class WateringDialog extends StatefulWidget {
  const WateringDialog({super.key});
  @override
  State<WateringDialog> createState() {
    return _WateringDialogState();
  }
}

class _WateringDialogState extends State<WateringDialog> {
  bool submitted = false;
  String? amountError;
  final TextEditingController amountController = TextEditingController(
    text: '300',
  );
  final TextEditingController noteController = TextEditingController();
  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void saveWatering() {
    if (submitted) return;
    final int? amount = int.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0 || amount > 1000000) {
      setState(() {
        amountError = 'Enter a positive whole number';
      });
      return;
    }

    String note = noteController.text.trim();
    if (note.isEmpty) {
      note = 'Regular watering';
    }
    submitted = true;
    final WateringEntry entry = WateringEntry(DateTime.now(), note, amount);
    // Close form dan kirim catatan; halaman detail yang memasukkannya ke riwayat.
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      title: const Text('Record watering'),
      titleTextStyle: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontSize: 21),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water amount',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                errorText: amountError,
                hintText: '300',
                suffixText: 'ml',
                errorMaxLines: 2,
              ),
              onChanged: (String text) {
                if (amountError != null) {
                  setState(() {
                    amountError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Note (optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'e.g. Top layer of soil was dry',
                hintStyle: TextStyle(color: mutedText, fontSize: 13),
              ),
              minLines: 3,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: Color(0xffd4d7d2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: saveWatering,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
