import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response catalogResponse() {
  return http.Response.bytes(
    File('test/fixtures/plants.json').readAsBytesSync(),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Future<void> pumpCatalogApp(WidgetTester tester, Widget app) async {
  await http.runWithClient(() async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }, () => MockClient((request) async => catalogResponse()));
}
