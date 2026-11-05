import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_grovia/model/plant.dart';
import 'package:my_grovia/services/api_service.dart';

import 'catalog_helper.dart';

void main() {
  test(
    'GET Plantfolio skips metadata, selects four plants and reads care values',
    () async {
      await http.runWithClient(
        () async {
          final List<Plant> plants = await ApiService().getPlants();
          expect(plants.length, 4);
          expect(plants.first.name, 'Monstera Deliciosa');
          expect(plants.first.temperature, '18–29°C');
          expect(plants.first.wateringDays, 7);
          expect(plants[1].name, 'Calathea Orbifolia');
          expect(plants[1].wateringDays, 4);
          expect(plants[1].temperature, '18–24°C');
          expect(plants[1].light, 'Medium indirect');
          expect(plants[2].lowLight, isTrue);
          expect(plants[3].name, 'Golden Pothos');
          expect(createSampleCollection(plants.take(1).toList()).length, 1);
        },
        () => MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), ApiService.catalogUrl);
          expect(request.url.scheme, 'https');
          expect(request.headers['Accept'], 'application/json');
          return catalogResponse();
        }),
      );
    },
  );

  test('Empty catalog is valid', () async {
    await http.runWithClient(() async {
      expect(await ApiService().getPlants(), isEmpty);
    }, () => MockClient((request) async => http.Response('[]', 200)));
  });

  test(
    'Rejects HTTP failures, malformed JSON and invalid plant fields',
    () async {
      for (final response in [
        http.Response('Not found', 404),
        http.Response('Unavailable', 500),
        http.Response('not JSON', 200),
        http.Response('[{"_metadata":{}}]', 200),
        http.Response('{"plants":null}', 200),
        http.Response('{"plants":[7]}', 200),
        http.Response('{"plants":[{"name":42}]}', 200),
      ]) {
        await http.runWithClient(() async {
          await expectLater(ApiService().getPlants(), throwsA(anything));
        }, () => MockClient((request) async => response));
      }
    },
  );

  test('Missing selected plants and invalid care fields fail instead of using defaults', () async {
    final List<dynamic> original = jsonDecode(catalogResponse().body);
    final List<dynamic> missing = List.from(original);
    missing.removeWhere((item) => item['id'] == 'calathea-orbifolia');
    final List<String> invalidBodies = [jsonEncode(missing)];
    for (final badValue in [null, 0, 'seven']) {
      final List<dynamic> changed = jsonDecode(catalogResponse().body);
      for (final item in changed) {
        if (item['id'] == 'swiss-cheese-plant') {
          item['summerInterval'] = badValue;
        }
      }
      invalidBodies.add(jsonEncode(changed));
    }
    for (final String body in invalidBodies) {
      await http.runWithClient(() async {
        await expectLater(ApiService().getPlants(), throwsA(anything));
      }, () => MockClient((request) async => http.Response(body, 200)));
    }
  });
}
