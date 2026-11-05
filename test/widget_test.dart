import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/main.dart';
import 'package:my_grovia/pages/collection_page.dart';

import 'catalog_helper.dart';

Future<void> openApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await pumpCatalogApp(tester, const MyGroviaApp());
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Tab changes reset search but preserve bookmarks and watering history',
    (tester) async {
      await openApp(tester);
      await tester.enterText(find.byType(TextField), 'Monstera');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monstera Deliciosa'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Save plant'));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('My collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monstera Deliciosa'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Record watering'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('View all'));
      expect(find.text('300 ml'), findsNWidgets(3));
      await tapVisible(tester, find.text('Show less'));
      expect(find.text('300 ml'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Plant dictionary'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.tap(find.byTooltip('Show saved plants'));
      await tester.pumpAndSettle();
      expect(find.text('Monstera Deliciosa'), findsOneWidget);
      expect(find.text('Calathea Orbifolia'), findsNothing);
      await tester.tap(find.byTooltip('My collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monstera Deliciosa'));
      await tester.pumpAndSettle();
      expect(find.text('In 7 days'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
      await tester.tap(find.byTooltip('Plant options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove plant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Monstera Deliciosa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Location sheet cancels safely and accepts a custom room on a small screen',
    (tester) async {
      await openApp(tester);
      await tester.enterText(find.byType(TextField), 'Pothos');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Golden Pothos'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Add to Collection'));
      final confirm = find.widgetWithText(FilledButton, 'Add to collection');
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.tap(find.text('Living room'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close location selection'));
      await tester.pumpAndSettle();
      expect(find.text('Already in Collection'), findsNothing);
      await tapVisible(tester, find.text('Add to Collection'));
      await tester.tap(find.text('Other room'));
      await tester.pumpAndSettle();
      await tapVisible(tester, confirm);
      expect(find.text('Enter a room name'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '  Balcony  ');
      await tester.pumpAndSettle();
      await tapVisible(tester, confirm);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CollectionPage>(find.byType(CollectionPage))
            .plants
            .length,
        4,
      );
      await tester.scrollUntilVisible(
        find.text('Balcony'),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Balcony'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('My space opens saved plants and clears previous search', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    expect(find.text('Your growing corner'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Due for watering'), findsOneWidget);
    await tester.tap(find.text('Saved plants'));
    await tester.pumpAndSettle();
    expect(find.text('No saved plants yet'), findsOneWidget);
    await tapVisible(tester, find.text('Browse all plants'));
    await tapVisible(tester, find.text('Monstera Deliciosa'));
    await tester.tap(find.byTooltip('Save plant'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Snake Plant');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Saved plants'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Saved plants'));
    await tester.pumpAndSettle();
    expect(find.text('Monstera Deliciosa'), findsOneWidget);
    expect(find.text('Snake Plant'), findsNothing);
    await tester.enterText(find.byType(TextField), 'no match');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved plants'));
    await tester.pumpAndSettle();
    expect(find.text('Monstera Deliciosa'), findsOneWidget);
    await tester.tap(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove bookmark'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('No saved plants yet'), findsOneWidget);
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plants in collection'));
    await tester.pumpAndSettle();
    expect(find.text('My collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search, clear, filter, bookmark and return from detail', (
    tester,
  ) async {
    await openApp(tester);
    expect(find.text('Plant dictionary'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Blue velvet fern');
    await tester.pumpAndSettle();
    expect(find.text('No plants found'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Clear search'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Low light'));
    await tester.pumpAndSettle();
    expect(find.text('Monstera Deliciosa'), findsNothing);
    expect(find.text('Snake Plant'), findsOneWidget);
    await tapVisible(tester, find.text('All plants'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save plant'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show saved plants'));
    await tester.pumpAndSettle();
    expect(find.text('Monstera Deliciosa'), findsOneWidget);
    expect(find.text('Calathea Orbifolia'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add, water, inspect history and remove a plant across routes', (
    tester,
  ) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextField), 'Pothos');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Golden Pothos'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Add to Collection'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tapVisible(tester, find.text('Add to Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bedroom'));
    await tester.pumpAndSettle();
    expect(find.text('Where will your plant live?'), findsOneWidget);
    await tapVisible(tester, find.text('Add to collection'));
    expect(
      tester.widget<CollectionPage>(find.byType(CollectionPage)).plants.length,
      4,
    );
    await tester.scrollUntilVisible(
      find.text('Golden Pothos'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tapVisible(tester, find.text('Golden Pothos'));
    await tester.pumpAndSettle();
    expect(find.text('Care level: easy'), findsNothing);
    expect(find.text('No watering recorded yet.'), findsOneWidget);
    await tester.tap(find.text('Record watering'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a positive whole number'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '250');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('In 7 days'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);
    await tester.tap(find.byTooltip('Plant options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove plant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CollectionPage>(find.byType(CollectionPage)).plants.length,
      3,
    );
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    expect(find.text('My space'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty collection scrolls on a small screen and browse works', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    bool browsed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CollectionPage(
            plants: [],
            onBrowse: () => browsed = true,
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Browse plant dictionary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse plant dictionary'));
    expect(browsed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
