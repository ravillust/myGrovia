import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/widgets/watering_dialog.dart';
import 'package:my_grovia/pages/my_space_page.dart';
import 'package:my_grovia/model/plant.dart';

void main() {
  testWidgets('Watering rejects invalid volume', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WateringDialog())),
    );
    await tester.enterText(find.byType(TextFormField), '0');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a positive whole number'), findsOneWidget);
  });
  testWidgets(
    'Simple My Space counts plants needing attention and opens collection',
    (tester) async {
      int openedCollection = 0;
      const plant = Plant(
        name: 'A',
        botanicalName: '',
        light: '',
        wateringDays: 3,
        temperature: '',
        description: '',
        tip: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MySpacePage(
              plants: [
                CollectionPlant(
                  plant: plant,
                  room: 'Room',
                  added: DateTime.now(),
                  history: [],
                ),
                CollectionPlant(
                  plant: plant,
                  room: 'Room',
                  added: DateTime.now(),
                  history: [
                    WateringEntry(
                      DateTime.now().subtract(const Duration(days: 5)),
                      '',
                      100,
                    ),
                  ],
                ),
                CollectionPlant(
                  plant: plant,
                  room: 'Room',
                  added: DateTime.now(),
                  history: [WateringEntry(DateTime.now(), '', 100)],
                ),
              ],
              onOpenCollection: () => openedCollection++,
            ),
          ),
        ),
      );
      expect(find.byType(ListTile), findsNWidgets(2));
      final collectionRow = find.widgetWithText(ListTile, 'My collection');
      expect(
        find.descendant(of: collectionRow, matching: find.text('3')),
        findsOneWidget,
      );
      final dueRow = find.widgetWithText(ListTile, 'To check today');
      expect(
        find.descendant(of: dueRow, matching: find.text('2')),
        findsOneWidget,
      );
      expect(find.text('A'), findsNothing);
      expect(find.textContaining('Swagger'), findsNothing);
      await tester.tap(dueRow);
      await tester.pump();
      expect(openedCollection, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
