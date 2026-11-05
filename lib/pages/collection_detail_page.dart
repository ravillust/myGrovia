import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../widgets/plant_widgets.dart';

class CollectionDetailPage extends StatefulWidget {
  final CollectionPlant item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  const CollectionDetailPage({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });
  @override
  State<CollectionDetailPage> createState() {
    return _CollectionDetailPageState();
  }
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  bool showAll = false;
  Future<void> waterPlant() async {
    final entry = await showDialog<WateringEntry>(
      context: context,
      builder: (context) {
        return const WateringDialog();
      },
    );
    if (entry == null || !mounted) {
      return;
    }
    // Riwayat terbaru harus berada di posisi pertama untuk menghitung jadwal.
    setState(() {
      widget.item.history.insert(0, entry);
    });
    widget.onChanged();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Watering recorded')));
  }

  Future<void> removePlant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove this plant?'),
          content: const Text(
            'Its watering history will also be removed from this demo collection.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    widget.onDelete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final CollectionPlant item = widget.item;
    final int days = item.daysUntilWatering;
    final List<WateringEntry> entries = [];
    for (int index = 0; index < item.history.length; index++) {
      if (showAll || index < 3) {
        entries.add(item.history[index]);
      }
    }
    String wateringLabel = 'Due today';
    if (days > 0) {
      wateringLabel = 'In $days days';
    }
    String historyButtonLabel = 'View all';
    if (showAll) {
      historyButtonLabel = 'Show less';
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                PlantPhoto(plant: item.plant, height: 200),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.plant.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.room,
                        style: const TextStyle(color: mutedText, fontSize: 12),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Next watering',
                        style: TextStyle(color: mutedText, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wateringLabel,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check the soil before watering.',
                        style: TextStyle(color: mutedText, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Record watering',
                        icon: Icons.water_drop_outlined,
                        onPressed: waterPlant,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Watering history',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (item.history.length > 3)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (showAll) {
                                    showAll = false;
                                  } else {
                                    showAll = true;
                                  }
                                });
                              },
                              child: Text(historyButtonLabel),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (entries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No watering recorded yet.',
                            style: TextStyle(color: mutedText),
                          ),
                        ),
                      for (final WateringEntry entry in entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.water_drop_outlined,
                                size: 18,
                                color: plantGreen,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            formatDate(entry.date),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            TimeOfDay.fromDateTime(entry.date)
                                                .format(context),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              color: mutedText,
                                              fontSize: 13,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            entry.note,
                                            style: const TextStyle(
                                              color: mutedText,
                                              fontSize: 13,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            '${entry.milliliters} ml',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              color: mutedText,
                                              fontSize: 13,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Tombol berada di depan foto dan tetap tersedia saat halaman digulir.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Back',
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: PopupMenuButton<String>(
                      tooltip: 'Plant options',
                      onSelected: (String choice) {
                        if (choice == 'remove') {
                          removePlant();
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove plant'),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    // Bandingkan tanggal saja agar jam penyiraman tidak mengubah label harinya.
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime wateringDate = DateTime(date.year, date.month, date.day);
    final int daysAgo = today.difference(wateringDate).inDays;
    if (daysAgo == 0) {
      return 'Today';
    }
    if (daysAgo == 1) {
      return 'Yesterday';
    }
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class WateringDialog extends StatefulWidget {
  const WateringDialog({super.key});
  @override
  State<WateringDialog> createState() {
    return _WateringDialogState();
  }
}

class _WateringDialogState extends State<WateringDialog> {
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
    final int? amount = int.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        amountError = 'Enter a positive whole number';
      });
      return;
    }

    String note = noteController.text.trim();
    if (note.isEmpty) {
      note = 'Regular watering';
    }
    final WateringEntry entry = WateringEntry(DateTime.now(), note, amount);
    // Tutup form dan kirim catatan; halaman detail yang memasukkannya ke riwayat.
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
            const SizedBox(height: 20),
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
