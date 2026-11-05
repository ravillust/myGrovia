class Plant {
  final String name;
  final String botanicalName;
  final String? image;
  final String difficulty;
  final String light;
  final int wateringDays;
  final String temperature;
  final String description;
  final String tip;
  final bool lowLight;

  const Plant({
    required this.name,
    required this.botanicalName,
    this.image,
    this.difficulty = 'Easy',
    required this.light,
    required this.wateringDays,
    required this.temperature,
    required this.description,
    required this.tip,
    this.lowLight = false,
  });

  // Deskripsi dan perawatan dari Plantfolio; foto dan label katalog dari aplikasi.
  factory Plant.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    String name;
    String botanicalName;
    String image;
    String difficulty = 'Easy';
    bool lowLight = false;

    if (id == 'swiss-cheese-plant') {
      name = 'Monstera Deliciosa';
      botanicalName = 'Monstera deliciosa';
      image = 'assets/plants/monstera_photo.jpg';
    } else if (id == 'calathea-orbifolia') {
      name = 'Calathea Orbifolia';
      botanicalName = 'Goeppertia orbifolia';
      image = 'assets/plants/calathea_photo.jpg';
      difficulty = 'Moderate';
    } else if (id == 'snake-plants') {
      name = 'Snake Plant';
      botanicalName = 'Dracaena trifasciata';
      image = 'assets/plants/snake_plant_photo.jpg';
      lowLight = true;
    } else if (id == 'golden-pothos') {
      name = 'Golden Pothos';
      botanicalName = 'Epipremnum aureum';
      image = 'assets/plants/golden_pothos.jpg';
      lowLight = true;
    } else {
      throw FormatException('Unsupported plant: $id');
    }

    final String lightPreference = json['lightPreference'] as String;
    String light;
    if (lightPreference == 'brightIndirect') {
      light = 'Bright indirect';
    } else if (lightPreference == 'mediumIndirect') {
      light = 'Medium indirect';
    } else if (lightPreference == 'lowIndirect') {
      light = 'Low indirect';
    } else {
      throw FormatException('Unsupported light preference: $lightPreference');
    }

    // Perkiraan awal dari summerInterval, bukan jadwal pasti untuk semua kondisi.
    final int wateringDays = json['summerInterval'] as int;
    final List<dynamic> temperatures = json['temperaturePreference'] as List;
    if (wateringDays <= 0 ||
        temperatures.length != 2 ||
        temperatures[0] is! num ||
        temperatures[1] is! num ||
        temperatures[0] > temperatures[1]) {
      throw const FormatException('Invalid care information.');
    }

    return Plant(
      name: name,
      botanicalName: botanicalName,
      image: image,
      difficulty: difficulty,
      light: light,
      wateringDays: wateringDays,
      temperature: '${temperatures[0]}–${temperatures[1]}°C',
      description: json['description'] as String,
      tip: json['careTips'] as String,
      lowLight: lowLight,
    );
  }
}

class WateringEntry {
  final DateTime date;
  final String note;
  final int milliliters;
  WateringEntry(this.date, this.note, this.milliliters);
}

class CollectionPlant {
  final Plant plant;
  final String room;
  final DateTime added;
  final List<WateringEntry> history;
  CollectionPlant({
    required this.plant,
    required this.room,
    required this.added,
    required this.history,
  });

  int get daysUntilWatering {
    if (history.isEmpty) {
      return 0;
    }
    final DateTime lastWateringDate = history.first.date;
    final int daysSinceWatering = DateTime.now()
        .difference(lastWateringDate)
        .inDays;
    final int remainingDays = plant.wateringDays - daysSinceWatering;
    return remainingDays;
  }

  String get status {
    if (history.isEmpty || daysUntilWatering <= 0) {
      return 'Due today';
    }
    final int days = DateTime.now().difference(history.first.date).inDays;
    if (days == 0) {
      return 'Watered today';
    }
    if (days == 1) {
      return 'Watered yesterday';
    }
    return 'Watered $days days ago';
  }
}

List<CollectionPlant> createSampleCollection(List<Plant> catalog) {
  // Data awal untuk presentasi UI; belum dibaca dari penyimpanan permanen.
  final DateTime now = DateTime.now();
  final List<CollectionPlant> collection = [];
  final List<String> rooms = ['Living room', 'Bedroom', 'Home office'];
  final List<int> daysSinceWatering = [1, 5, 6];

  for (int index = 0; index < 3 && index < catalog.length; index++) {
    final List<WateringEntry> history = [
      WateringEntry(
        now.subtract(Duration(days: daysSinceWatering[index])),
        'Soil checked before watering',
        320,
      ),
      WateringEntry(
        now.subtract(const Duration(days: 15)),
        'Regular watering',
        300,
      ),
      WateringEntry(
        now.subtract(const Duration(days: 24)),
        'Regular watering',
        300,
      ),
    ];

    final CollectionPlant item = CollectionPlant(
      plant: catalog[index],
      room: rooms[index],
      added: now.subtract(const Duration(days: 90)),
      history: history,
    );
    collection.add(item);
  }
  return collection;
}
