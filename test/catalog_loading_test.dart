import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_grovia/pages/home_page.dart';
import 'package:my_grovia/services/database_helper.dart';
import 'package:my_grovia/model/plant.dart';

class UnavailableDatabaseHelper extends DatabaseHelper {
  @override
  Future<List<Plant>> catalog({String query = ''}) async =>
      throw Exception('storage unavailable');
}

void main() {
  testWidgets('Local startup failure offers retry without fake data', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomePage(databaseHelper: UnavailableDatabaseHelper())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    expect(
      find.textContaining('Unable to load data from this device'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
