import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/pages/edit_plant_page.dart';
import 'package:my_grovia/services/database_helper.dart';
import 'package:my_grovia/widgets/plant_widgets.dart';

void main() {
  for (final hasPhoto in [true, false]) {
    testWidgets(
      'Restore default photo, cancel and persist (photo: $hasPhoto)',
      (tester) async {
        sqfliteFfiInit();
        late DatabaseHelper helper;
        late CollectionPlant item;
        final previousHelper = DatabaseHelper.instance;
        final image = hasPhoto ? 'assets/plants/catalog/test.jpg' : null;
        await tester.runAsync(() async {
          final folder = await Directory('build').createTemp('default-photo-');
          helper = DatabaseHelper(
            factory: databaseFactoryFfi,
            directory: folder.path,
            initialCatalog: [
              {
                'id': 'plant-a',
                'name': 'Plant A',
                'image': image,
                'photo_reference': hasPhoto ? 'Photo credit' : '',
              },
            ],
          );
          DatabaseHelper.instance = helper;
          await helper.savePhoto(
            'personal',
            Uint8List.fromList([255, 216, 255, 0]),
          );
          await helper.savePlant(
            'collection-a',
            Plant.fromJson({
              'id': 'plant-a',
              'name': 'My plant',
              'image': 'local:personal',
              'watering_days': 4,
            }),
            'Desk',
            create: true,
          );
          await helper.water(
            'collection-a',
            'water-a',
            WateringEntry(DateTime.now(), 'Keep', 100),
          );
          item = (await helper.collection()).single;
        });
        Future<void> settle() async {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pumpAndSettle();
        }

        Future<void> tap(String text) async {
          await tester.ensureVisible(find.text(text));
          await tester.tap(find.text(text));
          await settle();
        }

        try {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => EditPlantPage(item: item),
                      ),
                    ),
                    child: const Text('Open edit'),
                  ),
                ),
              ),
            ),
          );
          await tap('Open edit');
          await tap('Use default photo');
          expect(
            tester.widget<PlantPhoto>(find.byType(PlantPhoto)).plant.image,
            image,
          );
          await tester.pageBack();
          await settle();
          await tester.runAsync(() async {
            expect(
              (await helper.collection()).single.plant.image,
              'local:personal',
            );
          });
          await tap('Open edit');
          await tap('Use default photo');
          await tap('Save');
          await tester.pumpWidget(const SizedBox());
          await tester.runAsync(() async {
            await helper.close();
            final restored = (await helper.collection()).single;
            expect(restored.plant.image, image);
            expect(
              restored.plant.photoReference,
              hasPhoto ? 'Photo credit' : '',
            );
            expect(restored.plant.name, 'My plant');
            expect(restored.plant.wateringDays, 4);
            expect(restored.history.single.note, 'Keep');
          });
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox());
          await tester.runAsync(() => helper.close());
          DatabaseHelper.instance = previousHelper;
        }
      },
    );
  }
}
