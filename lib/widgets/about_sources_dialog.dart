import 'package:flutter/material.dart';

class AboutSourcesDialog extends StatelessWidget {
  const AboutSourcesDialog({super.key});

  Widget section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('About & sources'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section(
            'myGrovia',
            'A plant collection and watering journal. Your collection and watering history are stored on this device.',
          ),
          section(
            'Plant data',
            'Plantfolio Common Plants © 2026 Luminoid\n'
                'https://github.com/Luminoid/plantfolio-common-plants\n\n'
                'CC BY-NC-SA 4.0\n'
                'https://creativecommons.org/licenses/by-nc-sa/4.0/\n\n'
                'The catalog is bundled with the app. Read more loads descriptions from the same source through the GitHub API, with a saved copy available offline. '
                'Display names and light labels are adapted. Scientific-name labels and care filters are supplied by myGrovia. Adapted plant data is shared under the same license.',
          ),
          section(
            'Plant photos',
            'Verified Wikimedia photos are bundled for offline use. Open a plant, then Read more → Sources & credits for its photographer, source, license, and resizing details. '
                'Plants without a verified photo use the default illustration.',
          ),
          section(
            'Logo & illustration',
            'The myGrovia logo and default plant illustration were created by the myGrovia team.',
          ),
          section(
            'Watering guidance',
            'Watering estimates use the dataset’s summer intervals as a starting point. Adjust to your soil, room, and plant conditions.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
