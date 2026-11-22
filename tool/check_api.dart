import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:my_grovia/services/api_service.dart';

// Memanggil ApiService yang sama dengan Read more, dengan pencatatan respons untuk demo.
class RecordingClient extends http.BaseClient {
  final http.Client inner = http.Client();
  Map<String, Object?>? evidence;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await http.Response.fromStream(await inner.send(request));
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    evidence = {
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'execution': 'Dart CLI calling the app ApiService over live HTTPS; not an APK traffic capture',
      'method': request.method,
      'url': request.url.toString(),
      'request_headers': request.headers,
      'status': response.statusCode,
      'response_bytes': response.bodyBytes.length,
      'response_content_type': response.headers['content-type'],
      'response_example': body is List
          ? body.firstWhere(
              (row) => row is Map && row['id'] == 'swiss-cheese-plant',
            )
          : body,
    };
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }

  @override
  void close() => inner.close();
}

Future<void> main() async {
  final client = RecordingClient();
  try {
    final text = await ApiService(client: client)
        .fetchDescription('swiss-cheese-plant');
    final catalog = jsonDecode(
      await File('assets/data/catalog.json').readAsString(),
    ) as List;
    final saved = catalog.firstWhere(
      (row) => row['id'] == 'swiss-cheese-plant',
    );
    if (text != saved['description']) {
      throw StateError('Online and bundled descriptions differ.');
    }
    final evidence = {...client.evidence!, 'matches_bundled_description': true};
    final json = const JsonEncoder.withIndent('  ').convert(evidence);
    await Directory('build').create(recursive: true);
    await File('build/internet-api-evidence.json').writeAsString(json);
    await Directory('docs').create(recursive: true);
    await File('docs/API_EVIDENCE.md').writeAsString('''# Bukti request internet

Dihasilkan oleh `dart run tool/check_api.dart`. Request memakai ApiService aplikasi
dan internet sungguhan dari komputer. Ini bukan rekaman lalu lintas APK di HP.
Deskripsi hasil HTTP 200 dibandingkan dengan entri ber-ID sama di katalog APK.
Tes kegagalan/timeout dalam `test/api_service_test.dart` memakai respons simulasi.

```json
$json
```
''');
    stdout.writeln(json);
  } catch (error) {
    stderr.writeln('Live API check failed: $error');
    exitCode = 1;
  } finally {
    client.close();
  }
}
