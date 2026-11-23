import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../model/plant.dart';
import 'database_setup.dart';

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => message;
}

class DatabaseHelper {
  static DatabaseHelper instance = DatabaseHelper();
  static const maxPhotoBytes = 5 * 1024 * 1024;

  // Parameter opsional memungkinkan tes memakai database sementara.
  final DatabaseFactory? factory;
  final String? directory;
  final List<dynamic>? initialCatalog;
  Future<Database>? _opening;
  late Directory _photos;

  DatabaseHelper({this.factory, this.directory, this.initialCatalog});

  Future<Database> get database async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async {
    final folder = directory ?? (await getApplicationDocumentsDirectory()).path;
    final catalog =
        initialCatalog ??
        jsonDecode(await rootBundle.loadString('assets/data/catalog.json'))
            as List;
    await Directory(folder).create(recursive: true);
    _photos = await Directory(path.join(folder, 'photos'))
        .create(recursive: true);
    return openLocalDatabase(
      factory: factory ?? databaseFactory,
      directory: folder,
      catalog: catalog,
    );
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening == null) return;
    try {
      await (await opening).close();
    } finally {
      _opening = null;
    }
  }

  Future<List<Plant>> catalog({String query = ''}) async {
    final db = await database;
    final rows = await db.query('catalog', where: 'active = 1', orderBy: 'id');
    final plants = rows
        .map((row) => Plant.fromJson(jsonDecode(row['data'] as String)))
        .where(
          (plant) => '${plant.name} ${plant.botanicalName}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
    const featured = [
      'swiss-cheese-plant',
      'calathea-orbifolia',
      'snake-plants',
      'golden-pothos',
    ];
    plants.sort((first, second) {
      final firstIndex = featured.indexOf(first.id ?? '');
      final secondIndex = featured.indexOf(second.id ?? '');
      if (firstIndex >= 0 || secondIndex >= 0) {
        return (firstIndex < 0 ? featured.length : firstIndex).compareTo(
          secondIndex < 0 ? featured.length : secondIndex,
        );
      }
      return first.name.compareTo(second.name);
    });
    return plants;
  }

  Future<Plant> detail(String id, {bool includeArchived = false}) async {
    final db = await database;
    final rows = await db.query(
      'catalog',
      where: includeArchived ? 'id = ?' : 'id = ? AND active = 1',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      throw const StorageException('Dictionary entry not found.');
    }
    return Plant.fromJson(jsonDecode(rows.single['data'] as String));
  }

  Future<Set<String>> bookmarks() async {
    final db = await database;
    final rows = await db.query('bookmarks');
    return rows.map((row) => row['catalog_id'] as String).toSet();
  }

  Future<void> saveBookmark(String catalogId, {required bool saved}) async {
    final db = await database;
    if (saved) {
      await detail(catalogId);
      await db.insert('bookmarks', {
        'catalog_id': catalogId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db.delete(
        'bookmarks',
        where: 'catalog_id = ?',
        whereArgs: [catalogId],
      );
    }
  }

  Future<List<CollectionPlant>> collection() async {
    final db = await database;
    final rows = await db.query('collection', orderBy: 'added DESC');
    final plants = <CollectionPlant>[];
    for (final row in rows) {
      String photoReference = '';
      if (row['catalog_id'] != null) {
        final source = await detail(
          row['catalog_id'] as String,
          includeArchived: true,
        );
        if (row['image'] == source.image) {
          photoReference = source.photoReference;
        }
      }
      final history = await db.query(
        'watering',
        where: 'plant_id = ?',
        whereArgs: [row['id']],
        orderBy: 'watered_at DESC, id DESC',
      );
      plants.add(
        CollectionPlant.fromJson({
          ...row,
          'photo_reference': photoReference,
          'watering': history,
        }),
      );
    }
    return plants;
  }

  Future<void> savePlant(
    String id,
    Plant plant,
    String room, {
    bool create = false,
  }) async {
    _validateId(id);
    final db = await database;
    final existing = await db.query(
      'collection',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Retry penambahan memakai ID yang sama agar koleksi tidak terduplikasi.
    if (create && existing.isNotEmpty) return;
    if (!create && existing.isEmpty) {
      throw const StorageException('Plant not found.');
    }
    if (plant.wateringDays < 1 || plant.wateringDays > 365) {
      throw const StorageException(
        'Watering interval must be between 1 and 365 days.',
      );
    }
    if (plant.id != null) {
      await detail(
        plant.id!,
        includeArchived:
            existing.isNotEmpty && existing.single['catalog_id'] == plant.id,
      );
    }
    await _validateImage(plant.image);
    final values = {
      'catalog_id': plant.id,
      'name': _validateText(plant.name, 'plant name'),
      'botanical_name': _validateText(
        plant.botanicalName,
        'botanical name',
        allowEmpty: true,
      ),
      'room': _validateText(room, 'room'),
      'watering_days': plant.wateringDays,
      'image': plant.image,
    };
    if (create) {
      await db.insert('collection', {
        ...values,
        'id': id,
        'added': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db.update('collection', values, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deletePlant(String id) async {
    final db = await database;
    // Foreign key ON DELETE CASCADE ikut menghapus riwayat tanaman ini.
    await db.delete(
      'collection',
      where: 'id = ?',
      whereArgs: [_validateId(id)],
    );
  }

  Future<WateringEntry> water(
    String plantId,
    String actionId,
    WateringEntry entry,
  ) async {
    _validateId(plantId);
    _validateId(actionId);
    final note = _validateText(entry.note, 'note', allowEmpty: true);
    if (entry.milliliters <= 0 || entry.milliliters > 1000000) {
      throw const StorageException('Invalid water amount.');
    }
    final db = await database;
    return db.transaction((transaction) async {
      final plant = await transaction.query(
        'collection',
        where: 'id = ?',
        whereArgs: [plantId],
      );
      if (plant.isEmpty) throw const StorageException('Plant not found.');
      // Pemeriksaan dan insert dalam satu transaksi mencegah catatan ganda saat retry.
      final previous = await transaction.query(
        'watering',
        where: 'id = ?',
        whereArgs: [actionId],
      );
      if (previous.isNotEmpty) {
        final record = previous.single;
        if (record['plant_id'] != plantId ||
            record['note'] != note ||
            record['milliliters'] != entry.milliliters) {
          throw const StorageException(
            'This action ID is already used for a different record.',
          );
        }
        return WateringEntry.fromJson(record);
      }
      final record = {
        'id': actionId,
        'plant_id': plantId,
        'note': note,
        'milliliters': entry.milliliters,
        'watered_at': DateTime.now().toUtc().toIso8601String(),
      };
      await transaction.insert('watering', record);
      return WateringEntry.fromJson(record);
    });
  }

  Future<Uint8List> photo(String id) async {
    await database;
    final file = File(path.join(_photos.path, _validateId(id)));
    if (!await file.exists()) throw const StorageException('Photo not found.');
    return file.readAsBytes();
  }

  Future<String> savePhoto(String id, Uint8List bytes) async {
    await database;
    _validateId(id);
    final isPng = bytes.length > 8 && bytes[0] == 137 && bytes[1] == 80;
    final isJpeg = bytes.length > 3 && bytes[0] == 255 && bytes[1] == 216;
    if (bytes.length > maxPhotoBytes || (!isPng && !isJpeg)) {
      throw const StorageException('Choose a JPEG or PNG photo up to 5 MB.');
    }
    final file = File(path.join(_photos.path, id));
    final temporary = File('${file.path}.${const Uuid().v4()}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await file.exists()) {
      await temporary.delete();
    } else {
      await temporary.rename(file.path);
    }
    return 'local:$id';
  }

  Future<void> _validateImage(String? image) async {
    if (image == null) return;
    if (image.startsWith('local:')) {
      final id = _validateId(image.substring(6));
      if (!await File(path.join(_photos.path, id)).exists()) {
        throw const StorageException('Photo has not been saved.');
      }
    } else if (!RegExp(
      r'^assets/plants/(?:catalog/)?[a-zA-Z0-9_-]+\.(jpg|png)$',
    ).hasMatch(image)) {
      throw const StorageException('Photo must be stored on this device.');
    }
  }

  String _validateText(String value, String field, {bool allowEmpty = false}) {
    if ((!allowEmpty && value.trim().isEmpty) || value.length > 100) {
      throw StorageException('Invalid $field.');
    }
    return value.trim();
  }

  String _validateId(String value) {
    if (!RegExp(r'^[a-zA-Z0-9_-]{1,100}$').hasMatch(value)) {
      throw const StorageException('Invalid ID.');
    }
    return value;
  }
}
