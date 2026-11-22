import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../widgets/plant_widgets.dart';
import 'plant_detail_page.dart';

class DictionaryPage extends StatefulWidget {
  final List<Plant> catalog;
  final List<CollectionPlant> collection;
  final Set<String> bookmarks;
  final Future<void> Function(Plant, String) onAdd;
  final void Function(Plant) onBookmark;
  final bool savedOnly;
  final void Function(bool) onSavedOnlyChanged;

  const DictionaryPage({
    super.key,
    required this.catalog,
    required this.collection,
    required this.bookmarks,
    required this.onAdd,
    required this.onBookmark,
    required this.savedOnly,
    required this.onSavedOnlyChanged,
  });

  @override
  State<DictionaryPage> createState() {
    return _DictionaryPageState();
  }
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All plants';
  int visibleCount = 40;
  static const lightFilters = {
    'Indirect light': ['Bright indirect', 'Medium indirect'],
    'Direct sunlight': ['Strong direct light'],
    'Low light': ['Low indirect'],
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void clearSearch() {
    setState(() {
      searchController.clear();
      selectedFilter = 'All plants';
      visibleCount = 40;
    });
    widget.onSavedOnlyChanged(false);
  }

  void changeBookmarkView() {
    final showSavedPlants = !widget.savedOnly;
    setState(() {
      searchController.clear();
      selectedFilter = 'All plants';
      visibleCount = 40;
    });
    widget.onSavedOnlyChanged(showSavedPlants);
  }

  void searchSuggestedPlant(String name) {
    setState(() {
      searchController.text = name;
      selectedFilter = 'All plants';
      visibleCount = 40;
    });
    widget.onSavedOnlyChanged(false);
  }

  List<Plant> findMatchingPlants() {
    final String searchText = searchController.text.trim().toLowerCase();
    final List<Plant> results = [];

    // Periksa setiap tanaman, lalu simpan yang memenuhi semua syarat.
    for (final Plant plant in widget.catalog) {
      final String plantNames = '${plant.name} ${plant.botanicalName}'
          .toLowerCase();
      final bool nameMatches = plantNames.contains(searchText);

      final bool categoryMatches =
          selectedFilter == 'All plants' ||
          (lightFilters[selectedFilter]?.contains(plant.light) ?? false);

      bool bookmarkMatches = true;
      if (widget.savedOnly) {
        bookmarkMatches = widget.bookmarks.contains(plant.name);
      }

      if (nameMatches && categoryMatches && bookmarkMatches) {
        results.add(plant);
      }
    }
    return results;
  }

  Future<void> openPlantDetail(Plant plant) async {
    bool alreadyInCollection = false;
    for (final CollectionPlant item in widget.collection) {
      if (item.plant.name == plant.name) {
        alreadyInCollection = true;
        break;
      }
    }

    // Tunggu detail ditutup sebelum menampilkan bookmark terbaru.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PlantDetailPage(
            plant: plant,
            isSaved: widget.bookmarks.contains(plant.name),
            isAdded: alreadyInCollection,
            onBookmark: () {
              widget.onBookmark(plant);
            },
            onAdd: (String room, int days) async {
              await widget.onAdd(plant.withWateringDays(days), room);
            },
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Plant dictionary';
    String bookmarkLabel = 'Show saved plants';
    IconData bookmarkIcon = Icons.bookmark_border;
    if (widget.savedOnly) {
      title = 'Saved plants';
      bookmarkLabel = 'Show all plants';
      bookmarkIcon = Icons.bookmark;
    }

    final Widget heading = PageHeading(
      title: title,
      action: IconButton(
        tooltip: bookmarkLabel,
        onPressed: changeBookmarkView,
        icon: Icon(bookmarkIcon, color: plantGreen),
      ),
    );

    if (widget.savedOnly && widget.bookmarks.isEmpty) {
      return Column(
        children: [
          heading,
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  key: const ValueKey('empty-saved-message'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_border,
                      size: 48,
                      color: mutedText,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No saved plants yet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 230,
                      child: PrimaryButton(
                        label: 'Browse all plants',
                        onPressed: clearSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget? clearButton;
    if (searchController.text.isNotEmpty) {
      clearButton = IconButton(
        tooltip: 'Clear search',
        onPressed: clearSearch,
        icon: const Icon(Icons.cancel_outlined),
      );
    }

    final List<Plant> results = findMatchingPlants();
    return ListView(
      children: [
        heading,
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (String text) {
                  setState(() => visibleCount = 40);
                },
                decoration: InputDecoration(
                  hintText: 'Search plants',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: clearButton,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                key: const ValueKey('dictionary-filters'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildFilterButton('All plants'),
                    for (final name in lightFilters.keys) ...[
                      const SizedBox(width: 8),
                      buildFilterButton(name),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${results.length} ${results.length == 1 ? 'plant' : 'plants'}',
                  style: const TextStyle(color: mutedText, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              if (results.isEmpty) buildNoResults(),
              buildPlantRows(results.take(visibleCount).toList()),
              if (results.length > visibleCount)
                TextButton(
                  onPressed: () => setState(() => visibleCount += 40),
                  child: const Text('Show more plants'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFilterButton(String name) {
    Color textColor = plantGreen;
    if (selectedFilter == name) {
      textColor = Colors.white;
    }
    return ChoiceChip(
      label: Text(name),
      selected: selectedFilter == name,
      selectedColor: plantGreen,
      backgroundColor: neutralSurface,
      labelStyle: TextStyle(color: textColor),
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = name;
          visibleCount = 40;
        });
      },
    );
  }

  Widget buildNoResults() {
    String message = 'No plants match these filters. Try clearing them.';
    if (searchController.text.trim().isNotEmpty) {
      message =
          'We couldn’t match “${searchController.text.trim()}”. Try a shorter name or clear the filters.';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.search, size: 48, color: mutedText),
          const SizedBox(height: 28),
          Text(
            'No plants found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedText, height: 1.6),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 230,
            child: PrimaryButton(label: 'Clear search', onPressed: clearSearch),
          ),
          const SizedBox(height: 32),
          const Text(
            'TRY SEARCHING',
            style: TextStyle(color: mutedText, fontSize: 12),
          ),
          Wrap(
            children: [
              buildSearchSuggestion('Pothos'),
              buildSearchSuggestion('Calathea'),
              buildSearchSuggestion('Snake Plant'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSearchSuggestion(String name) {
    return TextButton(
      onPressed: () {
        searchSuggestedPlant(name);
      },
      child: Text(name),
    );
  }

  Widget buildPlantRows(List<Plant> results) {
    // Lebar isi adalah lebar layar dikurangi padding kiri dan kanan.
    final double contentWidth = MediaQuery.sizeOf(context).width - 48;
    final List<Widget> rows = [];
    if (contentWidth < 340) {
      for (final Plant plant in results) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: buildPlantCard(plant),
          ),
        );
      }
    } else {
      // Dua kartu per baris. Jika jumlahnya ganjil, sisi kanan tetap kosong.
      for (int index = 0; index < results.length; index += 2) {
        Widget rightCard = const SizedBox();
        if (index + 1 < results.length) {
          rightCard = buildPlantCard(results[index + 1]);
        }
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildPlantCard(results[index])),
                const SizedBox(width: 16),
                Expanded(child: rightCard),
              ],
            ),
          ),
        );
      }
    }
    return Column(children: rows);
  }

  Widget buildPlantCard(Plant plant) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        openPlantDetail(plant);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PlantPhoto(plant: plant, height: 205),
          ),
          const SizedBox(height: 10),
          Text(
            plant.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          if (plant.botanicalName.trim().isNotEmpty)
            Text(
              plant.botanicalName,
              style: const TextStyle(
                color: mutedText,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
