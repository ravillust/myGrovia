import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_grovia/services/database_helper.dart';
import 'package:my_grovia/model/plant.dart';

Uint8List catalogPhotoBytes() {
  final catalog =
      jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List;
  final photo =
      catalog.firstWhere((row) => row['image'] != null)['image'] as String;
  return File(photo).readAsBytesSync();
}

void main() {
  test(
    'Catalog photo refresh preserves private photos and watering history',
    () async {
      sqfliteFfiInit();
      final temp = await Directory('build').createTemp('photo-upgrade-');
      final original = {
        'id': 'catalog-a',
        'name': 'A',
        'watering_days': 7,
        'image': 'assets/plants/monstera_photo.jpg',
        'photo_reference': 'Original credit',
      };
      var helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: temp.path,
        initialCatalog: [original],
      );
      final plant = Plant.fromJson(original);
      await helper.savePlant('default-photo', plant, 'Room', create: true);
      final bytes = catalogPhotoBytes();
      final privateImage = await helper.savePhoto('personal-photo', bytes);
      await helper.savePlant(
        'private-photo',
        Plant(
          id: plant.id,
          name: 'My own photo',
          botanicalName: '',
          image: privateImage,
          light: '',
          wateringDays: 3,
          temperature: '',
          description: '',
          tip: '',
        ),
        'Room',
        create: true,
      );
      await helper.water(
        'default-photo',
        'kept-history',
        WateringEntry(DateTime.now(), 'keep', 200),
      );
      await helper.close();
      helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: temp.path,
        initialCatalog: [
          {
            ...original,
            'image': 'assets/plants/calathea_photo.jpg',
            'photo_reference': 'New licensed credit',
          },
        ],
      );
      final restored = await helper.collection();
      final defaultPhoto = restored.firstWhere((p) => p.id == 'default-photo');
      final privatePhoto = restored.firstWhere((p) => p.id == 'private-photo');
      expect(defaultPhoto.plant.image, 'assets/plants/calathea_photo.jpg');
      expect(defaultPhoto.plant.photoReference, 'New licensed credit');
      expect(defaultPhoto.history.single.note, 'keep');
      expect(privatePhoto.plant.image, privateImage);
      expect(privatePhoto.plant.photoReference, isEmpty);
      expect(privatePhoto.plant.wateringDays, 3);
      await helper.close();
      helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: temp.path,
        initialCatalog: [
          {...original, 'image': null, 'photo_reference': ''},
        ],
      );
      final withdrawn = await helper.collection();
      expect(
        withdrawn.firstWhere((p) => p.id == 'default-photo').plant.image,
        isNull,
      );
      expect(
        withdrawn
            .firstWhere((p) => p.id == 'default-photo')
            .history
            .single
            .note,
        'keep',
      );
      expect(
        withdrawn.firstWhere((p) => p.id == 'private-photo').plant.image,
        privateImage,
      );
      await helper.close();
    },
  );

  test(
    'SQLite CRUD, validation, concurrent watering, private photos and restart',
    () async {
      sqfliteFfiInit();
      final temp = await Directory('build').createTemp('database-test-');
      final catalog = jsonDecode(
        File('assets/data/catalog.json').readAsStringSync(),
      ) as List;
      var helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: temp.path,
        initialCatalog: catalog,
      );
      try {
        final plants = await helper.catalog();
        expect(plants.length, 297);
        final plant = plants.firstWhere((p) => p.id == 'swiss-cheese-plant');
        expect(
          (await helper.detail(plant.id!)).fullDescription,
          contains(plant.description),
        );
        expect(await helper.catalog(query: 'Monstera'), isNotEmpty);
        expect(await helper.collection(), isEmpty);
        await helper.savePlant('plant-a', plant, 'Room', create: true);
        await helper.savePlant('plant-a', plant, 'Room', create: true);
        expect((await helper.collection()).length, 1);
        expect((await helper.collection()).single.nextWatering, isNull);
        await helper.savePlant('plant-a', plant.withWateringDays(3), 'Balcony');
        await expectLater(
          helper.savePlant('plant-a', plant.withWateringDays(0), 'Room'),
          throwsA(isA<StorageException>()),
        );
        await expectLater(
          helper.savePlant('plant-a', plant, '   '),
          throwsA(isA<StorageException>()),
        );
        final entry = WateringEntry(DateTime(2000), 'Checked soil', 300);
        final replies = await Future.wait([
          helper.water('plant-a', 'action-a', entry),
          helper.water('plant-a', 'action-a', entry),
        ]);
        expect(replies.first.date, replies.last.date);
        expect(replies.first.date.year, DateTime.now().year);
        await expectLater(
          helper.water(
            'plant-a',
            'action-a',
            WateringEntry(DateTime.now(), 'Different', 500),
          ),
          throwsA(isA<StorageException>()),
        );
        await expectLater(
          helper.water('missing', 'new-action', entry),
          throwsA(isA<StorageException>()),
        );
        expect((await helper.collection()).single.history.length, 1);
        await helper.water(
          'plant-a',
          'action-b',
          WateringEntry(DateTime.now(), 'Again', 100),
        );
        final bytes = catalogPhotoBytes();
        final image = await helper.savePhoto('photo-a', bytes);
        final custom = Plant.fromJson({
          'id': plant.id,
          'name': 'My Monstera',
          'image': image,
          'watering_days': 3,
        });
        await helper.savePlant('plant-a', custom, 'Balcony');
        await expectLater(
          helper.photo('../escape'),
          throwsA(isA<StorageException>()),
        );
        await expectLater(
          helper.savePhoto('bad-photo', Uint8List.fromList([1, 2, 3])),
          throwsA(isA<StorageException>()),
        );
        await helper.close();
        helper = DatabaseHelper(
          factory: databaseFactoryFfi,
          directory: temp.path,
          initialCatalog: catalog,
        );
        final restored = (await helper.collection()).single;
        expect(restored.plant.name, 'My Monstera');
        expect(restored.plant.image, image);
        expect(restored.plant.photoReference, isEmpty);
        expect(restored.room, 'Balcony');
        expect(restored.history.length, 2);
        expect(restored.history.first.note, 'Again');
        expect(restored.daysUntilWatering, 3);
        expect(await helper.photo('photo-a'), bytes);
        await helper.deletePlant('plant-a');
        expect(await helper.collection(), isEmpty);
        expect(await (await helper.database).query('watering'), isEmpty);
      } finally {
        await helper.close();
      }
    },
  );

  test(
    'Version 1 migration preserves existing collection and history',
    () async {
      sqfliteFfiInit();
      final temp = await Directory('build').createTemp('migration-test-');
      var helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: temp.path,
        initialCatalog: [],
      );
      await helper.savePlant(
        'old',
        const Plant(
          name: 'Old',
          botanicalName: '',
          light: '',
          wateringDays: 7,
          temperature: '',
          description: '',
          tip: '',
        ),
        'Room',
        create: true,
      );
      await helper.water(
        'old',
        'old-action',
        WateringEntry(DateTime.now(), 'Old note', 200),
      );
      await (await helper.database).execute('DROP INDEX watering_by_plant');
      await (await helper.database).execute(
        'ALTER TABLE catalog DROP COLUMN active',
      );
      await (await helper.database).setVersion(1);
      await helper.close();
      helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: temp.path,
        initialCatalog: [],
      );
      expect(
        (await helper.collection()).single.history.single.note,
        'Old note',
      );
      expect(await (await helper.database).getVersion(), 3);
      await helper.close();
    },
  );
}
