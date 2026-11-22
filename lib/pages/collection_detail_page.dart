import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../model/plant.dart';
import '../services/database_helper.dart';
import '../widgets/plant_widgets.dart';
import '../widgets/watering_dialog.dart';
import 'edit_plant_page.dart';

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
  bool busy = false;
  bool choosingWater = false;
  String? actionId;
  WateringEntry? pendingEntry;

  Future<void> editPlant() async {
    if (busy) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPlantPage(item: widget.item)),
    );
    if (mounted) {
      setState(() {});
      widget.onChanged();
    }
  }

  void showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to save. Check device storage and try again.'),
      ),
    );
  }

  Future<void> waterPlant() async {
    if (busy || choosingWater) return;
    choosingWater = true;
    final entry =
        pendingEntry ??
        await showDialog<WateringEntry>(
          context: context,
          builder: (context) {
            return const WateringDialog();
          },
        );
    choosingWater = false;
    if (entry == null || !mounted) {
      return;
    }
    pendingEntry = entry;
    actionId ??= const Uuid().v4();
    setState(() => busy = true);
    try {
      final saved = await DatabaseHelper.instance.water(
        widget.item.id!,
        actionId!,
        entry,
      );
      widget.item.history.insert(0, saved);
      actionId = null;
      pendingEntry = null;
      widget.onChanged();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Watering recorded')));
      }
    } catch (_) {
      if (mounted) showError();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> removePlant() async {
    if (busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove this plant?'),
          content: const Text(
            'Its watering history will also be removed permanently.',
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
    setState(() => busy = true);
    try {
      await DatabaseHelper.instance.deletePlant(widget.item.id!);
      widget.onDelete();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) showError();
    } finally {
      if (mounted) setState(() => busy = false);
    }
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
    if (item.history.isEmpty) {
      wateringLabel = 'Not watered yet';
    } else if (days < 0) {
      final overdue = -days;
      wateringLabel = 'Overdue by $overdue ${overdue == 1 ? 'day' : 'days'}';
    } else if (days > 0) {
      wateringLabel = days == 1 ? 'Tomorrow' : 'In $days days';
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
                      Text(
                        item.history.isEmpty
                            ? 'Watering status'
                            : 'Next watering',
                        style: const TextStyle(color: mutedText, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wateringLabel,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (item.nextWatering != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${formatDate(item.nextWatering!, relative: false)} ${item.nextWatering!.year}',
                          style: const TextStyle(color: mutedText, height: 1.5),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: busy
                            ? 'Saving...'
                            : pendingEntry != null
                            ? 'Retry saving'
                            : 'Record watering',
                        icon: Icons.water_drop_outlined,
                        onPressed: busy ? null : waterPlant,
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
                                  showAll = !showAll;
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
                        if (choice == 'edit') editPlant();
                        if (choice == 'photo-source') {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              scrollable: true,
                              title: const Text('Photo source'),
                              content: SelectableText(
                                item.plant.photoReference,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                        if (choice == 'remove') {
                          removePlant();
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          if (item.plant.photoReference.isNotEmpty)
                            const PopupMenuItem(
                              value: 'photo-source',
                              child: Text('Photo source'),
                            ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit plant'),
                          ),
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

  String formatDate(DateTime date, {bool relative = true}) {
    final DateTime now = DateTime.now();
    // Bandingkan tanggal saja agar jam penyiraman tidak mengubah label harinya.
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime wateringDate = DateTime(date.year, date.month, date.day);
    final int daysAgo = today.difference(wateringDate).inDays;
    if (relative && daysAgo == 0) {
      return 'Today';
    }
    if (relative && daysAgo == 1) {
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
