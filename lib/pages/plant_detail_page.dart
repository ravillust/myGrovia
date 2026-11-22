import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../widgets/plant_widgets.dart';
import '../widgets/plant_information_dialog.dart';
import '../widgets/room_selection_sheet.dart';
import '../widgets/watering_interval_dialog.dart';

class PlantDetailPage extends StatefulWidget {
  final Plant plant;
  final bool isSaved;
  final bool isAdded;
  final VoidCallback onBookmark;
  final Future<void> Function(String, int) onAdd;
  const PlantDetailPage({
    super.key,
    required this.plant,
    required this.isSaved,
    required this.isAdded,
    required this.onBookmark,
    required this.onAdd,
  });
  @override
  State<PlantDetailPage> createState() {
    return _PlantDetailPageState();
  }
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  bool saved = false;
  bool adding = false;

  @override
  void initState() {
    super.initState();
    saved = widget.isSaved;
  }

  void changeBookmark() {
    widget.onBookmark();
    setState(() {
      saved = !saved;
    });
  }

  void showPlantInformation() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return PlantInformationDialog(plant: widget.plant);
      },
    );
  }

  Future<void> addToCollection() async {
    if (adding) return;
    int days = widget.plant.wateringDays;
    if (!widget.plant.wateringKnown) {
      final selected = await showDialog<int>(
        context: context,
        builder: (_) => const WateringIntervalDialog(),
      );
      if (selected == null || !mounted) return;
      days = selected;
    }
    final room = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return RoomSelectionSheet(plantName: widget.plant.name);
      },
    );
    // Menutup panel tanpa konfirmasi berarti tidak menambahkan tanaman.
    if (room == null || !mounted) {
      return;
    }
    setState(() => adding = true);
    try {
      await widget.onAdd(room, days);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to add this plant. Try again or restart the app.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Plant plant = widget.plant;
    String bookmarkLabel = 'Save plant';
    IconData bookmarkIcon = Icons.bookmark_border;
    if (saved) {
      bookmarkLabel = 'Remove bookmark';
      bookmarkIcon = Icons.bookmark;
    }

    String addButtonLabel = 'Add to Collection';
    IconData addButtonIcon = Icons.add;
    VoidCallback? addButtonAction = adding ? null : addToCollection;
    if (adding) addButtonLabel = 'Saving...';
    if (widget.isAdded) {
      addButtonLabel = 'Already in Collection';
      addButtonIcon = Icons.check;
      addButtonAction = null;
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                PlantPhoto(plant: plant, height: 250),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                      ),
                      if (plant.botanicalName.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          plant.botanicalName,
                          style: const TextStyle(
                            color: mutedText,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        plant.description,
                        style: const TextStyle(
                          color: mutedText,
                          height: 1.6,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: showPlantInformation,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        child: const Text('Read more'),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            careInfo(
                              Icons.wb_sunny_outlined,
                              'Light',
                              plant.light,
                            ),
                            const SizedBox(height: 20),
                            careInfo(
                              Icons.water_drop_outlined,
                              'Water',
                              plant.wateringKnown
                                  ? 'About every ${plant.wateringDays} days'
                                  : 'Set an interval when adding this plant',
                            ),
                            const SizedBox(height: 20),
                            careInfo(
                              Icons.thermostat_outlined,
                              'Temperature',
                              plant.temperature,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: addButtonLabel,
                        icon: addButtonIcon,
                        onPressed: addButtonAction,
                      ),
                      const SizedBox(height: 24),
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
                  IconButton(
                    tooltip: bookmarkLabel,
                    onPressed: changeBookmark,
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    icon: Icon(bookmarkIcon, color: plantGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget careInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: plantGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: mutedText, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
