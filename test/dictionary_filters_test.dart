import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/pages/dictionary_page.dart';

List<Plant> catalog() {
  final rows =
      jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List;
  return [
    for (final row in rows)
      Plant.fromJson({...row as Map<String, dynamic>, 'image': null}),
  ];
}

Widget page({bool savedOnly = false, Set<String> bookmarks = const {}}) =>
    MaterialApp(
      home: Scaffold(
        body: DictionaryPage(
          catalog: catalog(),
          collection: [],
          bookmarks: bookmarks,
          onAdd: (_, _) async {},
          onBookmark: (_) async {},
          savedOnly: savedOnly,
          onSavedOnlyChanged: (_) {},
        ),
      ),
    );

Future<void> selectFilter(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(ChoiceChip, label);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Light filters match the complete real catalog and combine with search',
    (tester) async {
      await tester.pumpWidget(page());
      await tester.pumpAndSettle();
      expect(find.text('Easy care'), findsNothing);
      expect(find.text('297 plants'), findsOneWidget);
      for (final entry in {
        'Indirect light': 253,
        'Direct sunlight': 27,
        'Low light': 17,
      }.entries) {
        await selectFilter(tester, entry.key);
        expect(find.text('${entry.value} plants'), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
      }
      await selectFilter(tester, 'Direct sunlight');
      expect(find.text('27 plants'), findsOneWidget);
      expect(find.text('Light requirements'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Adenium');
      await tester.pumpAndSettle();
      expect(find.text('1 plant'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == 'Adenium',
        ),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'Monstera deliciosa');
      await tester.pumpAndSettle();
      expect(find.text('0 plants'), findsOneWidget);
      expect(find.text('No plants found'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('297 plants'), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'All plants'))
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Filters stay in one scrollable row and work with bookmarks on small screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        page(savedOnly: true, bookmarks: {'swiss-cheese-plant', 'adenium'}),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 plants'), findsOneWidget);
      final allPlants = find.widgetWithText(ChoiceChip, 'All plants');
      final shade = find.widgetWithText(ChoiceChip, 'Low light');
      final firstPosition = tester.getTopLeft(allPlants);
      expect(tester.getTopLeft(shade).dy, firstPosition.dy);
      await tester.drag(
        find.byKey(const ValueKey('dictionary-filters')),
        const Offset(-700, 0),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(allPlants).dx, lessThan(firstPosition.dx));
      expect(
        shade.hitTestable(),
        findsOneWidget,
        reason: 'Low light position after scrolling: ${tester.getRect(shade)}',
      );
      expect(find.text('2 plants'), findsOneWidget);
      await selectFilter(tester, 'Direct sunlight');
      expect(find.text('1 plant'), findsOneWidget);
      expect(find.text('Adenium'), findsOneWidget);
      expect(find.text('Monstera Deliciosa'), findsNothing);
      await selectFilter(tester, 'Low light');
      expect(find.text('0 plants'), findsOneWidget);
      expect(find.text('No plants found'), findsOneWidget);
      await selectFilter(tester, 'All plants');
      expect(find.text('2 plants'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
