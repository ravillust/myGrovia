import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_grovia/main.dart';
import 'package:my_grovia/services/database_helper.dart';

void main() {
  testWidgets(
    'Offline UI with SQLite: search, fallback, add, water, edit, restart, delete',
    (tester) async {
      sqfliteFfiInit();
      late DatabaseHelper helper;
      late Directory directory;
      late List<dynamic> catalog;
      await tester.runAsync(() async {
        await Directory('build').create(recursive: true);
        directory = await Directory('build').createTemp('ui-offline-');
        catalog = jsonDecode(
          await File('assets/data/catalog.json').readAsString(),
        ) as List;
        helper = DatabaseHelper(
          factory: databaseFactoryFfi,
          directory: directory.path,
          initialCatalog: catalog,
        );
        await helper.database;
        DatabaseHelper.instance = helper;
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> settle() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pumpAndSettle();
      }

      Future<void> waitFor(Finder finder) async {
        for (int i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
          await settle();
        }
        if (finder.evaluate().isEmpty) {
          debugPrint(
            tester
                .widgetList<Text>(find.byType(Text))
                .map((w) => w.data)
                .join(' | '),
          );
        }
        expect(finder, findsWidgets);
      }

      Future<void> tap(Finder finder) async {
        await waitFor(finder);
        await tester.ensureVisible(finder.first);
        await tester.pumpAndSettle();
        await tester.tap(finder.first);
        await settle();
      }

      try {
        await tester.pumpWidget(const MyGroviaApp());
        await waitFor(find.byType(TextField));
        expect(find.byTooltip('My space'), findsNothing);
        final bar = tester
            .widget<Scaffold>(find.byType(Scaffold).first)
            .bottomNavigationBar!;
        expect(
          find.descendant(
            of: find.byWidget(bar),
            matching: find.byType(IconButton),
          ),
          findsNWidgets(2),
        );
        await tester.enterText(find.byType(TextField), 'Monstera');
        await settle();
        await tap(find.text('Monstera Deliciosa'));
        await tap(find.byTooltip('Save plant'));
        await waitFor(find.byTooltip('Remove bookmark'));
        await tap(find.text('Read more'));
        await tap(find.text('Sources & credits'));
        await waitFor(find.text('Description source'));
        expect(
          find.textContaining('Showing the saved description'),
          findsOneWidget,
        );
        await tap(find.text('Close'));
        await tap(find.text('Add to Collection'));
        await tap(find.text('Living room'));
        await tap(find.widgetWithText(FilledButton, 'Add to collection'));
        await waitFor(find.text('My collection'));
        await tap(find.text('Monstera Deliciosa'));
        await tap(find.text('Record watering'));
        await tap(find.text('Save'));
        await waitFor(find.text('Watering recorded'));
        await tap(find.byTooltip('Plant options'));
        await tap(find.text('Edit plant'));
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Monstera rumah',
        );
        await tester.enterText(find.byType(TextFormField).at(2), '4');
        await tap(find.text('Save'));
        await waitFor(find.text('In 4 days'));
        await tap(find.byTooltip('Back'));
        await tap(find.byTooltip('Add a plant'));
        await waitFor(find.byType(TextField));
        await tester.enterText(find.byType(TextField), 'Pothos');
        await settle();
        await tap(find.text('Golden Pothos'));
        await tap(find.text('Add to Collection'));
        await tap(find.text('Living room'));
        await tap(find.widgetWithText(FilledButton, 'Add to collection'));
        await waitFor(find.text('My collection'));
        await waitFor(find.text('Golden Pothos'));

        // Tutup dan buka lagi file SQLite yang sama untuk menguji persistensi.
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await helper.close();
          helper = DatabaseHelper(
            factory: databaseFactoryFfi,
            directory: directory.path,
            initialCatalog: catalog,
          );
          await helper.database;
          DatabaseHelper.instance = helper;
        });
        await tester.pumpWidget(const MyGroviaApp());
        await waitFor(find.byType(TextField));
        await tap(find.byTooltip('Dictionary options'));
        await tap(find.text('Saved plants'));
        expect(find.text('1 plant'), findsOneWidget);
        await tap(find.text('Monstera Deliciosa'));
        expect(find.text('Already in Collection'), findsOneWidget);
        await tap(find.byTooltip('Remove bookmark'));
        await waitFor(find.byTooltip('Save plant'));
        await tap(find.byTooltip('Back'));
        await waitFor(find.text('No saved plants yet'));
        await tester.runAsync(() async {
          expect(await helper.bookmarks(), isEmpty);
        });
        await tap(find.byTooltip('My collection'));
        await tap(find.text('Monstera rumah'));
        expect(find.text('In 4 days'), findsOneWidget);
        await tester.runAsync(() async {
          final plants = await DatabaseHelper.instance.collection();
          expect(plants.length, 2);
          expect(
            plants
                .firstWhere((p) => p.plant.name == 'Monstera rumah')
                .history
                .length,
            1,
          );
        });
        await tap(find.byTooltip('Plant options'));
        await tap(find.text('Remove plant'));
        await tap(find.text('Cancel'));
        expect(find.text('Monstera rumah'), findsOneWidget);
        await tap(find.byTooltip('Plant options'));
        await tap(find.text('Remove plant'));
        await tap(find.text('Remove'));
        await waitFor(find.text('Golden Pothos'));
        expect(find.text('Monstera rumah'), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() => helper.close());
      }
    },
  );
}
