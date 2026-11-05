import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/main.dart';

import 'catalog_helper.dart';

void main() {
  testWidgets('Small screen routes and visual previews', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previewKey = GlobalKey();
    final jakarta = FontLoader('PlusJakartaSans')
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'));
    await jakarta.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    await pumpCatalogApp(
      tester,
      RepaintBoundary(key: previewKey, child: const MyGroviaApp()),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      for (final path in [
        'assets/plants/monstera_photo.jpg',
        'assets/plants/calathea_photo.jpg',
        'assets/plants/snake_plant_photo.jpg',
        'assets/plants/golden_pothos.jpg',
      ]) {
        await precacheImage(AssetImage(path), previewKey.currentContext!);
      }
    });
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
      final boundary =
          previewKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 1);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        final folder = Directory('build/ui-previews');
        await folder.create(recursive: true);
        await File('${folder.path}/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }

    await capture('dictionary');
    await tester.enterText(find.byType(TextField), 'Pothos');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Golden Pothos'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add to Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bedroom'));
    await tester.pumpAndSettle();
    await capture('room-selection');
    await tester.tap(find.byTooltip('Close location selection'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    await capture('my-space');
    await tester.tap(find.byTooltip('My collection'));
    await tester.pumpAndSettle();
    await capture('collection');
    await tester.tap(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    await capture('care-detail');
    await tester.tap(find.text('Record watering'));
    await tester.pumpAndSettle();
    await capture('record-watering');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Record watering'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record watering'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Watering recorded'), findsOneWidget);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    await capture('my-space-small');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Plant dictionary'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mexican breadfruit'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    await capture('plant-detail-landscape');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await capture('dictionary-landscape');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('My collection'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monstera Deliciosa'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Record watering'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record watering'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My space'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
