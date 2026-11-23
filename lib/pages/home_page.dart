import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../model/plant.dart';
import '../services/database_helper.dart';
import '../widgets/plant_widgets.dart';
import 'collection_page.dart';
import 'dictionary_page.dart';

class HomePage extends StatefulWidget {
  final DatabaseHelper? databaseHelper;
  const HomePage({super.key, this.databaseHelper});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int selectedTab = 0;
  late final DatabaseHelper databaseHelper =
      widget.databaseHelper ?? DatabaseHelper.instance;
  final Map<String, String> pendingAdds = {};
  bool adding = false;
  List<Plant> catalog = [];
  final List<CollectionPlant> plants = [];
  bool isLoading = true;
  String? loadError;
  final Set<String> bookmarks = {};
  bool savedPlantsOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadPlants();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isLoading) loadPlants();
    if (state == AppLifecycleState.detached) DatabaseHelper.instance.close();
  }

  Future<void> loadPlants() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final List<Plant> result = await databaseHelper.catalog();
      final collection = await databaseHelper.collection();
      final saved = await databaseHelper.bookmarks();
      if (!mounted) {
        return;
      }
      setState(() {
        catalog = result;
        bookmarks
          ..clear()
          ..addAll(saved);
        // Koleksi dimuat dari SQLite, tidak diisi data contoh.
        plants
          ..clear()
          ..addAll(collection);
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        loadError = 'Unable to load data from this device. Try again or restart the app.';
      });
    }
  }

  void changeTab(int tabNumber) {
    setState(() {
      selectedTab = tabNumber;
    });
  }

  void openDictionary() {
    setState(() {
      savedPlantsOnly = false;
      selectedTab = 0;
    });
  }

  void changeSavedFilter(bool showSavedPlants) {
    setState(() {
      savedPlantsOnly = showSavedPlants;
    });
  }

  Future<void> changeBookmark(Plant plant) async {
    final id = plant.id!;
    final saved = !bookmarks.contains(id);
    await databaseHelper.saveBookmark(id, saved: saved);
    if (!mounted) return;
    setState(() {
      if (saved) {
        bookmarks.add(id);
      } else {
        bookmarks.remove(id);
      }
    });
  }

  void refreshCollection() {
    // Baca kembali hasil penyimpanan, termasuk saat kembali dari galeri.
    loadPlants();
  }

  Future<void> addPlant(Plant plant, String room) async {
    if (adding) return;
    adding = true;
    try {
      final key = '${plant.id ?? plant.name}:$room';
      final id = pendingAdds.putIfAbsent(key, () => const Uuid().v4());
      await databaseHelper.savePlant(id, plant, room, create: true);
      pendingAdds.remove(key);
      await loadPlants();
      if (mounted) changeTab(1);
    } finally {
      adding = false;
    }
  }

  Widget buildSelectedPage() {
    // Hanya tab aktif yang dibuat. Pencarian kembali kosong saat pindah tab.
    // Koleksi dan bookmark dimuat dari SQLite.
    if (selectedTab == 0) {
      return DictionaryPage(
        catalog: catalog,
        collection: plants,
        bookmarks: bookmarks,
        savedOnly: savedPlantsOnly,
        onSavedOnlyChanged: changeSavedFilter,
        onAdd: addPlant,
        onBookmark: changeBookmark,
      );
    }
    return CollectionPage(
      plants: plants,
      onBrowse: openDictionary,
      onChanged: refreshCollection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: buildBody()),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xffeef1ee))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                navigationButton(
                  0,
                  Icons.menu_book_outlined,
                  'Plant dictionary',
                ),
                navigationButton(
                  1,
                  Icons.local_florist_outlined,
                  'My collection',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: Text('Loading plants…'));
    }
    final String? message = loadError;
    if (message != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(onPressed: loadPlants, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(onRefresh: loadPlants, child: buildSelectedPage());
  }

  Widget navigationButton(int index, IconData icon, String label) {
    Color iconColor = mutedText;
    if (selectedTab == index) {
      iconColor = plantGreen;
    }
    return Expanded(
      child: Center(
        child: Semantics(
          selected: selectedTab == index,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: label,
              iconSize: 30,
              constraints: const BoxConstraints.tightFor(width: 52, height: 52),
              color: iconColor,
              onPressed: () {
                changeTab(index);
              },
              icon: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }
}
