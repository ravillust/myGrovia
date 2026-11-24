import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/widgets/watering_dialog.dart';
import 'package:my_grovia/pages/dictionary_page.dart';

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
    'Dictionary menu opens saved plants and scrollable sources on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool savedOnly = false;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: DictionaryPage(
                catalog: [],
                collection: [],
                bookmarks: {},
                onAdd: (_, _) async {},
                onBookmark: (_) async {},
                savedOnly: savedOnly,
                onSavedOnlyChanged: (value) =>
                    setState(() => savedOnly = value),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> choose(String label) async {
        await tester.tap(find.byTooltip('Dictionary options'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      await choose('Saved plants');
      expect(find.text('No saved plants yet'), findsOneWidget);
      await choose('About & sources');
      expect(find.textContaining('CC BY-NC-SA 4.0'), findsOneWidget);
      await tester.ensureVisible(find.text('Plant photos'));
      await tester.pumpAndSettle();
      expect(find.text('Plant photos').hitTestable(), findsOneWidget);
      expect(find.textContaining('Sources & credits'), findsOneWidget);
      await tester.ensureVisible(find.text('Watering guidance'));
      await tester.pumpAndSettle();
      expect(find.text('Watering guidance').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('No saved plants yet'), findsOneWidget);
      await choose('All plants');
      expect(find.text('Plant dictionary'), findsOneWidget);
      await choose('Privacy policy');
      expect(find.text('myGrovia Privacy Policy'), findsOneWidget);
      expect(find.text('support.grovia@gmail.com'), findsOneWidget);
      await tester.ensureVisible(find.text('Retention and deletion'));
      await tester.pumpAndSettle();
      expect(find.text('Retention and deletion').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Plant dictionary'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
