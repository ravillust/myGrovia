import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'plant_widgets.dart';

class PlantInformationDialog extends StatefulWidget {
  final String botanicalName;
  const PlantInformationDialog({super.key, required this.botanicalName});

  @override
  State<PlantInformationDialog> createState() {
    return _PlantInformationDialogState();
  }
}

class _PlantInformationDialogState extends State<PlantInformationDialog> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  String description = '';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDescription();
  }

  Future<void> loadDescription() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final String result = await apiService.getPlantDescription(
        widget.botanicalName,
      );
      // Dialog bisa sudah ditutup ketika respons internet tiba.
      if (!mounted) {
        return;
      }
      setState(() {
        description = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        errorMessage = 'Could not load plant information. Check your connection and try again.';
      });
    }
  }

  void showSource() {
    final String title = widget.botanicalName.replaceAll(' ', '_');
    final Uri url = Uri.https('en.wikipedia.org', '/wiki/$title');
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Source'),
          content: SelectableText(
            'Wikipedia contributors\n$url\n\n'
            'CC BY-SA 4.0 · Text displayed without edits\n'
            'https://creativecommons.org/licenses/by-sa/4.0/',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget buildInformation() {
    if (isLoading) {
      return const Text('Loading plant information…');
    }
    final String? message = errorMessage;
    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          TextButton(
            onPressed: loadDescription,
            child: const Text('Try again'),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description, style: const TextStyle(height: 1.6)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: showSource,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: mutedText,
          ),
          child: const Text(
            'Source: Wikipedia',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.botanicalName),
      content: SizedBox(width: 340, child: buildInformation()),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
