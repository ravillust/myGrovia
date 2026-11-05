import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../widgets/plant_widgets.dart';

class ProfilePage extends StatelessWidget {
  final List<CollectionPlant> plants;
  final int savedCount;
  final VoidCallback onOpenCollection;
  final VoidCallback onOpenSavedPlants;
  const ProfilePage({
    super.key,
    required this.plants,
    required this.savedCount,
    required this.onOpenCollection,
    required this.onOpenSavedPlants,
  });
  int countPlantsDueForWatering() {
    int total = 0;
    for (final CollectionPlant item in plants) {
      if (item.daysUntilWatering <= 0) {
        total++;
      }
    }
    return total;
  }

  void showDataSource(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Plant data source'),
          content: const SelectableText(
            'Plantfolio Common Plants © 2026 Luminoid\n'
            'https://github.com/Luminoid/plantfolio-common-plants\n\n'
            'CC BY-NC-SA 4.0\n'
            'https://creativecommons.org/licenses/by-nc-sa/4.0/\n\n'
            'Four entries selected. Display names and light labels are adapted. '
            'Photos, scientific-name labels, and care filters are supplied by myGrovia. '
            'Adapted plant data is shared under the same license.\n\n'
            'Watering estimates use the dataset’s summer intervals as a starting '
            'point. Adjust to your soil, room, and plant conditions.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const PageHeading(title: 'My space'),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: onOpenCollection,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.local_florist_outlined,
                  color: plantGreen,
                ),
                title: const Text('Plants in collection'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${plants.length}'),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right, size: 20, color: mutedText),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.water_drop_outlined,
                  color: plantGreen,
                ),
                title: const Text('Due for watering'),
                trailing: Text('${countPlantsDueForWatering()}'),
              ),
              const Divider(),
              ListTile(
                onTap: onOpenSavedPlants,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bookmark_border, color: plantGreen),
                title: const Text('Saved plants'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$savedCount'),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right, size: 20, color: mutedText),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  showDataSource(context);
                },
                child: const Text('Plant data source'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
