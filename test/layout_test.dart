import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_grovia/pages/edit_plant_page.dart';
import 'package:my_grovia/pages/collection_page.dart';
import 'package:my_grovia/pages/plant_detail_page.dart';
import 'package:my_grovia/pages/collection_detail_page.dart';
import 'package:my_grovia/pages/dictionary_page.dart';
import 'package:my_grovia/widgets/plant_widgets.dart';
import 'package:my_grovia/model/plant.dart';

CollectionPlant editItem() => CollectionPlant(
  id: 'test',
  plant: const Plant(
    name: '',
    botanicalName: '',
    light: '',
    wateringDays: 7,
    temperature: '',
    description: '',
    tip: '',
  ),
  room: 'Room',
  added: DateTime(2026),
  history: [],
);

void main() {
  testWidgets('Small screen supports edit form and empty collection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final page in <Widget>[
      EditPlantPage(item: editItem()),
      Scaffold(
        body: CollectionPage(plants: [], onBrowse: () {}, onChanged: () {}),
      ),
      CollectionDetailPage(item: editItem(), onChanged: () {}, onDelete: () {}),
      Scaffold(
        body: DictionaryPage(
          catalog: [],
          collection: [],
          bookmarks: {},
          onAdd: (_, _) async {},
          onBookmark: (_) async {},
          savedOnly: true,
          onSavedOnlyChanged: (_) {},
        ),
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'Missing botanical name removes its line and brings the summary up',
    (tester) async {
      Future<double> summaryGap(String botanicalName) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PlantDetailPage(
              plant: Plant(
                name: 'Plant title',
                botanicalName: botanicalName,
                light: 'Medium indirect',
                wateringDays: 7,
                temperature: '18 - 24 C',
                description: 'Plant summary',
                tip: '',
              ),
              isSaved: false,
              isAdded: false,
              onBookmark: () async {},
              onAdd: (_, _) async {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        return tester.getTopLeft(find.text('Plant summary')).dy -
            tester.getBottomLeft(find.text('Plant title')).dy;
      }

      final withName = await summaryGap('Botanical name');
      final withoutName = await summaryGap('');
      expect(find.text(''), findsNothing);
      expect(withoutName, lessThan(withName));
    },
  );
  testWidgets(
    'Empty saved plants centers its message below the heading and can browse again',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool? savedOnly;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DictionaryPage(
              catalog: [],
              collection: [],
              bookmarks: {},
              onAdd: (_, _) async {},
              onBookmark: (_) async {},
              savedOnly: true,
              onSavedOnlyChanged: (value) => savedOnly = value,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final headingBottom = tester.getBottomLeft(find.byType(PageHeading)).dy;
      final pageBottom = tester.getBottomLeft(find.byType(Scaffold)).dy;
      expect(
        tester.getCenter(find.byKey(const ValueKey('empty-saved-message'))).dy,
        closeTo((headingBottom + pageBottom) / 2, 1),
      );
      await tester.tap(find.text('Browse all plants'));
      await tester.pump();
      expect(savedOnly, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Edit form validates name and interval', (tester) async {
    await tester.pumpWidget(MaterialApp(home: EditPlantPage(item: editItem())));
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a plant name'), findsOneWidget);
    expect(find.text('Enter a number from 1 to 365'), findsOneWidget);
  });
}
