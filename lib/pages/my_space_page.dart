import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../widgets/plant_widgets.dart';

class MySpacePage extends StatelessWidget {
  final List<CollectionPlant> plants;
  final VoidCallback onOpenCollection;
  const MySpacePage({
    super.key,
    required this.plants,
    required this.onOpenCollection,
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
            'Catalog bundled inside APK from the pinned GitHub source. Read more loads descriptions from the same source through the GitHub API, with a saved copy available offline. Display names and light labels are adapted. '
            'Verified Wikimedia photos are bundled for offline use. Photographer, source, license, and resizing details are shown in Read more for each photo. Plants without a verified photo use the default illustration. Scientific-name labels and care filters are supplied by myGrovia. '
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    overviewRow(
                      'My collection',
                      plants.length,
                      Icons.local_florist_outlined,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    overviewRow(
                      'To check today',
                      countPlantsDueForWatering(),
                      Icons.water_drop_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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

  Widget overviewRow(String title, int count, IconData icon) {
    return ListTile(
      onTap: onOpenCollection,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: plantGreen),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, size: 20, color: mutedText),
        ],
      ),
    );
  }
}
