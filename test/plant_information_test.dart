import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/model/plant.dart';

void main() {
  test('Description and source are preserved on the same local ID', () {
    final plant = Plant.fromJson({
      'id': 'one',
      'name': 'A',
      'summary': 'Summary',
      'description': 'Full source text',
      'reference': 'Plantfolio',
      'photo_reference': 'Repository asset',
    });
    expect(plant.id, 'one');
    expect(plant.fullDescription, 'Full source text');
    expect(plant.reference, 'Plantfolio');
    expect(plant.photoReference, 'Repository asset');
  });
}
