import 'dart:io';

import 'package:my_grovia/services/api_service.dart';
import 'package:my_grovia/model/plant.dart';

// Pemeriksaan manual ke dataset online; cukup menjalankan dart run pada file ini.
Future<void> main() async {
  final ApiService service = ApiService();
  final List<Plant> plants = await service.getPlants();
  stdout.writeln('${plants.length} plants received from Plantfolio');
  for (final Plant plant in plants) {
    stdout.writeln(
      '${plant.name}: ${plant.temperature}, every ${plant.wateringDays} days',
    );
  }
}
