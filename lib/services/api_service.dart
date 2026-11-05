import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/plant.dart';

class ApiService {
  // Versi dataset dikunci agar hasil demo tidak berubah saat sumber diperbarui.
  static const String catalogUrl =
      'https://raw.githubusercontent.com/Luminoid/plantfolio-common-plants/'
      'bbb364534cfbca28168085897ac9f2ff00a151a5/dist/common_plants.json';

  Future<List<Plant>> getPlants() async {
    final Uri url = Uri.parse(catalogUrl);
    final http.Client client = http.Client();
    try {
      final http.Response response = await client
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Could not load plants: ${response.statusCode}');
      }

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! List) {
        throw const FormatException('The response must be a plant list.');
      }
      final List<Plant> plants = [];
      if (data.isEmpty) {
        return plants;
      }

      // Ambil empat tanaman yang fotonya tersedia, dalam urutan katalog aplikasi.
      const List<String> selectedIds = [
        'swiss-cheese-plant',
        'calathea-orbifolia',
        'snake-plants',
        'golden-pothos',
      ];
      for (final String id in selectedIds) {
        bool found = false;
        for (final dynamic item in data) {
          // Baris metadata dan tanaman lain tidak perlu ditampilkan.
          if (item is Map<String, dynamic> && item['id'] == id) {
            plants.add(Plant.fromJson(item));
            found = true;
            break;
          }
        }
        if (!found) {
          throw FormatException('Plant not found in dataset: $id');
        }
      }
      return plants;
    } finally {
      client.close();
    }
  }
}
