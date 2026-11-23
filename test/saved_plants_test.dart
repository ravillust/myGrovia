import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/services/database_helper.dart';

void main() {
  test(
    'Version 3 migration and bookmarks survive restart and catalog rename',
    () async {
      sqfliteFfiInit();
      final folder = await Directory('build').createTemp('saved-plants-');
      var catalog = <dynamic>[
        {'id': 'plant-a', 'name': 'Original name'},
      ];
      var helper = DatabaseHelper(
        factory: databaseFactoryFfi,
        directory: folder.path,
        initialCatalog: catalog,
      );
      try {
        await helper.savePlant(
          'collection-a',
          await helper.detail('plant-a'),
          'Room',
          create: true,
        );
        await helper.water(
          'collection-a',
          'water-a',
          WateringEntry(DateTime.now(), 'Keep history', 200),
        );
        final db = await helper.database;
        await db.execute('DROP TABLE bookmarks');
        await db.setVersion(3);
        await helper.close();
        helper = DatabaseHelper(
          factory: databaseFactoryFfi,
          directory: folder.path,
          initialCatalog: catalog,
        );
        expect(await helper.bookmarks(), isEmpty);
        expect(
          (await helper.collection()).single.history.single.note,
          'Keep history',
        );
        await helper.saveBookmark('plant-a', saved: true);
        await helper.saveBookmark('plant-a', saved: true);
        await expectLater(
          helper.saveBookmark('missing', saved: true),
          throwsA(isA<StorageException>()),
        );
        await helper.close();
        catalog = [
          {'id': 'plant-a', 'name': 'Renamed plant'},
        ];
        helper = DatabaseHelper(
          factory: databaseFactoryFfi,
          directory: folder.path,
          initialCatalog: catalog,
        );
        expect(await helper.bookmarks(), {'plant-a'});
        expect((await helper.detail('plant-a')).name, 'Renamed plant');
        await helper.saveBookmark('plant-a', saved: false);
        await helper.close();
        expect(await helper.bookmarks(), isEmpty);
        expect(
          (await helper.collection()).single.history.single.note,
          'Keep history',
        );
      } finally {
        await helper.close();
      }
    },
  );
}
