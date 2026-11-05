import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/plant.dart';
import '../widgets/plant_widgets.dart';
import 'collection_detail_page.dart';

class CollectionPage extends StatelessWidget {
  final List<CollectionPlant> plants;
  final VoidCallback onBrowse;
  final VoidCallback onChanged;
  const CollectionPage({
    super.key,
    required this.plants,
    required this.onBrowse,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    Widget collectionContent;
    if (plants.isEmpty) {
      collectionContent = emptyCollection();
    } else {
      collectionContent = buildPlantList(context);
    }
    return Column(
      children: [
        PageHeading(
          title: 'My collection',
          action: IconButton(
            tooltip: 'Add a plant',
            onPressed: onBrowse,
            icon: const Icon(Icons.add, size: 30, color: plantGreen),
          ),
        ),
        Expanded(child: collectionContent),
      ],
    );
  }

  Widget buildPlantList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        for (final CollectionPlant item in plants)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CollectionDetailPage(
                          item: item,
                          onChanged: onChanged,
                          onDelete: () {
                            plants.remove(item);
                            onChanged();
                          },
                        );
                      },
                    ),
                  );
                  if (context.mounted) {
                    onChanged();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: PlantPhoto(plant: item.plant, height: 108),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.plant.name,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.room,
                              style: const TextStyle(
                                color: mutedText,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(
                                  Icons.water_drop_outlined,
                                  size: 17,
                                  color: wateringStatusColor(item),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: wateringStatusColor(item),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: mutedText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color wateringStatusColor(CollectionPlant item) {
    if (item.daysUntilWatering <= 0) {
      return warmBrown;
    }
    return plantGreen;
  }

  Widget emptyCollection() {
    // Center menengahkan isi; scroll tetap tersedia jika layarnya pendek.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/illustration/empty_collection_plant.svg',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
            const Text(
              'No plants in your collection',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 280,
              child: PrimaryButton(
                label: 'Browse plant dictionary',
                icon: Icons.eco_outlined,
                onPressed: onBrowse,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
