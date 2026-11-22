import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/pages/plant_detail_page.dart';

void main() {
  test('Bundled catalog has unique IDs, offline photos and honest missing intervals', () {
    final rows =
        jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List;
    expect(rows.length, 297);
    expect(rows.map((r) => r['id']).toSet().length, 297);
    final ids = rows.map((row) => row['id']).toSet();
    expect(
      ids,
      containsAll([
        'swiss-cheese-plant',
        'golden-pothos',
        'adenium',
        'phalaenopsis-orchids',
      ]),
    );
    for (final excluded in [
      'oak',
      'apple',
      'corn',
      'hemp',
      'tobacco',
      'saguaro',
      'corpse-flower',
      'welwitschia',
    ]) {
      expect(ids, isNot(contains(excluded)));
    }
    for (final row in rows) {
      expect(row['source_category'], startsWith('Houseplants - '));
      expect(
        row['reference'],
        contains('bbb364534cfbca28168085897ac9f2ff00a151a5'),
      );
      expect(row['description'], contains(row['summary']));
      if (row['image'] != null) {
        expect(row['image'], startsWith('assets/'));
        expect(File(row['image']).existsSync(), isTrue);
      }
    }
    expect(rows.where((r) => r['watering_days'] == null).length, 1);
    final manifestFile = File('third_party/catalog_photos/manifest.json');
    final manifest = manifestFile.existsSync()
        ? jsonDecode(manifestFile.readAsStringSync()) as List
        : <dynamic>[];
    final downloaded = {
      for (final entry in manifest)
        if (entry['status'] == 'downloaded') entry['id']: entry,
    };
    for (final row in rows) {
      final photo = downloaded[row['id']];
      if (photo != null) {
        expect(row['image'], photo['asset']);
        expect(row['photo_reference'], contains(photo['source_page']));
        expect(row['photo_reference'], contains(photo['license']));
        final bytes = File(photo['asset']).readAsBytesSync();
        expect(bytes.take(2), [255, 216]);
        expect(bytes.length, photo['bytes']);
        expect(bytes.length, lessThan(250000));
      } else {
        expect(
          (row['image'] as String?)?.contains('catalog_') ?? false,
          isFalse,
        );
      }
    }
  });

  testWidgets(
    'Unknown interval asks the user before adding; cancel does not add',
    (tester) async {
      var added = false;
      final plant = Plant.fromJson({
        'id': 'unknown',
        'name': 'Unknown',
        'watering_days': null,
      });
      expect(plant.wateringKnown, isFalse);
      await tester.pumpWidget(
        MaterialApp(
          home: PlantDetailPage(
            plant: plant,
            isSaved: false,
            isAdded: false,
            onBookmark: () {},
            onAdd: (room, days) async {
              added = true;
            },
          ),
        ),
      );
      await tester.ensureVisible(find.text('Add to Collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Collection'));
      await tester.pumpAndSettle();
      expect(find.text('Set watering interval'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Enter a number from 1 to 365'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(added, isFalse);
    },
  );

  test('Schedule uses local calendar day across year boundary', () {
    final plant = CollectionPlant(
      plant: const Plant(
        name: 'A',
        botanicalName: '',
        light: '',
        wateringDays: 7,
        temperature: '',
        description: '',
        tip: '',
      ),
      room: 'Room',
      added: DateTime(2026),
      history: [WateringEntry(DateTime(2026, 12, 30, 23, 59), '', 100)],
    );
    expect(plant.nextWatering, DateTime(2027, 1, 6));
    plant.history.clear();
    expect(plant.nextWatering, isNull);
    expect(plant.daysUntilWatering, 0);
  });
}
