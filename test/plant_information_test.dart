import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_grovia/main.dart';
import 'package:my_grovia/services/api_service.dart';
import 'package:my_grovia/widgets/plant_information_dialog.dart';

import 'catalog_helper.dart';

http.Response summaryResponse() {
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({
        'type': 'standard',
        'extract': 'Plant description — green leaves.',
      }),
    ),
    200,
  );
}

void main() {
  testWidgets(
    'Wikipedia is requested only after Read more; source opens separately',
    (tester) async {
      int wikiRequests = 0;
      final reply = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await tester.pumpWidget(const MyGroviaApp());
          await tester.pumpAndSettle();
          await tester.tap(find.text('Monstera Deliciosa'));
          await tester.pumpAndSettle();
          expect(wikiRequests, 0);
          await tester.ensureVisible(find.text('Read more'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Read more'));
          await tester.pumpAndSettle();
          expect(find.text('Loading plant information…'), findsOneWidget);
          reply.complete(summaryResponse());
          await tester.pumpAndSettle();
          expect(
            find.text('Plant description — green leaves.'),
            findsOneWidget,
          );
          await tester.tap(find.text('Source: Wikipedia'));
          await tester.pumpAndSettle();
          expect(find.textContaining('CC BY-SA 4.0'), findsOneWidget);
          expect(wikiRequests, 1);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((request) async {
          if (request.url.host == 'raw.githubusercontent.com') {
            return catalogResponse();
          }
          wikiRequests++;
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://en.wikipedia.org/api/rest_v1/page/summary/Monstera_deliciosa',
          );
          expect(request.headers['Api-User-Agent'], contains('myGrovia'));
          return reply.future;
        }),
      );
    },
  );

  testWidgets(
    'Small dialog retries failure and ignores late response after close',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      int calls = 0;
      final reply = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: TextButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) {
                            return const PlantInformationDialog(
                              botanicalName: 'Monstera deliciosa',
                            );
                          },
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Try again'));
          await tester.pumpAndSettle();
          expect(
            find.text('Plant description — green leaves.'),
            findsOneWidget,
          );
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 13));
          await tester.pumpAndSettle();
          expect(find.text('Try again'), findsOneWidget);
          await tester.tap(find.text('Try again'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();
          reply.complete(summaryResponse());
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
        () => MockClient((request) async {
          calls++;
          if (calls == 1) throw http.ClientException('Offline');
          if (calls == 2) return summaryResponse();
          return reply.future;
        }),
      );
    },
  );

  test(
    'Wikipedia rejects HTTP failures, malformed data and disambiguation',
    () async {
      for (final response in [
        http.Response('Unavailable', 503),
        http.Response('invalid json', 200),
        http.Response('[]', 200),
        http.Response('{"type":"disambiguation","extract":"Choose"}', 200),
        http.Response('{"type":"standard","extract":" "}', 200),
        http.Response('{"type":"standard","extract":42}', 200),
      ]) {
        await http.runWithClient(() async {
          await expectLater(
            ApiService().getPlantDescription('Monstera deliciosa'),
            throwsA(isA<Exception>()),
          );
        }, () => MockClient((request) async => response));
      }
    },
  );
}
