import 'dart:io';

import 'package:my_grovia/services/api_service.dart';

Future<void> main() async {
  final ApiService service = ApiService();
  for (final String name in [
    'Monstera deliciosa',
    'Goeppertia orbifolia',
    'Dracaena trifasciata',
    'Epipremnum aureum',
  ]) {
    final String description = await service.getPlantDescription(name);
    stdout.writeln('$name: ${description.length} characters from Wikipedia');
  }
}
