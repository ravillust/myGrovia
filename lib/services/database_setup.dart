import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

Future<Database> openLocalDatabase({
  required DatabaseFactory factory,
  required String directory,
  required List<dynamic> catalog,
}) async {
  final database = await factory.openDatabase(
    path.join(directory, 'mygrovia.sqlite'),
    options: OpenDatabaseOptions(
      version: 3,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    ),
  );
  try {
    await _updateCatalog(database, catalog);
    return database;
  } catch (_) {
    await database.close();
    rethrow;
  }
}

Future<void> _createTables(Database db, int version) async {
  await db.execute(
    'CREATE TABLE catalog (id TEXT PRIMARY KEY, data TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1)',
  );
  await db.execute('''CREATE TABLE collection (
    id TEXT PRIMARY KEY, catalog_id TEXT REFERENCES catalog(id),
    name TEXT NOT NULL, botanical_name TEXT NOT NULL DEFAULT '', image TEXT,
    room TEXT NOT NULL,
    watering_days INTEGER NOT NULL CHECK(watering_days BETWEEN 1 AND 365),
    added TEXT NOT NULL)''');
  await db.execute('''CREATE TABLE watering (
    id TEXT PRIMARY KEY,
    plant_id TEXT NOT NULL REFERENCES collection(id) ON DELETE CASCADE,
    watered_at TEXT NOT NULL, note TEXT NOT NULL,
    milliliters INTEGER NOT NULL CHECK(milliliters > 0))''');
  await db.execute(
    'CREATE INDEX watering_by_plant ON watering(plant_id, watered_at DESC)',
  );
}

Future<void> _upgradeDatabase(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // Migrasi menambah indeks tanpa menghapus koleksi atau riwayat lama.
  if (oldVersion < 2) {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS watering_by_plant ON watering(plant_id, watered_at DESC)',
    );
  }
  if (oldVersion < 3) {
    await db.execute(
      'ALTER TABLE catalog ADD COLUMN active INTEGER NOT NULL DEFAULT 1',
    );
  }
}

Future<void> _updateCatalog(Database database, List<dynamic> catalog) async {
  await database.transaction((transaction) async {
    final batch = transaction.batch();
    // Entri lama disembunyikan dari Dictionary, tetapi referensi koleksi tetap ada.
    batch.update('catalog', {'active': 0});
    for (final plant in catalog) {
      final values = {
        'id': plant['id'],
        'data': jsonEncode(plant),
        'active': 1,
      };
      batch.insert(
        'catalog',
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      batch.update(
        'catalog',
        {'data': values['data'], 'active': 1},
        where: 'id = ?',
        whereArgs: [plant['id']],
      );
      // Foto bawaan mengikuti katalog terbaru; foto galeri pengguna dipertahankan.
      batch.update(
        'collection',
        {'image': plant['image']},
        where: "catalog_id = ? AND (image IS NULL OR image LIKE 'assets/plants/%')",
        whereArgs: [plant['id']],
      );
    }
    await batch.commit(noResult: true);
  });
}
