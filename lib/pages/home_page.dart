import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../services/api_service.dart';
import '../widgets/plant_widgets.dart';
import 'collection_page.dart';
import 'dictionary_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  final ApiService apiService = ApiService();
  List<Plant> catalog = [];
  final List<CollectionPlant> plants = [];
  bool isLoading = true;
  String? loadError;
  final Set<String> bookmarks = {};
  bool savedPlantsOnly = false;

  @override
  void initState() {
    super.initState();
    loadPlants();
  }

  Future<void> loadPlants() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final List<Plant> result = await apiService.getPlants();
      if (!mounted) {
        return;
      }
      setState(() {
        catalog = result;
        // Koleksi presentasi dibuat dari tanaman yang berhasil diambil dari internet.
        plants.addAll(createSampleCollection(catalog));
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        loadError =
            'Could not load plants. Check your connection and try again.';
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

  void openCollection() {
    changeTab(1);
  }

  void openSavedPlants() {
    setState(() {
      savedPlantsOnly = true;
      selectedTab = 0;
    });
  }

  void changeSavedFilter(bool showSavedPlants) {
    setState(() {
      savedPlantsOnly = showSavedPlants;
    });
  }

  void changeBookmark(Plant plant) {
    setState(() {
      if (bookmarks.contains(plant.name)) {
        bookmarks.remove(plant.name);
      } else {
        bookmarks.add(plant.name);
      }
    });
  }

  void refreshCollection() {
    // Data sudah diubah di halaman detail; tampilkan hasil terbarunya.
    setState(() {});
  }

  void addPlant(Plant plant, String room) {
    final CollectionPlant newPlant = CollectionPlant(
      plant: plant,
      room: room,
      added: DateTime.now(),
      history: [],
    );
    setState(() {
      plants.add(newPlant);
      selectedTab = 1;
    });
  }

  Widget buildSelectedPage() {
    // Hanya tab aktif yang dibuat. Pencarian kembali kosong saat pindah tab.
    // Koleksi dan bookmark tetap ada karena disimpan di HomePage.
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
    if (selectedTab == 1) {
      return CollectionPage(
        plants: plants,
        onBrowse: openDictionary,
        onChanged: refreshCollection,
      );
    }
    return ProfilePage(
      plants: plants,
      savedCount: bookmarks.length,
      onOpenCollection: openCollection,
      onOpenSavedPlants: openSavedPlants,
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
                navigationButton(2, Icons.person_outline, 'My space'),
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
    return buildSelectedPage();
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
