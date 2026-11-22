import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/plant.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class PlantDescription {
  final String text;
  final bool fromInternet;
  const PlantDescription(this.text, {required this.fromInternet});
}

class ApiService {
  static final catalogUrl = Uri.https(
    'api.github.com',
    '/repos/Luminoid/plantfolio-common-plants/contents/dist/common_plants.json',
    {'ref': 'bbb364534cfbca28168085897ac9f2ff00a151a5'},
  );
  static const headers = {
    'Accept': 'application/vnd.github.raw+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'myGrovia',
  };

  final http.Client? client;
  final Duration timeout;
  ApiService({this.client, this.timeout = const Duration(seconds: 12)});

  Future<PlantDescription> description(Plant plant) async {
    if (plant.id == null) {
      return PlantDescription(plant.fullDescription, fromInternet: false);
    }
    try {
      return PlantDescription(
        await fetchDescription(plant.id!),
        fromInternet: true,
      );
    } on ApiException {
      return PlantDescription(plant.fullDescription, fromInternet: false);
    } on http.ClientException {
      return PlantDescription(plant.fullDescription, fromInternet: false);
    } on TimeoutException {
      return PlantDescription(plant.fullDescription, fromInternet: false);
    } on FormatException {
      return PlantDescription(plant.fullDescription, fromInternet: false);
    }
  }

  Future<String> fetchDescription(String plantId) async {
    final httpClient = client ?? http.Client();
    try {
      // Request internet terjadi saat Read more dibuka; tanpa token atau data pribadi.
      final response = await httpClient
          .get(catalogUrl, headers: headers)
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw ApiException(
          'Unable to load the online description.',
          statusCode: response.statusCode,
        );
      }
      final rows = jsonDecode(utf8.decode(response.bodyBytes));
      if (rows is! List) throw const FormatException('Expected a plant list.');
      for (final row in rows) {
        if (row is! Map || row['id'] != plantId) continue;
        final description = row['description'];
        if (description is! String || description.trim().isEmpty) {
          throw const FormatException('Description not available.');
        }
        final sections = [description];
        const labels = {
          'commonExamples': 'Examples',
          'origin': 'Origin',
          'careTips': 'Care guidance',
        };
        for (final field in labels.keys) {
          final value = row[field];
          if (value == null || value == '') continue;
          if (value is! String) {
            throw const FormatException('Invalid description field.');
          }
          sections.add('${labels[field]}: $value');
        }
        return sections.join('\n\n');
      }
      throw const ApiException('Plant not found in the online catalog.');
    } finally {
      if (client == null) httpClient.close();
    }
  }
}
