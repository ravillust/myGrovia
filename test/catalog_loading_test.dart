import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_grovia/main.dart';

import 'catalog_helper.dart';

void main() {
  testWidgets('Loads catalog once and uses it for detail and tabs', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    int requests = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(const MyGroviaApp());
        expect(find.text('Loading plants…'), findsOneWidget);
        response.complete(catalogResponse());
        await tester.pumpAndSettle();
        expect(requests, 1);
        await tester.tap(find.text('Monstera Deliciosa'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Mexican breadfruit'), findsOneWidget);
        expect(find.text('Read more'), findsNothing);
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('My collection'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Plant dictionary'));
        await tester.pumpAndSettle();
        expect(requests, 1);
        await tester.tap(find.byTooltip('My space'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Plant data source'));
        await tester.tap(find.text('Plant data source'));
        await tester.pumpAndSettle();
        expect(find.textContaining('CC BY-NC-SA 4.0'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
      () => MockClient((request) {
        requests++;
        return response.future;
      }),
    );
  });

  testWidgets('Failure has no fake catalog and retry loads real response', (
    tester,
  ) async {
    int requests = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(const MyGroviaApp());
        await tester.pumpAndSettle();
        expect(find.text('Monstera Deliciosa'), findsNothing);
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(find.text('Monstera Deliciosa'), findsOneWidget);
        expect(requests, 2);
        expect(tester.takeException(), isNull);
      },
      () => MockClient((request) async {
        requests++;
        if (requests == 1) {
          throw http.ClientException('Offline');
        }
        return catalogResponse();
      }),
    );
  });

  testWidgets('Empty catalog stays empty and can open collection', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(const MyGroviaApp());
      await tester.pumpAndSettle();
      expect(find.text('No plants found'), findsOneWidget);
      await tester.tap(find.byTooltip('My collection'));
      await tester.pumpAndSettle();
      expect(find.text('No plants in your collection'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, () => MockClient((request) async => http.Response('[]', 200)));
  });

  testWidgets(
    'Timeout can retry and a late response after disposal is ignored',
    (tester) async {
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        await tester.pumpWidget(const MyGroviaApp());
        await tester.pump(const Duration(seconds: 13));
        await tester.pumpAndSettle();
        expect(find.text('Try again'), findsOneWidget);
        await tester.tap(find.text('Try again'));
        await tester.pump();
        await tester.pumpWidget(const SizedBox());
        response.complete(catalogResponse());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }, () => MockClient((request) => response.future));
    },
  );
}
