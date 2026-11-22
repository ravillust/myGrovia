import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/services/api_service.dart';
import 'package:my_grovia/widgets/plant_information_dialog.dart';

void main() {
  final bundled =
      jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List;
  final plant = Plant.fromJson(
    bundled.firstWhere((row) => row['id'] == 'swiss-cheese-plant'),
  );
  final source = File('third_party/plantfolio/source.json').readAsStringSync();

  test(
    'GitHub request selects the same ID and text as the bundled catalog',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url, ApiService.catalogUrl);
        expect(request.url.scheme, 'https');
        expect(request.headers['Accept'], 'application/vnd.github.raw+json');
        expect(request.headers.containsKey('Authorization'), isFalse);
        expect(request.body, isEmpty);
        return http.Response(
          source,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final result = await ApiService(client: client).description(plant);
      expect(result.fromInternet, isTrue);
      expect(result.text, plant.fullDescription);
    },
  );

  for (final status in [403, 404, 429, 500]) {
    test('HTTP $status keeps the saved description', () async {
      final client = MockClient(
        (_) async => http.Response('{"message":"Unavailable"}', status),
      );
      final api = ApiService(client: client);
      await expectLater(
        api.fetchDescription(plant.id!),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'status', status),
        ),
      );
      final result = await api.description(plant);
      expect(result.fromInternet, isFalse);
      expect(result.text, plant.fullDescription);
    });
  }

  test(
    'Malformed, missing and mismatched data never show another plant',
    () async {
      for (final body in [
        '<html>Error</html>',
        '{}',
        '[]',
        jsonEncode([
          {'id': 'other-plant', 'description': 'Wrong plant'},
        ]),
        jsonEncode([
          {'id': plant.id, 'description': 123},
        ]),
        jsonEncode([
          {'id': plant.id, 'description': 'Text', 'careTips': []},
        ]),
      ]) {
        final api = ApiService(
          client: MockClient((_) async => http.Response(body, 200)),
        );
        final result = await api.description(plant);
        expect(result.fromInternet, isFalse);
        expect(result.text, plant.fullDescription);
      }
    },
  );

  test(
    'Connection failure and timeout fall back without changing the plant',
    () async {
      final offline = ApiService(
        client: MockClient((_) async => throw http.ClientException('Offline')),
      );
      expect((await offline.description(plant)).fromInternet, isFalse);
      final pending = Completer<http.Response>();
      final slow = ApiService(
        client: MockClient((_) => pending.future),
        timeout: const Duration(milliseconds: 20),
      );
      expect((await slow.description(plant)).text, plant.fullDescription);
      pending.complete(http.Response.bytes(utf8.encode(source), 200));
    },
  );

  testWidgets(
    'Read more sends a request, shows saved text on failure, retries online',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var requests = 0;
      final pending = Completer<http.Response>();
      final api = ApiService(
        client: MockClient((_) {
          requests++;
          return requests == 1
              ? pending.future
              : Future.value(http.Response.bytes(utf8.encode(source), 200));
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlantInformationDialog(plant: plant, apiService: api),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Loading description...'), findsOneWidget);
      pending.complete(http.Response('', 503));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Showing the saved description'),
        findsOneWidget,
      );
      expect(find.text(plant.description), findsOneWidget);
      expect(find.text('Examples'), findsOneWidget);
      expect(find.text('Origin'), findsOneWidget);
      expect(find.text('Care guidance'), findsOneWidget);
      expect(find.text(plant.tip), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(requests, 2);
      expect(find.text('Description source'), findsNothing);
      await tester.ensureVisible(find.text('Sources & credits'));
      await tester.tap(find.text('Sources & credits'));
      await tester.pumpAndSettle();
      expect(
        find.text('Description loaded from Plantfolio on GitHub.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsNothing);
      expect(find.text(plant.description), findsOneWidget);
      expect(find.text('Description source'), findsOneWidget);
      expect(find.text('Photo source'), findsOneWidget);
      expect(find.text(plant.reference), findsOneWidget);
      expect(find.text(plant.photoReference), findsOneWidget);
      await tester.ensureVisible(find.text('Sources & credits'));
      await tester.tap(find.text('Sources & credits'));
      await tester.pumpAndSettle();
      expect(find.text('Photo source'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
