import 'package:flutter/material.dart';

import '../model/plant.dart';
import '../services/api_service.dart';

class PlantInformationDialog extends StatefulWidget {
  final Plant plant;
  final ApiService? apiService;
  const PlantInformationDialog({
    super.key,
    required this.plant,
    this.apiService,
  });
  @override
  State<PlantInformationDialog> createState() => _PlantInformationDialogState();
}

class _PlantInformationDialogState extends State<PlantInformationDialog> {
  late final ApiService apiService = widget.apiService ?? ApiService();
  late Future<PlantDescription> detail = apiService.description(widget.plant);

  void reloadDescription() {
    setState(() {
      detail = apiService.description(widget.plant);
    });
  }

  Widget descriptionContent(String text) {
    if (text.trim().isEmpty) {
      return const Text('Full description not available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final paragraph in text.split('\n\n'))
          if (paragraph.trim().isNotEmpty) descriptionSection(paragraph),
      ],
    );
  }

  Widget descriptionSection(String paragraph) {
    String? heading;
    String body = paragraph.trim();
    for (final label in ['Examples', 'Origin', 'Care guidance']) {
      if (body.startsWith('$label: ')) {
        heading = label;
        body = body.substring(label.length + 2);
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null) ...[
            Semantics(
              header: true,
              child: Text(
                heading,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(body, style: const TextStyle(height: 1.55)),
        ],
      ),
    );
  }

  Widget sources(PlantDescription result) {
    final plant = widget.plant;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.centerLeft,
      shape: const Border(),
      collapsedShape: const Border(),
      title: const Text(
        'Sources & credits',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      children: [
        Text(
          result.fromInternet
              ? 'Description loaded from Plantfolio on GitHub.'
              : 'Description from the saved Plantfolio catalog.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (plant.reference.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Description source',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SelectableText(
            plant.reference,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
        if (plant.photoReference.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Photo source',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SelectableText(
            plant.photoReference,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.plant.name),
    content: SizedBox(
      width: 340,
      child: FutureBuilder<PlantDescription>(
        future: detail,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load the plant description.'),
                TextButton(
                  onPressed: reloadDescription,
                  child: const Text('Try again'),
                ),
              ],
            );
          }
          if (!snapshot.hasData) return const Text('Loading description...');
          final result = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!result.fromInternet) ...[
                Text(
                  'Showing the saved description.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextButton(
                  onPressed: reloadDescription,
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 8),
              ],
              descriptionContent(result.text),
              sources(result),
            ],
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}
