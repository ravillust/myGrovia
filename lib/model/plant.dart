class Plant {
  final String? id;
  final String fullDescription;
  final String reference;
  final String photoReference;
  final String name;
  final String botanicalName;
  final String? image;
  final String light;
  final int wateringDays;
  final bool wateringKnown;
  final String temperature;
  final String description;
  final String tip;

  const Plant({
    this.id,
    this.fullDescription = '',
    this.reference = '',
    this.photoReference = '',
    required this.name,
    required this.botanicalName,
    this.image,
    required this.light,
    required this.wateringDays,
    this.wateringKnown = true,
    required this.temperature,
    required this.description,
    required this.tip,
  });

  Plant withWateringDays(int days) => Plant(
    id: id,
    name: name,
    botanicalName: botanicalName,
    image: image,
    light: light,
    wateringDays: days,
    temperature: temperature,
    description: description,
    tip: tip,
    fullDescription: fullDescription,
    reference: reference,
    photoReference: photoReference,
  );

  factory Plant.fromJson(Map<String, dynamic> row) => Plant(
    id: row['catalog_id'] ?? (row.containsKey('room') ? null : row['id']),
    name: row['name'],
    botanicalName: row['botanical_name'] ?? '',
    image: row['image'],
    wateringDays: row['watering_days'] ?? 7,
    wateringKnown: row['watering_days'] is int,
    light: lightLabel(row['light'] as String?),
    temperature: row['temperature'] ?? 'Not available',
    description: row['summary'] ?? '',
    fullDescription: row['description'] ?? '',
    reference: row['reference'] ?? '',
    photoReference: row['photo_reference'] ?? '',
    tip: row['tip'] ?? '',
  );

  static String lightLabel(String? value) {
    const labels = {
      'outdoorFullSun': 'Full sun (outdoors)',
      'outdoorPartialSun': 'Partial sun (outdoors)',
      'outdoorShade': 'Shade (outdoors)',
      'strongDirect': 'Strong direct light',
    };
    return labels[value] ?? value ?? 'Not available';
  }
}

class WateringEntry {
  final DateTime date;
  final String note;
  final int milliliters;
  WateringEntry(this.date, this.note, this.milliliters);

  factory WateringEntry.fromJson(Map<String, dynamic> row) => WateringEntry(
    DateTime.parse(row['watered_at']).toLocal(),
    row['note'],
    row['milliliters'],
  );
}

class CollectionPlant {
  final String? id;
  Plant plant;
  String room;
  final DateTime added;
  final List<WateringEntry> history;
  CollectionPlant({
    this.id,
    required this.plant,
    required this.room,
    required this.added,
    required this.history,
  });

  factory CollectionPlant.fromJson(Map<String, dynamic> row) => CollectionPlant(
    id: row['id'],
    plant: Plant.fromJson(row),
    room: row['room'],
    added: DateTime.parse(row['added']).toLocal(),
    history: [
      for (final entry in row['watering'] as List)
        WateringEntry.fromJson(entry),
    ],
  );

  int get daysUntilWatering {
    if (history.isEmpty) {
      return 0;
    }
    final now = DateTime.now();
    final due = nextWatering!;
    return DateTime.utc(
      due.year,
      due.month,
      due.day,
    ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }

  DateTime? get nextWatering {
    if (history.isEmpty) return null;
    final last = history.first.date.toLocal();
    return DateTime(last.year, last.month, last.day + plant.wateringDays);
  }

  String get status {
    if (history.isEmpty) return 'Not watered yet';
    if (daysUntilWatering < 0) {
      return 'Overdue by ${-daysUntilWatering} ${daysUntilWatering == -1 ? 'day' : 'days'}';
    }
    if (daysUntilWatering == 0) return 'Due today';
    final now = DateTime.now();
    final last = history.first.date.toLocal();
    final int days = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime.utc(last.year, last.month, last.day)).inDays;
    if (days == 0) {
      return 'Watered today';
    }
    if (days == 1) {
      return 'Watered yesterday';
    }
    return 'Watered $days days ago';
  }
}
