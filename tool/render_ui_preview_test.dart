// Run: flutter test tool/render_ui_preview_test.dart --update-goldens --no-pub
// Preview images are written to build/ui-previews, not committed as test baselines.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_grovia/main.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/pages/collection_detail_page.dart';
import 'package:my_grovia/pages/collection_page.dart';
import 'package:my_grovia/pages/dictionary_page.dart';
import 'package:my_grovia/pages/plant_detail_page.dart';
import 'package:my_grovia/pages/my_space_page.dart';
import 'package:my_grovia/services/api_service.dart';
import 'package:my_grovia/widgets/plant_information_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'SemiBold', 'Bold']) {
      loader.addFont(
        rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
      );
    }
    await loader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('Render current pages at phone size', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rows =
        jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List;
    Plant plant(String id) =>
        Plant.fromJson(rows.firstWhere((row) => row['id'] == id));
    final monstera = plant('swiss-cheese-plant');
    final adenium = plant('adenium');
    final date = DateTime.now();
    final now = DateTime(date.year, date.month, date.day, 9, 30);
    final today = CollectionPlant(
      id: 'preview',
      plant: monstera,
      room: 'Living room',
      added: now,
      history: [
        WateringEntry(
          now.subtract(Duration(days: monstera.wateringDays)),
          'Regular watering',
          300,
        ),
      ],
    );
    final never = CollectionPlant(
      id: 'preview-empty',
      plant: adenium,
      room: 'Home office',
      added: now,
      history: [],
    );
    final folder = Directory('build/ui-previews');
    folder.createSync(recursive: true);
    final pages = <String, Widget>{
      'read-more-offline': Scaffold(
        body: PlantInformationDialog(
          plant: monstera,
          apiService: ApiService(
            client: MockClient((_) async => http.Response('', 503)),
          ),
        ),
      ),
      'read-more-online': Scaffold(
        body: PlantInformationDialog(
          plant: monstera,
          apiService: ApiService(
            client: MockClient(
              (_) async => http.Response.bytes(
                File('third_party/plantfolio/source.json').readAsBytesSync(),
                200,
              ),
            ),
          ),
        ),
      ),
      'dictionary-filter': Scaffold(
        body: DictionaryPage(
          catalog: [for (final row in rows) Plant.fromJson(row)],
          collection: [],
          bookmarks: {},
          onAdd: (_, _) async {},
          onBookmark: (_) {},
          savedOnly: false,
          onSavedOnlyChanged: (_) {},
        ),
      ),
      'saved-empty': Scaffold(
        body: DictionaryPage(
          catalog: [],
          collection: [],
          bookmarks: {},
          onAdd: (_, _) async {},
          onBookmark: (_) {},
          savedOnly: true,
          onSavedOnlyChanged: (_) {},
        ),
      ),
      'dictionary': Scaffold(
        body: DictionaryPage(
          catalog: [
            monstera,
            adenium,
            plant('calathea-orbifolia'),
            plant('snake-plants'),
          ],
          collection: [],
          bookmarks: {},
          onAdd: (_, _) async {},
          onBookmark: (_) {},
          savedOnly: false,
          onSavedOnlyChanged: (_) {},
        ),
      ),
      'detail-no-latin': PlantDetailPage(
        plant: adenium,
        isSaved: false,
        isAdded: false,
        onBookmark: () {},
        onAdd: (_, _) async {},
      ),
      'collection': Scaffold(
        body: CollectionPage(
          plants: [today, never],
          onBrowse: () {},
          onChanged: () {},
        ),
      ),
      'collection-detail': CollectionDetailPage(
        item: today,
        onChanged: () {},
        onDelete: () {},
      ),
      'my-space': Scaffold(
        body: MySpacePage(plants: [today, never], onOpenCollection: () {}),
      ),
    };
    for (final entry in pages.entries) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final app = const MyGroviaApp().build(context) as MaterialApp;
            return RepaintBoundary(
              key: const ValueKey('preview'),
              child: MaterialApp(
                key: ValueKey(entry.key),
                debugShowCheckedModeBanner: app.debugShowCheckedModeBanner,
                theme: app.theme,
                home: entry.value,
              ),
            );
          },
        ),
      );
      await tester.runAsync(() async {
        for (final item in [
          monstera,
          adenium,
          plant('calathea-orbifolia'),
          plant('snake-plants'),
        ]) {
          if (item.image != null) {
            await precacheImage(
              AssetImage(item.image!),
              tester.element(find.byType(MaterialApp)),
            );
          }
        }
      });
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      if (entry.key == 'dictionary-filter') {
        await tester.tap(find.text('Indirect light'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      if (entry.key == 'my-space') {
        expect(
          tester.getTopLeft(find.text('My space')).dy,
          greaterThanOrEqualTo(24),
        );
      }
      await expectLater(
        find.byKey(const ValueKey('preview')),
        matchesGoldenFile(
          Uri.file(
            '${Directory.current.path}/build/ui-previews/${entry.key}.png',
          ),
        ),
      );
    }
  });
}
