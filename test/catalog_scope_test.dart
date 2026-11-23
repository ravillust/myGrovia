import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test(
    'Version 2 catalog becomes houseplants without losing saved plants',
    () async {
      sqfliteFfiInit();
      final folder = await Directory('build').createTemp('catalog-scope-');
      final catalog = jsonDecode(
        File('assets/data/catalog.json').readAsStringSync(),
      ) as List;
      final archived = {
        'id': 'outdoor-tree',
        'name': 'Existing outdoor tree',
        'watering_days': 7,
        'image': catalog.firstWhere((row) => row['image'] != null)['image'],
        'photo_reference': 'Existing photo credit',
      };
      var helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: folder.path,
        initialCatalog: [...catalog, archived],
      );
      try {
        await helper.savePlant(
          'kept-plant',
          Plant.fromJson(archived),
          'Terrace',
          create: true,
        );
        await helper.water(
          'kept-plant',
          'first-action',
          WateringEntry(DateTime.now(), 'Before update', 200),
        );
        await (await helper.database).execute(
          'ALTER TABLE catalog DROP COLUMN active',
        );
        await (await helper.database).setVersion(2);
        await helper.close();
        helper = DatabaseHelper(
          factory: databaseFactoryFfi,
          directory: folder.path,
          initialCatalog: catalog,
        );
        expect(await (await helper.database).getVersion(), 4);
        expect((await helper.catalog()).length, 297);
        expect(await helper.catalog(query: 'outdoor'), isEmpty);
        await expectLater(
          helper.detail('outdoor-tree'),
          throwsA(isA<StorageException>()),
        );
        var saved = (await helper.collection()).single;
        expect(saved.plant.image, archived['image']);
        expect(saved.plant.photoReference, 'Existing photo credit');
        expect(saved.history.single.note, 'Before update');
        await helper.savePlant(
          saved.id!,
          saved.plant.withWateringDays(3),
          'Living room',
        );
        await helper.water(
          saved.id!,
          'second-action',
          WateringEntry(DateTime.now(), 'After update', 150),
        );
        await expectLater(
          helper.savePlant(
            'new-tree',
            Plant.fromJson(archived),
            'Terrace',
            create: true,
          ),
          throwsA(isA<StorageException>()),
        );
        // Retry penambahan sebelum upgrade tetap menunjuk koleksi yang sama.
        await helper.savePlant(
          'kept-plant',
          Plant.fromJson(archived),
          'Terrace',
          create: true,
        );
        await helper.close();
        helper = DatabaseHelper(
          factory: databaseFactoryFfi,
          directory: folder.path,
          initialCatalog: catalog,
        );
        saved = (await helper.collection()).single;
        expect(saved.room, 'Living room');
        expect(saved.plant.wateringDays, 3);
        expect(saved.history.length, 2);
        expect((await helper.catalog()).length, 297);
        await helper.deletePlant(saved.id!);
        expect(await helper.collection(), isEmpty);
        expect(await (await helper.database).query('watering'), isEmpty);
      } finally {
        await helper.close();
      }
    },
  );
}
